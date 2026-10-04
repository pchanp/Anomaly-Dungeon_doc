#!/usr/bin/env python3
"""共通パックと設計候補を読み取り検証する。ゲームデータを生成・実行しない。"""
import argparse
from collections import Counter
from datetime import datetime
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit
import xml.etree.ElementTree as ET

sys.dont_write_bytecode = True
PACK = Path(__file__).resolve().parent.parent
RUN = 'overnight-design-pilot-v1'
SECTIONS = {'sources', 'hypothesis', 'diagram', 'effects', 'uncertainties', 'connections', 'cost', 'role-details'}
ROUTES = {'Acquire', 'Hold', 'Use', 'Present', 'Place', 'Lose', 'SecureSlot', 'Sell', 'Quest', 'AnomalyInteraction'}
SCHEMA_KEYS = {'$schema', '$ref', '$defs', 'title', 'description', 'type', 'const', 'enum', 'required', 'properties', 'additionalProperties', 'items', 'minItems', 'maxItems', 'uniqueItems', 'minLength', 'pattern', 'minimum', 'maximum', 'allOf', 'if', 'then', 'else'}


def read_json(path):
    # 重複キーとNaN/Infinityを受理しない。
    def pairs(items):
        result = {}
        for key, val in items:
            if key in result:
                raise ValueError('duplicate JSON key: ' + key)
            result[key] = val
        return result
    def reject_constant(text):
        raise ValueError('invalid JSON constant: ' + text)
    return json.loads(Path(path).read_text(encoding='utf-8'), object_pairs_hook=pairs, parse_constant=reject_constant)


def schema_lint(schema, location='$'):
    errors = []
    for key in schema:
        if key not in SCHEMA_KEYS:
            errors.append(location + ': unsupported schema keyword ' + key)
    for key in ('properties', '$defs'):
        for name, child in schema.get(key, {}).items():
            errors.extend(schema_lint(child, location + '/' + key + '/' + name))
    for key in ('items', 'if', 'then', 'else'):
        if key in schema:
            errors.extend(schema_lint(schema[key], location + '/' + key))
    for idx, child in enumerate(schema.get('allOf', [])):
        errors.extend(schema_lint(child, location + '/allOf/' + str(idx)))
    return errors


def schema_errors(data, schema, root=None, location='$'):
    """このパックが使うJSON Schemaのキーワードだけを評価する。"""
    root = root or schema
    errors = []
    if '$ref' in schema:
        pointer = schema['$ref']
        if not pointer.startswith('#/'):
            return [location + ': non-local schema reference']
        target = root
        for part in pointer[2:].split('/'):
            target = target[part.replace('~1', '/').replace('~0', '~')]
        errors.extend(schema_errors(data, target, root, location))
    types = schema.get('type')
    if types:
        types = [types] if isinstance(types, str) else types
        matches = {
            'object': isinstance(data, dict),
            'array': isinstance(data, list),
            'string': isinstance(data, str),
            'boolean': type(data) is bool,
            'integer': type(data) is int,
            'number': type(data) in (int, float),
            'null': data is None,
        }
        if not any(matches.get(t, False) for t in types):
            return errors + [location + ': type must be ' + str(types)]
    canonical = lambda val: json.dumps(val, sort_keys=True, ensure_ascii=False)
    if 'const' in schema and canonical(data) != canonical(schema['const']):
        errors.append(location + ': const mismatch')
    if 'enum' in schema and canonical(data) not in [canonical(x) for x in schema['enum']]:
        errors.append(location + ': enum mismatch')
    if isinstance(data, dict):
        for key in schema.get('required', []):
            if key not in data:
                errors.append(location + ': missing ' + key)
        props = schema.get('properties', {})
        if schema.get('additionalProperties') is False:
            for key in set(data) - set(props):
                errors.append(location + ': unexpected property ' + key)
        for key, child in props.items():
            if key in data:
                errors.extend(schema_errors(data[key], child, root, location + '/' + key))
    if isinstance(data, list):
        if len(data) < schema.get('minItems', 0):
            errors.append(location + ': too few items')
        if 'maxItems' in schema and len(data) > schema['maxItems']:
            errors.append(location + ': too many items')
        if schema.get('uniqueItems') and len({canonical(x) for x in data}) != len(data):
            errors.append(location + ': duplicate items')
        for idx, val in enumerate(data):
            if 'items' in schema:
                errors.extend(schema_errors(val, schema['items'], root, location + '/' + str(idx)))
    if isinstance(data, str):
        if len(data) < schema.get('minLength', 0) or not data.strip():
            errors.append(location + ': empty string')
        if 'pattern' in schema and not re.search(schema['pattern'], data):
            errors.append(location + ': pattern mismatch')
    if type(data) in (int, float):
        if 'minimum' in schema and data < schema['minimum']:
            errors.append(location + ': below minimum')
        if 'maximum' in schema and data > schema['maximum']:
            errors.append(location + ': above maximum')
    for child in schema.get('allOf', []):
        errors.extend(schema_errors(data, child, root, location))
    if 'if' in schema:
        branch = 'then' if not schema_errors(data, schema['if'], root, location) else 'else'
        if branch in schema:
            errors.extend(schema_errors(data, schema[branch], root, location))
    return errors


