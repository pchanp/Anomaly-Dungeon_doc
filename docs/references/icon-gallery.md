# Icon Gallery / Draw Things

**Status: Implemented（実装済み・Prototype）**

[`tools/icon-gallery/`](../../tools/icon-gallery/) は、OpenCodeの3担当がMacのDraw Things（SDXL）へ依頼したアイコン候補を、携帯から一覧・拡大確認するためのローカル補助ツールです。生成依頼・完成画像は [`work/icon-generation/`](../../work/icon-generation/) に置きます。

Python標準ライブラリで画像の自動検出とレビュー保存を行い、共通キューの生成ワーカーはDraw ThingsのHTTP APIへ1枚ずつ送信します。外出先閲覧にはCloudflare公式 `cloudflared` による一時URLを利用でき、画像・生成情報・レビューには専用のアクセスキーが必要です。

本ツールとSDXLは、導入しただけでプロジェクトの標準制作工程に採用されたことにはなりません。制作候補のレビューはゲーム仕様や正式アセット採用の判断とは分けて扱います。Roblox Studio上の構造やゲーム実装を変更しません。

起動手順、互換性、追加依存の目的・代替手段、制約、一次資料は [`tools/icon-gallery/README.md`](../../tools/icon-gallery/README.md) を正本とします。
