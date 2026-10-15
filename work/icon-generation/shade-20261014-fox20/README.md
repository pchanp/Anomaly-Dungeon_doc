# SHADE 20枚 — フォックス横Bの視覚イメージ

**Status: Draft（20枚生成・取得確認済み、意匠は選別待ち）**

ユーザーは、ABCへの指示をゲームのスキル説明からビジュアルイメージへ変更し、英語で伝えることを指定した。ユーザーへの進捗・結果のサマリは日本語で報告する。対象はSHADEの追加20枚。視覚の基準は、スマブラのフォックスの横B（Fox Illusion）。

英語の指示は [`brief.en.md`](brief.en.md)。前傾した横向きの突進、同じ姿勢の青白い残像、後方へ水平に伸びる光を主題とする。Aは7案、Bは7案、Cは6案を作る。スキルのダメージ・Stun・ランク等を画像プロンプトへ入れない。

作品候補の比較であり、SHADEの仕様・ロア・正式衣装・System IDを変更しない。過去の5枚は保持し、今回の20枚と混同しない。

参考画像は `references/fox-illusion-reference.jpg`。出典URLは英語指示に記録する。参照用ファイルはGit対象外で、生成画像や正式アセットではない。

## 実行記録

OpenCodeのHappier ACP実行はA/B/Cとも完了。実際に観測したモデルはA/Bが `opencode/longcat-2.5-preview-free`、Cが `opencode/big-pickle`。いずれもプロバイダ一覧の料金が0であることを確認した。要求欄は3担当ともLongCatだったが、Cの応答はBig Pickleだったため、要求値と実際の値を分けて [`model-verification.json`](model-verification.json) に記録する。

原文は `prompts-A.json`（7案）、`prompts-B.json`（7案）、`prompts-C.json`（6案）。C06の `shadow creature` は、共通ビジュアルの人型を保つため、実際の依頼では `shadow humanoid` に正規化した。変更は [`batch.json`](batch.json) に記録し、OpenCodeの原文は保持する。

生成はA/B/Cの順に交互投入し、合計20枚だけを共通ワーカーで1枚ずつ処理する。条件はSDXL Base、1024×1024、16 Steps、CFG 5、DPM++ 2M AYS、CLIP Skip 1。CLIP Skipを依頼で明示できるようにローカルツールを更新し、境界・並行キュー・互換API等の11テストは成功した。

生成条件とSeed、ジョブID、出力先は [`batch.json`](batch.json) に保存する。ギャラリーで `Fox20` を検索すると今回の追加20枚を分離できる。Macはワーカー処理中のアイドルスリープを抑止し、処理終了時に解除する。

## 生成途中の構図調整

最初の8枚では、青い発光は出たが、低い水平姿勢・独立した青い残像が弱く、直立・斜めの人型、筋肉・顔の詳細が出現した。8枚の保存完了後にGPUワーカーを画像の境界で止め、未生成の12件だけを調整した。合計の依頼件数20件と、保存済みの8枚は保持している。

修正の指示は [`revision-brief.en.md`](revision-brief.en.md)。ABCの無料モデルから4案ずつ取得し、`revised-prompts-A.json`、`revised-prompts-B.json`、`revised-prompts-C.json` に原文を保存した。出力のlabelが文字通り `English` だったため、実際の依頼には案番号と英語の構図ラベルを付け直した。画像プロンプト本文は変更していない。

参考画像の縦横比を保って1024×576へ縮小し、上下に暗色を足した1024×1024のPNGをimg2imgへ送る。後半12枚は16 Steps・CFG 5・CLIP Skip 1、denoising strengthは0.50〜0.65。初期画像のSHA256、各案の強度、変更前後の依頼は `batch.json` に記録する。新しい経路と待機中の修正、参照ファイルの境界を含む13テストが成功した。

参考画像を使う生成では、ポーズと青い残像に加え、元の衣装や背景が残る場合がある。これらは候補画像の生成結果であり、SHADEの衣装・舞台・キャラクターとして採用しない。

## 完了確認

- A: 7枚 / B: 7枚 / C: 6枚、計20枚を保存した。前半8枚はtxt2img、後半12枚はimg2img。
- 20ジョブすべて `done`。PNGはすべて1024×1024で、20枚のSHA256は互いに異なる。
- PNG内部のメタデータで、モデル・Seed・Steps・CFG・Sampler・CLIP Skip・正負のプロンプト・img2img強度が実際の依頼と一致することを確認した。
- 今回20枚のtitle・prompt・negative_prompt・notesは英語。ABC用の作業指示にも、英語のビジュアル説明と日本語のユーザー向けサマリという方針を残した。
- 外部HTTPSギャラリーに今回の20枚があり、認証後に元画像20枚を取得し、ローカルファイルと同じSHA256であることを確認した。既存5枚は保持している。
- 検証の詳細は [`generation-verification.json`](generation-verification.json)。実機iPhone・携帯回線での確認は未実施。

画像は比較用の候補。前半には直立寄りの姿勢・弱い残像、後半には参考画像由来の衣装・背景・上下の余白が残る。生成成功を、そのまま正式なアイコン採用やビジュアル完成とは扱わない。
