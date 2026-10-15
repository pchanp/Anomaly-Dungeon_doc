"""Freeze Fox20 images and construct an offline review page. No generation or network."""
import base64
import hashlib
import json
from pathlib import Path
import struct
import subprocess

RUN = Path(__file__).resolve().parent
ROOT = next(p for p in RUN.parents if (p / 'AGENTS.md').exists() and (p / 'docs/systems/skill-build.md').exists())
BASE = ROOT / 'work/icon-generation'
BATCH = BASE / 'shade-20261014-fox20'

def sha(data):
    return hashlib.sha256(data).hexdigest()

def build():
    if (RUN / 'review.html').exists():
        raise SystemExit('Existing review snapshot preserved. Use a new run to rebuild.')
    batch = json.loads((BATCH / 'batch.json').read_text())
    verified = {x['variant']: x for x in json.loads((BATCH / 'generation-verification.json').read_text())['images']}
    assert len(batch['jobs']) == 20
    candidates = []
    for job in sorted(batch['jobs'], key=lambda j: j['variant']):
        p = BASE / job['outputs'][0]
        raw = p.read_bytes()
        assert raw[:8] == b'\x89PNG\r\n\x1a\n'
        width, height = struct.unpack('>II', raw[16:24])
        digest = sha(raw)
        assert digest == verified[job['variant']]['sha256'], job['variant']
        assert (width, height) == (1024, 1024)
        request = BASE / job['request']
        candidates.append(dict(variant=job['variant'], label=job['label'], job_id=job['id'],
            source=str(p.relative_to(ROOT)), sha256=digest, width=width, height=height,
            seed=job['seed'], mode=job.get('mode', 'txt2img'),
            denoising_strength=job.get('denoising_strength'),
            request=str(request.relative_to(ROOT)), request_sha256=sha(request.read_bytes()),
            image='data:image/png;base64,' + base64.b64encode(raw).decode()))
    assert len({c['sha256'] for c in candidates}) == 20
    source_paths = ['AGENTS.md', 'README.md', 'work/AGENTS.md',
        'work/icon-generation/AGENTS.md', 'docs/systems/skill-build.md',
        'docs/production/workshop/shared/art-direction.md',
        'docs/production/workshop/shared/handoff.md',
        'docs/production/workshop/shared/validation.md',
        'work/icon-generation/shade-20261014-fox20/README.md',
        'work/icon-generation/shade-20261014-fox20/brief.en.md',
        'work/icon-generation/shade-20261014-fox20/revision-brief.en.md',
        'work/icon-generation/shade-20261014-fox20/batch.json',
        'work/icon-generation/shade-20261014-fox20/generation-verification.json']
    manifest = dict(task_id='W01-01', run_id='review-20261015',
        baseline_commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        note='Local hashes fix inputs; HEAD alone does not reproduce uncommitted assets.',
        source_documents=[dict(path=p, sha256=sha((ROOT/p).read_bytes())) for p in source_paths],
        candidates=[{k:v for k,v in c.items() if k != 'image'} for c in candidates])
    (RUN/'inputs.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n')
    data=json.dumps(candidates,ensure_ascii=False).replace('<', '\\u003c')
    page=TEMPLATE.replace('__CANDIDATES__',data)
    (RUN/'review.html').write_text(page)
    report=dict(image_count=20, unique_hashes=20, previous_hashes_match=True,
        full_square_retained=True, html_sha256=sha(page.encode()),
        inputs_sha256=sha((RUN/'inputs.json').read_bytes()),
        html_bytes=len(page.encode()), browser_test='Unconfirmed', human_review='Unreviewed')
    (RUN/'verification.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n')
    print('Prepared 20 frozen candidates; all previous image hashes match.')

