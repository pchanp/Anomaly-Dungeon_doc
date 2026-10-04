#!/usr/bin/env python3
"""設計案ではない仮データを一時ディレクトリに置いて検証器を確認する。"""
import copy
import json
from pathlib import Path
import sys
import tempfile
import unittest

sys.dont_write_bytecode=True
import validate as v
import summarize_timing as timing


def fixture(role='A',n=1):
    raw=json.dumps(v.read_json(v.PACK/f'templates/candidate-{role.lower()}.json'),ensure_ascii=False)
    data=json.loads(raw.replace('【記入】','検証用文字列（設計案ではない）'))
    data['candidate_id']=f'ROLE-{role}-{n:03d}';data['html_file']=data['candidate_id']+'.html'
    slot=next(s for s in v.read_json(v.PACK/'reserved-ids.json')['slots'] if s['candidate_id']==data['candidate_id'])
    data['primary_map']=slot['primary_map'];data['classification']=slot['classification']
    if role=='A' and n==13:data['role_details']['mob_contract']['applicable']=True
    return data


class ValidationTests(unittest.TestCase):
    def test_schema_templates_have_valid_shapes(self):
        for role in 'ABC':self.assertEqual(v.schema_errors(fixture(role),v.read_json(v.PACK/'candidate.schema.json')),[])
    def test_bad_effect_kind_fails(self):
        data=fixture();data['effects'][0]['kind']='Sound'
        self.assertTrue(v.candidate_errors(data,'A'))
    def test_numeric_boolean_does_not_pass(self):
        data=fixture();data['requires_code']=1
        self.assertTrue(v.candidate_errors(data,'A'))
    def test_changed_map_fails(self):
        data=fixture();data['primary_map']='研究所'
        self.assertIn('candidate map/classification differs from reservation',v.candidate_errors(data,'A'))
    def test_source_status_is_checked(self):
        data=fixture();data['source_evidence'][0]['source_status']='Status: Implemented'
        self.assertTrue(any('Status mismatch' in e for e in v.candidate_errors(data,'A')))
    def test_unreserved_ref_fails(self):
        data=fixture();data['refs']=[{'target_id':'ROLE-B-999','kind':'optional_connection','required_traits':['trait'],'fallback':'未接続','resolution':'reserved_unresolved'}]
        self.assertTrue(v.candidate_errors(data,'A'))
    def test_reserved_missing_ref_is_review(self):
        data=fixture();data['refs']=[{'target_id':'ROLE-B-001','kind':'optional_connection','required_traits':['trait'],'fallback':'未接続でも検証用記録','resolution':'reserved_unresolved'}]
        data['unresolved_refs']=[{'target_id':'ROLE-B-001','required_traits':['trait'],'reason':'検証用未作成','adoption_blocker':False}]
        self.assertEqual(v.candidate_errors(data,'A'),[])
        self.assertTrue(any(x['type']=='reserved_not_created_or_not_loaded' for x in v.reference_review({data['candidate_id']:data})))
    def test_cycles_are_distinguished(self):
        a,b=fixture('A'),fixture('B')
        for kind in ['data_dependency','interaction_loop']:
            a['refs']=[{'target_id':b['candidate_id'],'kind':kind,'required_traits':['trait'],'fallback':'検証用','resolution':'draft_available'}]
            b['refs']=[{'target_id':a['candidate_id'],'kind':kind,'required_traits':['trait'],'fallback':'検証用','resolution':'draft_available'}]
            records={a['candidate_id']:a,b['candidate_id']:b}
            report=v.reference_review(records)
            self.assertTrue(any(r['type']==kind+'_cycle' for r in report))
            other='interaction_loop' if kind=='data_dependency' else 'data_dependency'
            self.assertFalse(any(r['type']==other+'_cycle' for r in report))
    def test_traits_mismatch_is_review(self):
        a,b=fixture('A'),fixture('B')
        a['refs']=[{'target_id':b['candidate_id'],'kind':'optional_connection','required_traits':['absent'],'fallback':'検証用','resolution':'draft_available'}]
        self.assertTrue(any(r['type']=='required_traits_mismatch' for r in v.reference_review({a['candidate_id']:a,b['candidate_id']:b})))
    def test_item_routes_cannot_duplicate(self):
        data=fixture('B');data['role_details']['routes'][0]['route']='Use'
        self.assertTrue(any('10 paths' in e for e in v.candidate_errors(data,'B')))
    def test_skill_levels_cannot_duplicate(self):
        data=fixture('C');data['role_details']['levels'][0]['level']=2
        self.assertTrue(any('1,2,3' in e for e in v.candidate_errors(data,'C')))
    def test_mob_pilot_requirement(self):
        data=fixture('A',13);data['role_details']['mob_contract']['applicable']=False
        self.assertTrue(any('normal mob' in e for e in v.candidate_errors(data,'A')))
    def test_missing_svg_and_remote_asset_fail(self):
        data=fixture()
        with tempfile.TemporaryDirectory() as name:
            path=Path(name)/data['html_file'];path.write_text('<html><script src="https://example.invalid/a.js"></script><img src="https://example.invalid/a.png"></html>')
            errors=v.html_errors(path,Path(name),candidate=data)
            self.assertIn('inline SVG missing',errors)
            self.assertTrue(any('external' in e for e in errors))
    def test_pilot_manifest_and_progress(self):
        with tempfile.TemporaryDirectory() as name:
            out=Path(name);entries=[]
            template=(v.PACK/'templates/candidate.html').read_text().replace('【記入】','検証用').replace('TEMPLATE','検証用')
            for n in [1,4,13]:
                data=fixture('A',n);cid=data['candidate_id']
                data['design_hypothesis']+=str(n)
                (out/(cid+'.json')).write_text(json.dumps(data,ensure_ascii=False))
                (out/(cid+'.html')).write_text(template.replace('検証用候補IDと作業用タイトル',cid+' '+data['title'])+'\n<!-- '+data['design_status']+' -->')
                entries.append({'candidate_id':cid,'json_file':cid+'.json','html_file':cid+'.html'})
            (out/'manifest.json').write_text(json.dumps({'run_id':v.RUN,'role':'A','candidates':entries}))
            (out/'index.html').write_text('<html>'+''.join('<a href="'+x['html_file']+'">test</a>' for x in entries)+'</html>')
            progress=v.read_json(v.PACK/'templates/progress.json');progress.update(role='A',state='awaiting_pilot_review',completed_ids=[x['candidate_id'] for x in entries])
            (out/'progress.json').write_text(json.dumps(progress))
            (out/'events.jsonl').write_text(json.dumps({'at':None,'event':'checkpoint','candidate_ids':progress['completed_ids'],'note':'検証用。実時刻なし。'})+'\n')
            (out/'handoff.md').write_text('検証用記録。設計案ではない。')
            (out/'board.css').write_text((v.PACK/'templates/board.css').read_text())
            errors,review,records=v.output_check('A',out,'pilot')
            self.assertEqual(errors,[])
            self.assertEqual(len(records),3)
            self.assertTrue(any(r['type']=='visual_check_pending_or_unavailable' for r in review))
    def test_timing_uses_real_intervals_and_gaps(self):
        with tempfile.TemporaryDirectory() as name:
            path=Path(name)/'events.jsonl'
            events=[]
            for at,event in [('2026-10-04T00:00:00+00:00','session_start'),('2026-10-04T00:01:00+00:00','batch_start'),('2026-10-04T00:02:00+00:00','batch_end'),('2026-10-04T00:03:00+00:00','session_end'),('2026-10-04T00:04:00+00:00','session_start'),('2026-10-04T00:05:00+00:00','session_end')]:
                events.append({'at':at,'event':event,'candidate_ids':[],'note':'検証用時刻'})
            path.write_text('\n'.join(json.dumps(e) for e in events))
            result=timing.summarize(path)
            self.assertEqual(result['overall_elapsed_seconds'],300)
            self.assertEqual(result['between_sessions_seconds'],60)
            self.assertEqual(result['phase_totals_seconds']['batch'],60)


if __name__=='__main__':unittest.main()
