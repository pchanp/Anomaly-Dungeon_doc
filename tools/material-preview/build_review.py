"""比較画像とブラウザで開けるレビュー資料を生成。Pillowが必要。"""
import html,json,pathlib
from PIL import Image,ImageDraw
ROOT=pathlib.Path(__file__).resolve().parents[2];OUT=ROOT/'work/material-preview/rock-v1'
canvas=Image.new('RGB',(1600,880),'#182025');draw=ImageDraw.Draw(canvas)
for row,asset in enumerate(['rock_01','rock_face']):
 for col,label in enumerate(['far','mid','near']):
  im=Image.open(OUT/'renders'/f'{asset}_{label}.png');im.thumbnail((520,390))
  x=col*530+5;y=row*440+40
  canvas.paste(im,(x,y));draw.text((x+10,y-25),f'{asset} / {label}',fill='white')
canvas.save(OUT/'comparison.jpg')
settings=json.loads((OUT/'settings.json').read_text())
parts=['<!doctype html><html lang="ja"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>岩2素材の比較 — 熟考準備</title><style>body{margin:32px;background:#182025;color:#e8ecef;font-family:system-ui;line-height:1.8}section{margin:32px 0}.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}img{width:100%}a{color:#9cd8ff}pre{white-space:pre-wrap}button{padding:8px} @media(max-width:800px){.grid{grid-template-columns:1fr}}</style><h1>岩2素材の比較</h1><p>Prototype: Implemented（Blender比較試作）／素材未採用・Studio未確認</p><p>同じ80三角形の岩、照明、50mmカメラ。距離のみ16・9・5 Blender単位へ変更。1Kの色・Normal・Roughnessを使用し、Displacementは使用しない。</p><p>評価する点：遠目の自然さ／近景の輪郭と表面の食い違い／UVの継ぎ目／模様の大きさ。形状は比較用に新規作成したもので、8/31の本番アセットではない。</p>']
for asset in ['rock_01','rock_face']:
 parts.append(f'<section><h2>{asset}</h2><p><a href="https://polyhaven.com/a/{asset}">配布元 https://polyhaven.com/a/{asset}</a> / <a href="{asset}.blend">Blenderファイル</a></p><div class="grid">')
 for label,title in [('far','遠景・16単位'),('mid','中景・9単位'),('near','近景・5単位')]:parts.append(f'<div><h3>{title}</h3><a href="renders/{asset}_{label}.png"><img src="renders/{asset}_{label}.png" alt="{asset} {title}"></a></div>')
 parts.append('</div></section>')
parts.append('<h2>再現設定</h2><pre>'+html.escape(json.dumps(settings,ensure_ascii=False,indent=2))+'</pre><p>出典・ファイルURL・SHA256：<a href="sources.json">sources.json</a>。CC0：https://polyhaven.com/license</p><p>熟考準備完了：比較画像・設定・編集可能なモデルを揃えた状態。採用判断・ゲームへの取り込みは未実施。</p></html>')
(OUT/'index.html').write_text(''.join(parts))
print(OUT/'index.html')
