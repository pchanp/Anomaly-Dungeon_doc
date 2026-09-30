# Anomaly Dungeon UI Layout Editor

2D UIレイアウトを YAML で定義し、ブラウザ上でドラッグして調整するための Prototype エディタです。

このツールが，解决了したい問題は1つです。

> **LLM が作った UI 部品定義（YAML）を読み込み、人間がブラウザ上で配置を調整して、また YAML に戻す。**

画像エディタのように1から UI を描くための道具ではありません。PowerPoint や福笑いのように、配置された部品を動かして整えることが主目的です。

`Layout Definition`（YAML）と `Editor UI`（React）は完全に分離されています。React コンポーネントの中に座標をハードコードせず、YAML が唯一のデータソースです。これにより将来的に

```text
Layout Definition
      ├── Web Preview        (このツール)
      ├── Roblox UI Generator (未着手)
      └── Documentation / MD   (未着手)
```

へ分岐できます。

## 起動方法

```bash
cd tools/ui-layout-editor
npm install
npm run dev
```

表示されたURLをブラウザで開きます。起動時にサンプルレイアウト（`samples/inventory.yaml`）が読み込まれます。

### その他のスクリプト

| コマンド | 内容 |
| --- | --- |
| `npm run dev` | 開発サーバー |
| `npm run build` | 型チェック + 本番ビルド（`dist/`） |
| `npm run preview` | ビルド結果の確認 |
| `npm run typecheck` | 型チェックのみ |
| `npm run test` | 単体テスト + 描画スモークテスト |

`npm` 以外でも動きます。`pnpm install && pnpm run dev` でも同じです。

依存の固定は `pnpm-lock.yaml` で行っています。検証は pnpm で実施しましたが、`scripts` は npm 互換で書いてあるため `npm install` でもそのまま動きます。

## YAMLフォーマット

```yaml
version: 1
screen:
  id: hud
  name: Anomaly Dungeon HUD
  width: 1920
  height: 1080
components:
  - id: slot_01
    type: slot
    x: 440
    y: 800
    z: 20
    width: 96
    height: 96
    texture:
      normal: assets/slot_normal.svg
      selected: assets/slot_selected.svg
    properties:
      selectable: true
      show_count: true
      show_rarity: true
```

### Component

| キー | 必須 | 内容 |
| --- | --- | --- |
| `id` | ○ | 一意な識別子。ゲーム側が依存するシステムIDであり、変更は別のキーへ分離してください |
| `type` | ○ | 種別。`panel` / `group` / `slot` / `text` / `image` / `button` / `gauge` / `minimap` / `radio` |
| `x` `y` | ○ | 画面上の座標。原点は左上 |
| `z` | ○ | 前後関係。大きいほど手前。同じ値なら定義順 |
| `width` `height` | ○ | サイズ |
| `texture` | | 単一パス、または状態ごとのパス、または `null` |
| `properties` | | 自由なキー/値。`string` / `number` / `boolean` |

座標は常に `screen.width` × `screen.height` の仮想解像度です。ブラウザで縮小表示しても内部座標は変わりません。

### 未知の type と未知のキー

この Prototype は、`type: anomaly_effect` のような未知の種別を読み込んでもデータを壊しません。キャンバスでは `Unknown: anomaly_effect` のプレースホルダーとして表示し、Save で元の `type` を維持します。

コンポーネントの未知のキーと、YAML ルート／`screen` の未知のキーも `extra` に保持して書き戻します。**保存のたびに理解できない情報が失われることはありません。**

### 読み込み時エラー

不正な YAML を読み込んでもアプリは停止しません。エラーと警告を画面上部に表示し、可能な範囲で読み込みます。

- `id` の重複、必須キーの欠落、`x/y/z` の非数値などはエラーとして報告し、その項目を読み飛ばします
- `"24"` のような数値文字列は数値として読み込み、警告を出します
- `properties` のネスト構造は JSON 文字列として保持し、警告を出します

## 操作方法

### 共通

3つの編集口（キャンバスのドラッグ、Inspector、Table）はすべて同じ状態を更新するため、内容が食い違いません。

### キャンバス

| 操作 | マウス | タッチ |
| --- | --- | --- |
| 選択 | クリック | タップ |
| 移動 | ドラッグ | ドラッグ |
| リサイズ | ハンドル（8方向）をドラッグ | 同左 |
| パン | 空 余白のドラッグ／中ボタン／`Space` + ドラッグ | 1本指の空余白ドラッグ |
| ズーム | ホイール | ピンチ |
| 選択解除 | 空余白をクリック | 同左 |

選択中のコンポーネントは他コンポーネントより常に前面へ持ち上げられるので、隠れていても掴めます。タッチ端末では 44px 未満のコンポーネントに余分なタップ領域を割り当て、選択ハンドルも大きくします。

### Snap と Grid

Toolbar の Grid / Snap は ON/OFF を切り替えます。Grid Size は 8 / 16 / 32。Snap が ON のとき、移動・リサイズ・Add・Duplicate がグリッドへ吸着します（`x = 417` → `416`）。

### Zoom / Pan

Zoom は 25% / 50% / 75% / 100% / 150% / 200% に加え、ホイール・ピンチで連続変更できます。`Fit` は全体を表示します。ホイールとピンチは、カーソル／ピンチ中心の下のレイアウト座標が動かないように補正します。

### Inspector

選択中のコンポーネントの ID / Type / Position / Size / Texture / Properties を編集します。

- **ID** を変えると、Component List や Table の選択状態も追従します。重複IDは拒否されます
- **Type** は登録済み種別のドロップダウンです。`custom…` を選ぶと文字列入力が開き、新しい種別を定義できます
- **Properties** は固定フォームではなく、YAML に実際に含まれるキーがそのまま行として表示されます。string / number / boolean を切り替えられ、行の追加と削除ができます