class Page(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []
        self.text = []
        self.links = []
        self.assets = []
        self.forbidden = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if 'id' in attrs:
            self.ids.append(attrs['id'])
        if tag in {'script', 'iframe', 'object', 'embed', 'foreignobject', 'base'}:
            self.forbidden.append(tag)
        if tag == 'meta' and attrs.get('http-equiv', '').lower() == 'refresh':
            self.forbidden.append('meta refresh')
        if any(key.startswith('on') for key in attrs):
            self.forbidden.append('event handler')
        if tag == 'a' and attrs.get('href'):
            self.links.append(attrs['href'])
        if tag in {'img', 'audio', 'video', 'source', 'image'}:
            for key in ('src', 'srcset', 'href', 'xlink:href'):
                if attrs.get(key):
                    self.assets.append(attrs[key])
        if tag == 'link' and attrs.get('href'):
            self.assets.append(attrs['href'])
        if tag == 'use':
            self.assets.append(attrs.get('href', attrs.get('xlink:href', '')))
    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
    def handle_data(self, data):
        self.text.append(data)


def local_link_error(href, page, output, pack, anchors, asset=False):
    parsed = urlsplit(href)
    if parsed.scheme or parsed.netloc:
        if not asset and parsed.scheme in {'http', 'https'}:
            return None  # 出典へのリンクは表示の外部依存ではない。
        return 'external or unsafe asset/link: ' + href
    if not parsed.path:
        if parsed.fragment and parsed.fragment not in anchors:
            return 'missing anchor: ' + href
        return None
    target = (page.parent / unquote(parsed.path)).resolve()
    if not (target.is_relative_to(output.resolve()) or target.is_relative_to(pack.resolve())):
        return 'local link outside output/pack: ' + href
    if not target.is_file():
        return 'missing local file: ' + href
    if parsed.fragment and target.suffix == '.html':
        other = Page();other.feed(target.read_text(encoding='utf-8'))
        if parsed.fragment not in other.ids:
            return 'missing linked anchor: ' + href
    return None


def html_errors(path, output, pack=PACK, candidate=None):
    errors = []
    resolved = path.resolve()
    if not (resolved.is_relative_to(output.resolve()) or resolved.is_relative_to(pack.resolve())):
        return ['HTML file escapes output/pack']
    text = path.read_text(encoding='utf-8')
    page = Page();page.feed(text)
    if len(page.ids) != len(set(page.ids)):
        errors.append('duplicate HTML id')
    if page.forbidden:
        errors.append('forbidden HTML features: ' + ', '.join(page.forbidden))
    for href in page.links:
        err = local_link_error(href, path, output, pack, page.ids)
        if err:errors.append(err)
    for href in page.assets:
        err = local_link_error(href, path, output, pack, page.ids, asset=True)
        if err:errors.append(err)
    if re.search(r'@import\b|url\s*\(\s*[\'"]?\s*(?:https?:|//)', text, re.I):
        errors.append('external CSS dependency')
    svgs = re.findall(r'<svg\b[\s\S]*?</svg\s*>', text, re.I)
    if candidate and not svgs:
        errors.append('inline SVG missing')
    for svg in svgs:
        try:
            element = ET.fromstring(svg)
            if not element.get('viewBox') or element.get('role') != 'img' or not element.get('aria-label'):
                errors.append('SVG needs viewBox, role=img, aria-label')
        except ET.ParseError as exc:
            errors.append('invalid SVG: ' + str(exc))
    if candidate:
        for section in sorted(SECTIONS - set(page.ids)):
            errors.append('missing HTML section: ' + section)
        rendered = ' '.join(page.text)
        for val in (candidate['candidate_id'], candidate['title'], candidate['design_status']):
            if val not in rendered:
                errors.append('HTML/JSON identifier or title/status mismatch: ' + val)
        if '【記入】' in text or 'TEMPLATE' in text:
            errors.append('unfinished HTML template')
    return errors


def pack_errors(pack=PACK):
    errors = []
    schema = read_json(pack / 'candidate.schema.json')
    errors.extend(schema_lint(schema))
    sources = read_json(pack / 'sources.json')
    for entry in sources['entries']:
        file = (pack / entry['snapshot']).resolve()
        if not file.is_relative_to(pack.resolve()) or not file.is_file():
            errors.append('missing/unsafe snapshot: ' + entry['snapshot'])
        elif hashlib.sha256(file.read_bytes()).hexdigest() != entry['sha256']:
            errors.append('snapshot hash mismatch: ' + entry['path'])
    reserved = read_json(pack / 'reserved-ids.json')
    slots = reserved['slots']
    if reserved['run_id'] != RUN or len(slots) != 45 or len({s['candidate_id'] for s in slots}) != 45:
        errors.append('reservation count/identity mismatch')
    for role in 'ABC':
        if Counter(s['primary_map'] for s in slots if s['role'] == role) != Counter({m:3 for m in ['8/31','廃TSUTAYA','SEKIGAHARA','研究所','全マップ共通']}):
            errors.append('reservation map allocation mismatch: ' + role)
    config = read_json(pack / 'run-config.json')
    if config['run_id'] != RUN or config['total_candidates'] != 45 or config['generation_enabled'] is not False:
        errors.append('prepared run-config mismatch')
    for role in 'abc':
        errors.extend('template-' + role + ': ' + e for e in schema_errors(read_json(pack / f'templates/candidate-{role}.json'), schema))
    errors.extend(html_errors(pack / 'templates/candidate.html', pack, pack))
    integrity = read_json(pack / 'pack-integrity.json')
    expected = set(integrity['files'])
    actual = {str(f.relative_to(pack)) for f in pack.rglob('*') if f.is_file() and f.name != 'pack-integrity.json'}
    if expected != actual:
        errors.append('pack file set changed: missing=' + str(sorted(expected-actual)) + ' extra=' + str(sorted(actual-expected)))
    for name, digest in integrity['files'].items():
        file = (pack / name).resolve()
        if not file.is_relative_to(pack.resolve()) or not file.is_file() or hashlib.sha256(file.read_bytes()).hexdigest() != digest:
            errors.append('pack hash mismatch: ' + name)
    return errors


def candidate_errors(data, role, pack=PACK):
    schema = read_json(pack / 'candidate.schema.json')
    errors = schema_errors(data, schema)
    if errors:return errors
    slots = {s['candidate_id']:s for s in read_json(pack / 'reserved-ids.json')['slots']}
    slot = slots.get(data['candidate_id'])
    if not slot or data['role'] != role or slot['role'] != role:
        errors.append('candidate role/reservation mismatch')
    elif data['primary_map'] != slot['primary_map'] or data['classification'] != slot['classification']:
        errors.append('candidate map/classification differs from reservation')
    if data['html_file'] != data['candidate_id'] + '.html':
        errors.append('html_file differs from candidate ID')
    cats = {'A':{'GimmickEvent','NPC','MobEnemy'},'B':{'Item'},'C':{'Skill'}}
    if data['category'] not in cats[role]:errors.append('category outside role')
    if '【記入】' in json.dumps(data, ensure_ascii=False):errors.append('unfinished JSON template')
    sources = {s['path']:s for s in read_json(pack / 'sources.json')['entries']}
    for entry in data['source_evidence']:
        source = sources.get(entry['path'])
        if not source or not entry['path'].endswith('.md'):
            errors.append('MD absent from snapshot: ' + entry['path'])
        else:
            if entry['source_status'] not in source['status_declarations']:
                errors.append('source Status mismatch: ' + entry['path'])
            if entry['section'] not in (pack / source['snapshot']).read_text(encoding='utf-8'):
                errors.append('source section not found: ' + entry['path'] + '#' + entry['section'])
    for conflict in data['conflicts']:
        if conflict['source_path'] not in sources or not conflict['source_path'].endswith('.md'):
            errors.append('conflict MD absent from snapshot: ' + conflict['source_path'])
    catalog = {c['component'] for c in read_json(pack / 'components.json')['components']}
    for component in data['components']:
        if component['availability'] == 'catalog' and component['component'] not in catalog:
            errors.append('unknown catalog component: ' + component['component'])
    if data['requires_code'] is False and (data['new_logic'] or any(c['availability']=='proposed' for c in data['components'])):
        errors.append('requires_code=false conflicts with new/proposed logic')
    unresolved = {r['target_id'] for r in data['unresolved_refs']}
    seen = []
    for entry in data['refs']:
        seen.append((entry['target_id'],entry['kind']))
        if entry['target_id'] not in slots:
            errors.append('unreserved reference: ' + entry['target_id'])
        if entry['resolution'] in {'reserved_unresolved','incompatible'} and entry['target_id'] not in unresolved:
            errors.append('unresolved/incompatible ref not in unresolved_refs: ' + entry['target_id'])
    if len(seen) != len(set(seen)):errors.append('duplicate reference kind/target')
    for target in unresolved - {None}:
        if target not in slots:errors.append('unreserved unresolved reference: ' + target)
    if role == 'A':
        mob = data['role_details']['mob_contract']
        if data['candidate_id']=='ROLE-A-013' and not mob['applicable']:
            errors.append('ROLE-A-013 must contain an event-spawned normal mob')
        if data['category']=='MobEnemy' and not mob['applicable']:
            errors.append('MobEnemy must have an applicable mob contract')
    elif role == 'B':
        if Counter(r['route'] for r in data['role_details']['routes']) != Counter({r:1 for r in ROUTES}):
            errors.append('Item routes must contain each of 10 paths once')
    elif role == 'C':
        if Counter(r['level'] for r in data['role_details']['levels']) != Counter({1:1,2:1,3:1}):
            errors.append('Skill levels must be 1,2,3 once each')
        for tech in data['role_details']['real_techniques']:
            if tech['confirmation']=='Confirmed' and (not tech['source_url'] or urlsplit(tech['source_url']).scheme not in {'http','https'}):
                errors.append('Confirmed technique requires a verified source URL')
    return errors


def cycles(records, kind):
    graph = {cid:[r['target_id'] for r in d['refs'] if r['kind']==kind and r['target_id'] in records] for cid,d in records.items()}
    visited, stack, found = set(), [], set()
    def walk(node):
        if node in stack:
            part = stack[stack.index(node):]
            rotations = [tuple(part[n:]+part[:n]) for n in range(len(part))]
            found.add(min(rotations));return
        if node in visited:return
        stack.append(node)
        for nxt in graph[node]:walk(nxt)
        stack.pop();visited.add(node)
    for node in sorted(graph):walk(node)
    return [list(c)+[c[0]] for c in sorted(found)]


def reference_review(records):
    review = []
    for cid,data in records.items():
        for entry in data['refs']:
            other = records.get(entry['target_id'])
            if other is None:
                review.append({'type':'reserved_not_created_or_not_loaded','candidate_id':cid,'target_id':entry['target_id'],'required_traits':entry['required_traits'],'claimed_resolution':entry['resolution']})
            else:
                missing = sorted(set(entry['required_traits']) - set(other['provides_traits']))
                if missing:
                    review.append({'type':'required_traits_mismatch','candidate_id':cid,'target_id':entry['target_id'],'missing_traits':missing})
                if entry['resolution'] != 'draft_available':
                    review.append({'type':'reference_resolution_needs_review','candidate_id':cid,'target_id':entry['target_id'],'claimed_resolution':entry['resolution']})
        for entry in data['unresolved_refs']:
            review.append({'type':'unresolved_reference','candidate_id':cid,**entry})
    for kind in ['data_dependency','interaction_loop']:
        for cycle in cycles(records,kind):
            review.append({'type':kind+'_cycle','path':cycle,'interpretation':'採用後の起動データ依存の停止論点' if kind=='data_dependency' else 'ゲーム内ループ。再発動上限と終了条件のレビュー'})
    return review


def output_check(role, output, stage, pack=PACK):
    errors, review, records = [], [], {}
    output = output.resolve()
    manifest = read_json(output / 'manifest.json')
    if set(manifest) != {'run_id','role','candidates'} or manifest['run_id']!=RUN or manifest['role']!=role:
        return ['manifest header/shape mismatch'], review, records
    if not isinstance(manifest['candidates'], list):return ['manifest candidates must be array'], review, records
    files, html_files = [], []
    for item in manifest['candidates']:
        if not isinstance(item, dict) or set(item) != {'candidate_id','json_file','html_file'}:
            errors.append('manifest entry shape mismatch');continue
        cid = item['candidate_id']
        if not isinstance(cid,str) or not re.fullmatch(r'ROLE-'+role+r'-(00[1-9]|01[0-5])',cid):
            errors.append('manifest ID invalid/outside role');continue
        if item['json_file']!=cid+'.json' or item['html_file']!=cid+'.html':
            errors.append('manifest filenames differ from ID: ' + cid);continue
        files.append(item['json_file']);html_files.append(item['html_file'])
        if cid in records:errors.append('duplicate candidate ID: '+cid);continue
        try:
            path = output / item['json_file']
            if not path.resolve().is_relative_to(output):raise ValueError('candidate path escapes output')
            data = read_json(path)
            errs = candidate_errors(data,role,pack)
            if data.get('candidate_id')!=cid:errs.append('manifest/JSON ID mismatch')
            errors.extend(cid+': '+err for err in errs)
            if errs:continue
            html_path = output / item['html_file']
            errors.extend(cid+': '+err for err in html_errors(html_path,output,pack,data))
            records[cid] = data
            if data['requires_code']=='unknown':review.append({'type':'requires_code_unknown','candidate_id':cid,'reason':data['requires_code_reason']})
            catalog = {c['component']:c for c in read_json(pack / 'components.json')['components']}
            for c in data['components']:
                if c['availability']=='proposed' or catalog.get(c['component'],{}).get('implementation_status') in {'Partial','NotImplemented','Unconfirmed'}:
                    review.append({'type':'component_implementation_review','candidate_id':cid,**c})
            for c in data['conflicts']:review.append({'type':'spec_conflict','candidate_id':cid,**c})
            for c in data['uncertainties']:review.append({'type':'uncertainty','candidate_id':cid,'note':c})
        except (OSError,ValueError,KeyError,TypeError) as exc:
            errors.append(cid+': '+str(exc))
    for names,label in [(files,'JSON'),(html_files,'HTML')]:
        if len(names)!=len(set(names)):errors.append('duplicate '+label+' filename')
    actual_json={p.name for p in output.glob('ROLE-*.json')}
    actual_html={p.name for p in output.glob('ROLE-*.html')}
    if set(files)!=actual_json or set(html_files)!=actual_html:
        errors.append('manifest and candidate file set differ')
    slots={s['candidate_id'] for s in read_json(pack / 'reserved-ids.json')['slots'] if s['role']==role}
    pilot={f'ROLE-{role}-{n:03d}' for n in [1,4,13]}
    if stage=='pilot' and set(records)!=pilot:errors.append('pilot requires exactly IDs 001,004,013')
    if stage=='final' and set(records)!=slots:errors.append('final requires all 15 reserved IDs')
    if len(records)>15:errors.append('more than 15 candidates')
    index_path=output/'index.html'
    try:
        errors.extend('index: '+err for err in html_errors(index_path,output,pack))
        index=Page();index.feed(index_path.read_text(encoding='utf-8'))
        linked={unquote(urlsplit(h).path).removeprefix('./') for h in index.links if not urlsplit(h).scheme}
        if not set(html_files).issubset(linked):errors.append('index does not link to all candidates')
    except (OSError,ValueError) as exc:errors.append('index: '+str(exc))
    for css in output.rglob('*.css'):
        if re.search(r'@import\b|url\s*\(\s*[\'"]?\s*(?:https?:|//)',css.read_text(encoding='utf-8'),re.I):
            errors.append('external CSS dependency: '+css.name)
    fingerprints={}
    for cid,data in records.items():
        body={k:v for k,v in data.items() if k not in {'candidate_id','title','html_file','primary_map','classification'}}
        key=json.dumps(body,sort_keys=True,ensure_ascii=False)
        if key in fingerprints:errors.append('mechanically duplicate candidates: '+fingerprints[key]+' / '+cid)
        fingerprints[key]=cid
    try:
        progress=read_json(output/'progress.json')
        if progress.get('run_id')!=RUN or progress.get('role')!=role:errors.append('progress role/run mismatch')
        if Counter(progress.get('completed_ids',[]))!=Counter(records.keys()):errors.append('progress completed IDs differ')
        if stage=='pilot' and progress.get('state')!='awaiting_pilot_review':errors.append('pilot must stop in awaiting_pilot_review')
        if stage=='final' and progress.get('state')!='completed':errors.append('final progress state must be completed')
        visual=progress.get('visual_check',{})
        checked=set(visual.get('checked_ids',[]))
        if visual.get('status')!='checked' or not set(records).issubset(checked):
            review.append({'type':'visual_check_pending_or_unavailable','role':role,'note':visual.get('note'),'missing_ids':sorted(set(records)-checked)})
        for name in ['events.jsonl','handoff.md','board.css']:
            if not (output/name).is_file():errors.append('missing '+name)
        if (output/'events.jsonl').is_file():
            for n,line in enumerate((output/'events.jsonl').read_text(encoding='utf-8').splitlines(),1):
                if not line.strip():continue
                try:
                    event=json.loads(line)
                    if not isinstance(event,dict) or not {'at','event','candidate_ids','note'}.issubset(event):raise ValueError('event fields missing')
                    if event['at'] is not None:
                        time=datetime.fromisoformat(event['at'].replace('Z','+00:00'))
                        if time.tzinfo is None:raise ValueError('event timestamp needs timezone')
                    elif not event['note']:raise ValueError('unknown event timestamp needs reason')
                except (ValueError,TypeError,AttributeError) as exc:errors.append(f'events line {n}: {exc}')
    except (OSError,ValueError,TypeError) as exc:errors.append('progress: '+str(exc))
    return errors,review,records


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pack-only',action='store_true')
    parser.add_argument('--role',choices=list('ABC'))
    parser.add_argument('--output',type=Path)
    parser.add_argument('--stage',choices=['progress','pilot','final'],default='progress')
    parser.add_argument('--peer',action='append',default=[],metavar='ROLE=/path/to/output')
    args=parser.parse_args()
    result={'run_id':RUN,'errors':[],'review_items':[],'candidate_summaries':[],'counts':{},'visual_render_verified':False,'worldview_content_verified':False}
    try:
        result['errors'].extend(pack_errors())
        if not args.pack_only:
            if not args.role or not args.output:parser.error('--role and --output are required unless --pack-only')
            err,review,records=output_check(args.role,args.output,args.stage)
            result['errors'].extend(err);result['review_items'].extend(review)
            used_roles={args.role}
            for peer in args.peer:
                role,sep,path=peer.partition('=')
                if not sep or role not in 'ABC' or len(role)!=1 or role in used_roles:raise ValueError('peer must have a unique other role: ROLE=/path')
                used_roles.add(role)
                peer_stage='final' if args.stage=='final' else 'progress'
                err,review,other=output_check(role,Path(path),peer_stage)
                result['errors'].extend('peer '+role+': '+e for e in err);result['review_items'].extend(review)
                duplicate=set(records)&set(other)
                if duplicate:result['errors'].append('cross-role duplicate IDs: '+str(sorted(duplicate)))
                records.update(other)
            result['review_items'].extend(reference_review(records))
            result['counts']=dict(Counter(d['role']+':'+d['primary_map'] for d in records.values()))
            result['candidate_summaries']=[{'candidate_id':cid,'title':d['title'],'primary_map':d['primary_map'],'category':d['category'],'design_status':d['design_status'],'requires_code':d['requires_code'],'prototype_cost':d['prototype_cost'],'connection_tags':d['connection_tags'],'conflict_count':len(d['conflicts']),'unresolved_count':len(d['unresolved_refs'])} for cid,d in sorted(records.items())]
        result['mechanical_validation']='passed' if not result['errors'] else 'failed'
        print(json.dumps(result,ensure_ascii=False,indent=2))
        return 1 if result['errors'] else 0
    except (OSError,ValueError,KeyError,TypeError) as exc:
        result['errors'].append('input/pack problem: '+str(exc));result['mechanical_validation']='not_completed'
        print(json.dumps(result,ensure_ascii=False,indent=2));return 2


if __name__=='__main__':
    raise SystemExit(main())
