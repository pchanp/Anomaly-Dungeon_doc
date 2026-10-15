# Blenderによる岩材質の比較試作

**Status: Prototype: Implemented（ローカル比較ツール）／素材採用・Studio互換性はUnconfirmed（未確認）**

## 目的と位置付け

「粗い形状に写実的な表面を適用し、遠目の自然さと近景の違和感を比較する」ための試作です。作風の正式採用や標準制作工程の変更ではありません。ゲームの実プレースには反映しません。

## 再実行

リポジトリのルートで、次を順に実行します。

```sh
python3 tools/material-preview/fetch_textures.py
/Applications/Blender.app/Contents/MacOS/Blender --background --factory-startup --python-exit-code 1 --python tools/material-preview/render_rocks.py
python3 tools/material-preview/build_review.py
open work/material-preview/rock-v1/index.html
```

出力先は固定です。再実行すると同名の試作ファイルを更新します。別案を残す場合は出力フォルダを複製してから再実行してください。

## 依存・互換性・代替手段

- Blender 5.2.1 LTS：モデル、PBR材質、UV、レンダリング。外部アドオン不要。検証環境はmacOSです。
- Python 3とcurl：Poly Haven APIから1K PNGを取得。Web接続が必要です。
- Pillow：画像一覧の組み立て。既存環境のものを使用。代替としてHTMLから個々のPNGを直接参照できます。
- Poly Haven：Rock 01とRock FaceのCC0テクスチャ。モデルは外部モデルを使わず比較専用に作成します。取得元とハッシュは出力のsources.jsonに記録します。

## 比較条件と限界

同じ80三角形の岩、共通UV、固定照明、50mmカメラ、1Kの色・Normal・Roughnessで比較します。Displacement、Subdivisionは使用しません。素材の掲載実寸幅から模様密度を近似調整していますが、Smart UVの面ごとの歪みがあるため厳密な物理スケール比較ではありません。距離は16・9・5 Blender単位で、Robloxのスタッドへの換算は未確定です。

.blendは画像を内包します。Blender材質ノードをRobloxへそのまま移せることは保証しません。Studioでの見え方・メモリ・当たり判定は未検証です。

「熟考準備完了」は画像、設定、出典、編集可能なモデルが揃った状態を指し、素材の採用を意味しません。

## 関連資料

- [アセット制作パイプライン（草案）](../production/asset-pipeline.md)
- [Blender](blender.md)
- https://polyhaven.com/a/rock_01
- https://polyhaven.com/a/rock_face
- https://polyhaven.com/license

## 2026-10-13：Studio試作確認

**Status: Prototype: Implemented（Editモードの比較配置）／見た目・FBX Importer・Play動作はUnconfirmed（未確認）**

プレース `99417611378273`（異変のダンジョン）の `Workspace.RockMaterialPreview` に、2つのMeshPartと比較用床・照明を追加しました。既存AnomalyDungeonモデル、生成器、Lightingは変更していません。

- FBXは `work/material-preview/rock-v1/export/` に出力済み。UI接続がtimeoutReached / cgWindowNotFoundで失敗したため、FBX Importerを操作できていません。
- 代替としてBlenderの42頂点・80三角形・UV・面法線をEditableMeshへ転送してMeshPartを作りました。FBXの取り込み成功とは扱いません。
- 両方ともAnchored=true、CanCollide=true、CanTouch=false、CollisionFidelity=Hull。上からのレイが両方の岩に当たることを確認しました。キャラクターによる歩行・登坂テストは未実施です。
- 1KのColor・Normal・Roughnessは画像としてRobloxへアップロードしてSurfaceAppearanceへ設定済み。元資料の試作用模様倍率をUVに反映しています。
- 画面キャプチャを2回試しましたが、空のビューポート画像が返りました。視覚的な適合・画像の審査後表示は未確認です。
- MeshContentはEditableMeshオブジェクト参照であり、通常のアップロード済みMeshIdではありません。保存・再読み込み・公開後の保持は未検証です。本番採用には通常のFBX Importerで取り込み直してください。プレースは公開していません。
- 再作成用データとLuauはexport/geometry.json、export/studio-preview.luauに保存。モデル名が既存ならスクリプトは停止します。

| 素材 | ColorMap | NormalMap | RoughnessMap |
| --- | --- | --- | --- |
| Rock 01 | 72612432842552 | 85459749328246 | 110732260764829 |
| Rock Face | 124308878227854 | 99062921522252 | 76290648527047 |
