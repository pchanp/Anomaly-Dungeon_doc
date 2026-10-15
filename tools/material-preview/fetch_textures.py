"""Poly Havenの比較用1K素材を取得し、出典とハッシュを記録する。"""
import concurrent.futures, hashlib, json, pathlib, subprocess
ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / 'work/material-preview/rock-v1'
OUT.mkdir(parents=True, exist_ok=True)
(OUT / 'textures').mkdir(exist_ok=True)
jobs=[]
for asset in ['rock_01', 'rock_face']:
    raw=subprocess.check_output(['curl','--fail','--location','--silent','--show-error',f'https://api.polyhaven.com/files/{asset}'])
    data=json.loads(raw)
    (OUT / f'{asset}-files.json').write_bytes(raw)
    for kind in ['Diffuse','nor_gl','Rough']:
        url=data[kind]['1k']['png']['url']
        jobs.append((asset,kind,url))
def fetch(job):
    asset,kind,url=job
    path=OUT/'textures'/f'{asset}_{kind}.png'
    subprocess.run(['curl','--fail','--location','--silent','--show-error','--retry','2',url,'-o',str(path)],check=True)
    return dict(asset=asset,kind=kind,url=url,path=str(path.relative_to(OUT)),sha256=hashlib.sha256(path.read_bytes()).hexdigest())
with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
    files=list(pool.map(fetch,jobs))
(OUT/'sources.json').write_text(json.dumps(dict(license='CC0',license_url='https://polyhaven.com/license',assets=['https://polyhaven.com/a/rock_01','https://polyhaven.com/a/rock_face'],files=files),ensure_ascii=False,indent=2))
print('Downloaded',len(files),'maps')