TEMPLATE=r'''<!doctype html>
<html lang="ja"><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>W01 SHADE — 候補評価</title>
<style>
*{box-sizing:border-box}body{margin:0;background:#0b1019;color:#e9eef7;font:15px/1.6 system-ui,sans-serif}header,main{max-width:1400px;margin:auto;padding:24px}h1{font-size:30px;margin:0}h2{font-size:17px}p{max-width:900px}.muted{color:#abb8cd}button,input,select,textarea{font:inherit;border:1px solid #5d718b;border-radius:6px;padding:8px;background:#182234;color:#fff}button{cursor:pointer}button:hover{background:#2c405b}label{display:block;margin:8px 0}input{width:min(100%,340px)}.bar{display:flex;flex-wrap:wrap;gap:14px;align-items:center}.bar label{margin:0}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:18px}.card{border:1px solid #36445a;border-radius:12px;padding:16px;background:#121c2c;min-width:0}.stage{background:var(--stage,#111827);padding:16px;display:flex;justify-content:center;border-radius:8px}.large{width:256px;height:256px;max-width:100%;object-fit:contain}.samples{display:flex;gap:14px;justify-content:center;align-items:flex-end;padding:16px;background:var(--stage,#111827);margin:8px 0;border-radius:8px}.sample{text-align:center;font-size:12px;color:#73849b}.samples img{display:block;margin:0 auto 4px;object-fit:contain}.formgrid{display:grid;grid-template-columns:1fr 1fr;gap:6px}.formgrid label{font-size:13px}.formgrid select{width:100%;font-size:13px}textarea{width:100%;min-height:65px}.badge{display:inline-block;background:#20364e;padding:2px 8px;border-radius:20px;font-size:12px}.status{color:#82ddd0}details{margin:10px 0}summary{cursor:pointer}.hash{overflow-wrap:anywhere;font-size:11px}.action{margin:20px 0}.light{--stage:#f3f4f6}a{color:#8acbff}footer{padding:20px}.blind .candidate-title{visibility:hidden}
</style>
<header><span class="badge">W01-01 · Draft · 20 candidates</span><h1>SHADE 候補評価</h1>
<p>まず名称や説明を見ず、画像から何の動作に見えるかを記録してください。その後、姿勢・残像・不要な参照要素・縮小時の見分けやすさを別々に評価します。</p>
<details><summary>今回の目標と評価条件</summary><p>横向きで低く前傾した人型が右へ進み、左後方に同じ姿勢の青い残像と水平の軌跡が見える構図。匿名の簡潔な人型を暫定表現とし、衣装・装備・風景・顔や筋肉の詳細は目的外の要素として確認します。</p><p>32／48／64 CSS pxと256 CSS px、明暗の周辺背景は今回の試用条件です。本番サイズ・透過・ゲームへの採用を決定しません。画像内の背景・上下余白は変更していません。</p><p>前半8枚はtxt2img、後半12枚はimg2img。条件が異なるため、方式だけを原因として比較しません。</p></details>
<div class="bar"><label>比較対象 <select id="filter"><option value="all">全20枚</option><option value="txt2img">txt2img · 8枚</option><option value="img2img">img2img · 12枚</option></select></label><label>周辺背景 <select id="background"><option value="dark">暗色 #111827</option><option value="light">明色 #f3f4f6</option></select></label><label><input id="blind" type="checkbox" style="width:auto">候補ラベルを隠す</label></div>
<div class="bar action"><label>評価者 <input id="reviewer" placeholder="名前または識別名"></label><button id="download">評価をJSONで保存</button><span id="status" class="status" role="status"></span></div>
<p class="muted">入力はこのページを閉じると失われます。「評価をJSONで保存」で記録をダウンロードしてください。明暗背景の評価は別々に保持します。既存ギャラリーのレビューには反映されません。</p>
</header><main><div id="grid" class="grid"></div></main>
<script id="candidates" type="application/json">__CANDIDATES__</script>
<script>
const items=JSON.parse(document.getElementById('candidates').textContent);
const fields=[['pose','低い横向き姿勢・右向き'],['echo','同じ姿勢の独立した残像'],['clean','不要な衣装・背景・顔等がない'],['read32','32pxで動作を識別'],['read48','48pxで動作を識別'],['read64','64pxで動作を識別']];
const states={}; const grid=document.getElementById('grid');
for(const item of items){
 const card=document.createElement('article');card.className='card';card.dataset.mode=item.mode;
 const title=document.createElement('h2');title.className='candidate-title';title.textContent=item.label;card.append(title);
 const badge=document.createElement('span');badge.className='badge';badge.textContent=item.variant+' · '+item.mode;card.append(badge);
 const stage=document.createElement('div');stage.className='stage';const img=document.createElement('img');img.className='large';img.src=item.image;img.alt=item.variant+' full square candidate';stage.append(img);card.append(stage);
 const samples=document.createElement('div');samples.className='samples';for(const size of [32,48,64]){const box=document.createElement('div');box.className='sample';const small=document.createElement('img');small.src=item.image;small.width=size;small.height=size;small.alt=item.variant+' '+size+'px';box.append(small,document.createTextNode(size+'px'));samples.append(box)}card.append(samples);
 const state={dark:{},light:{}};states[item.variant]=state;
 const controls=[]; const bg=()=>document.getElementById('background').value;
 const label=document.createElement('label');label.textContent='何の動作に見える？';const reading=document.createElement('input');reading.style.width='100%';reading.placeholder='説明を見る前の印象';label.append(reading);card.append(label);controls.push(['perceived_action',reading]);reading.oninput=()=>state[bg()].perceived_action=reading.value;
 const form=document.createElement('div');form.className='formgrid';
 for(const [key,text]of fields){const label=document.createElement('label');label.textContent=text;const select=document.createElement('select');for(const [value,name]of [['','未評価'],['clear','明確に満たす'],['partial','一部／曖昧'],['poor','満たさない']]){const op=document.createElement('option');op.value=value;op.textContent=name;select.append(op)}label.append(select);form.append(label);controls.push([key,select]);select.onchange=()=>state[bg()][key]=select.value}card.append(form);
 const verdictLabel=document.createElement('label');verdictLabel.textContent='レビュー提案（正式採用ではありません）';const verdict=document.createElement('select');for(const [v,t]of [['','未審査'],['candidate','採用候補'],['revise','修正したい'],['skip','見送り']]){const op=document.createElement('option');op.value=v;op.textContent=t;verdict.append(op)}verdictLabel.append(verdict);card.append(verdictLabel);controls.push(['suggestion',verdict]);verdict.onchange=()=>state[bg()].suggestion=verdict.value;
 const noteLabel=document.createElement('label');noteLabel.textContent='理由・残したい要素・直したい要素';const note=document.createElement('textarea');noteLabel.append(note);card.append(noteLabel);controls.push(['notes',note]);note.oninput=()=>state[bg()].notes=note.value;
 card.refresh=()=>{for(const [key,control]of controls)control.value=state[bg()][key]||''};
 const details=document.createElement('details');const summary=document.createElement('summary');summary.textContent='入力版・生成条件';const info=document.createElement('p');info.className='hash';info.textContent='SHA256 '+item.sha256+' / Seed '+item.seed+' / '+item.mode+(item.denoising_strength!==null?' / strength '+item.denoising_strength:'');details.append(summary,info);card.append(details);grid.append(card);
}
document.getElementById('filter').onchange=e=>{for(const c of grid.children)c.hidden=e.target.value!=='all'&&c.dataset.mode!==e.target.value};
document.getElementById('background').onchange=e=>{document.body.classList.toggle('light',e.target.value==='light');for(const card of grid.children)card.refresh()};
document.getElementById('blind').onchange=e=>document.body.classList.toggle('blind',e.target.checked);
document.getElementById('download').onclick=()=>{
 const reviewer=document.getElementById('reviewer').value.trim();if(!reviewer){document.getElementById('status').textContent='評価者を記入してください。';return}
 const result={task_id:'W01-01',run_id:'review-20261015',reviewer,reviewed_at:new Date().toISOString(),formal_adoption:false,conditions:{sizes_css_px:[32,48,64,256],backgrounds:{dark:'#111827',light:'#f3f4f6'},device_pixel_ratio:window.devicePixelRatio,viewport_css_px:[innerWidth,innerHeight],browser:navigator.userAgent},candidates:items.map(i=>({variant:i.variant,sha256:i.sha256,source:i.source,ratings_by_background:states[i.variant]}))};
 const blob=new Blob([JSON.stringify(result,null,2)],{type:'application/json'});const url=URL.createObjectURL(blob);const a=document.createElement('a');a.href=url;a.download='W01-01-review-'+Date.now()+'.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);document.getElementById('status').textContent='JSONのダウンロードを要求しました。保存先を確認してください。';
};
</script></html>'''

if __name__ == '__main__':
    build()