### Table Mode

全コンポーネントを表形式で一覧します。ID / Type / X / Y / Z / W / H はセルを直接編集できます。ID / Type / Z ヘッダでソートし、Search（id と type）・Type・Z 範囲でフィルタできます。Properties は Inspector 側での編集になります。

### Add / Delete / Duplicate

- **+ Add** は画面中央に `new_component` を追加し、自動的に選択します
- **Duplicate** は `<id>_copy` を作り、若干ずらした位置へ置きます。重複IDは自動で避けます
- **Delete** は選択中のコンポーネントを削除します。確認ダイアログが出ます

### Undo / Redo

移動・リサイズ・Inspector変更・Table編集・Add・Delete・Duplicate・ID変更が対象です。

- `Ctrl/Cmd + Z` … Undo
- `Ctrl/Cmd + Shift + Z` … Redo
- `Ctrl/Cmd + Y` … Redo
- `Ctrl/Cmd + S` … Save

連続操作（ドラッグ、リサイズ）は指／マウスを離した時点で1回だけ記録されるため、**1回のドラッグが Undo 1回**になります。履歴はスナップショット方式で 100 段まで保持します。

## Load / Save

- **Open** … ローカルの `.yaml` / `.yml` を開きます
- **Save** … 現在の Layout Definition を YAML としてダウンロードします

バックエンド、サーバー、データベース、認証はありません。すべてブラウザ内で完結します。

## ID規約

`id` と `type` はコードとジェネレータが依存するシステムIDです。画面に出るラベルは日本語や英語の文章にして構いませんが、IDは変更するとゲーム側との整合が壊れます。IDを変える場合は、別のキー（`properties` など）へ分離してください。

## 現在の制約

- **画像はローカルパスで永続化できません。** ブラウザの制約で、アップロードした画像は data URL として Layout Definition 内に埋め込まれます。そのままだと YAML が大きくなるため、検証用の画像として `public/assets/*.svg` を同梱し、ファイルパスを指定する形を推奨します
- **複数選択はありません。** Prototype では単一選択です
- **矢印キーでの nudge はありません。** 移動はドラッグ、または Snap 付きの数値入力で行います
- **`properties` はネスト非対応です。** ネストした値は JSON 文字列として保持し、警告します
- **アニメーション、3D、CSSデザイン、Auto Layout、Figma連携、マルチユーザー編集は未実装です**
- **Snapping はグリッド固定です。** 任意間隔のスナップポイントやガイド線は未実装
- **テクスチャは `normal` など type が指定する状態を1枚表示します。** 状態の切り替えアニメーションは未実装
- Roblox Studio との直接連携、Roblox Lua の自動生成、GitHub API 連携は未実装です
- **実機iPhone Safari は未確認です。** 横画面・`pointer: coarse` のエミュレーションで操作は確認済みですが、実機でのピンチ反応は未検証です
- **`Open` / `Save` はブラウザ上で未操作です。** ファイル選択ダイアログ経由の読み込みと、ダウンロードしたYAMLの再読み込みは未確認です

## 検証状況

マウスとマルチタッチの操作は、Chrome の DevTools プロトコルに実入力を送って確認しています。記録と欠陥の内容は [`docs/references/ui-layout-editor.md`](../../docs/references/ui-layout-editor.md) の「ブラウザ実機検証」を参照してください。

## ファイル構成

```text
tools/ui-layout-editor/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── index.html
├── public/assets/          プレースホルダ画像
├── samples/inventory.yaml  サンプル Layout Definition（唯一の正本）
├── src/
│   ├── main.tsx
│   ├── App.tsx             状態と全編集口の結線
│   ├── model/
│   │   ├── layout.ts       データモデル（Layout Definition の形）
│   │   ├── component.ts    typeレジストリと描画メタデータ
│   │   └── sample.ts       samples/inventory.yaml を読み込む
│   ├── io/
│   │   ├── yaml.ts         読み書き・検証・往復安全性
│   │   └── file.ts         ローカルファイルと data URL
│   ├── editor/
│   │   ├── history.ts      Undo / Redo
│   │   ├── selection.ts    選択・フィルタ・ソート
│   │   ├── snap.ts         Snap 規則
│   │   ├── transform.ts    移動・リサイズ・描画順
│   │   └── view.ts         ペインとビューモードの連動
│   ├── components/         Canvas / Inspector / Table / List / Toolbar など
│   └── styles/editor.css   エディタ本体の見た目
└── README.md
```

`model/` `io/` `editor/` は副作用のない純ロジックで、`*.test.ts` で単体テストしています。UI を持つ `components/` は、全体の描画が壊れていないことを `src/App.test.tsx` の描画スモークテストで確認します。

## 将来拡張候補

優先順です。いずれも未実装です。

1. **MD 内埋め込み** — `<!-- ui-components:start -->` と `<!-- ui-components:end -->` の間に Layout Definition を埋め込む。 Prototype のデータモデルはすでにこの前提を壊していません
2. **Roblox UI Generator** — YAML から ScreenGui / Frame を生成する。上の `Layout Definition` 分岐に対応
3. **複数選択と一括移動**
4. **スナップポイントとガイド線**（画面端、中央、他コンポーネントとの整列）
5. **アセットの切り離し** — data URL をやめて、`Layout Definition` と `assets/` を別ファイルとして配布する
6. **差分表示** — ファイル比較と版差分の可視化

## 関連資料

- [Anomaly Dungeon リポジトリのREADME](../../README.md)
- [UI レイアウト定義ツールの参考記録](../../docs/references/ui-layout-editor.md)
