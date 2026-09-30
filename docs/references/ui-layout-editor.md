# UI Layout Editor

**Status: Implemented（実装済み・Prototype）**

## 位置付け

[`tools/ui-layout-editor/`](../../tools/ui-layout-editor/) に置いた、Anomaly Dungeon の2D UIレイアウトを YAML で定義するためのローカルWebエディタです。

このツールはゲーム制作の標準工程の一部ではありません。UIレイアウトの**設計情報**を作る場所であり、実行時のUI.Frameを生成する道具ではありません。

解決しようとしている問題は1つに絞っています。

> LLMが作ったUI部品定義（YAML）を読み込み、人間がブラウザ上でドラッグして配置を調整し、またYAMLに戻す。

## なぜこの分離が必要か

`Layout Definition`（YAML）と `Editor UI`（React）を分離してあります。Reactコンポーネント内に座標をハードコードせず、YAMLが唯一のデータソースです。これにより次のいずれにも分岐できます。

```text
Layout Definition
      ├── Web Preview
      ├── Roblox UI Generator
      └── Documentation / MD
```

いずれも未実装ですが、データモデルはこの前提を壊していません。特にMD埋め込み（`<!-- ui-components:start -->` と `<!-- ui-components:end -->` の間にYAMLを置く構成）は、往復安全性を担保している関係で将来に拡張できます。

## 記録する情報

- 起動手順と利用可能なスクリプト
- YAMLフォーマットとComponent Schema
- 現在の制約（画像のパス永続化、複数選択、propertiesのネスト非対応など）
- 将来拡張候補の優先順位

これらは [`tools/ui-layout-editor/README.md`](../../tools/ui-layout-editor/README.md) を正本とします。このファイルは位置付けとリポジトリ内での扱いだけを記録します。

## ID規約との関係

Layout Definition の `id` と `type` は、コードとジェネレータが依存するシステムIDとして扱う。ゲーム内で表示するラベルは別の値とする。

リポジトリの「システムIDとゲーム内表示名を混同しない」という方針を、UI設計情報の側にもそのまま適用している。

## ブラウザ実機検証

Playwright や Selenium は使わず、Chrome の DevTools プロトコル（CDP）に直接接続して、`Input.dispatchMouseEvent` / `Input.dispatchTouchEvent` / `Emulation.setDeviceMetricsOverride` で実入力を送って確認した。ヘッドレス Chrome でもマウスとマルチタッチのイベント経路は実機と同じものを通る。

2026-09-30 の検証結果。

| 対象 | 結果 |
| --- | --- |
| マウスドラッグ、8px Snap、Undo / Redo | 仕様どおり |
| リサイズハンドル、リサイズ後の Undo | 仕様どおり |
| Z順（DOM順とz順の一致、同Zなら定義順） | 仕様どおり |
| ホイールズーム、カーソル下の固定 | 仕様どおり |
| パン（空余白ドラッグ、中ボタン、1本指、2本指） | 仕様どおり |
| タップ選択、タッチドラッグ | 仕様どおり |
| ピンチズーム（拡大・縮小の両方） | 仕様どおり |
| 横画面でのペインタブ、Inspector / Table 切替 | 仕様どおり |
| 縦画面時の回転案内 | 仕様どおり |
| タッチ目標サイズ（Inspector入力欄 44px、フィルタ 44px） | 仕様どおり |
| コンソールエラー | なし |

この検証で欠陥を1件発見し修正した。**モバイルの「Table」タブは `pane` だけを更新し `mode` を更新しないため、Tableペインがマウントされないまま空欄になっていた。** 狭幅画面ではCSSでペインを出し分けるため、選択されたペインに対応するDOMが存在しないと何も表示されない。`pane` と `mode` を同時に更新する形へ直し、`editor/view.ts` として副作用のないロジックに切り出して単体テストで固定した（`editor/view.test.ts`、7件）。

あわせて `index.html` にfaviconを追加し、ブラウザが `/favicon.ico` を要求して404となるconsoleエラーを解消した。

### まだ確認していないこと

- **実機iPhone Safari は未確認。** 上記は横画面 852x393 CSS px・`pointer: coarse` のエミュレーションである。実機でのピンチの反応やSafari側のgesture処理は未検証。確認手順は [`tools/ui-layout-editor/README.md`](../../tools/ui-layout-editor/README.md) の「実機iPhone Safari 確認手順」に書き起こしてある
- **ファイルオープンと保存（ダウンロード）は未操作。** ブラウザのファイル選択ダイアログをCDPから安定して扱えないため `Open` / `Save` は未確認
- 複数人編集は対象外（仕様で除外）

## 未確定・未実装

- Roblox UI Generator（YAMLからScreenGuiを生成する）
- MD内埋め込みの実装
- アセットをLayout Definitionから切り離した配布
- 複数選択、アンカー制約、Auto Layout
