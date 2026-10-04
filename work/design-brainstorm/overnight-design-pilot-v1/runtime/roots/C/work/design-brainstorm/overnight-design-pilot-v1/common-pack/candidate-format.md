# HTMLとJSONの候補形式

**Status: Draft（schema_version: 0.1）**

候補は同じIDのHTMLとJSONを一組にする。JSONが検証・集計の元、HTMLが人間のレビュー用。両方の内容を一致させる。矛盾の補正で仕様を変えたら両方を更新する。

## HTML

指定された `work/visual-brainstorm/opencode/01-miw.html` の、根拠・仮説・図・未確定事項を同じページに収める形式を参照する。形式の原文はreferenceに保存した。内容と図案は流用しない。

雛形のsection IDは `sources`、`hypothesis`、`diagram`、`effects`、`uncertainties`、`connections`、`cost`、`role-details` を維持する。見出しは日本語。図は1つ以上のSVGで、作用・状態遷移・空間関係・選択結果を伝える。

- A: NPCの目的と反応、発生から退場まで、戦闘／非戦闘の分岐。
- B: 所持・提示・配置・使用・喪失等の違い、誰へ渡すか。
- C: 回避対象、介入点、移動や硬直、失う選択肢。

1つの汎用「入力→結果」の図へ名前を入れ替えるだけにしない。図注に「この図で分かること」「図では確定しないこと」を書く。未知のマップ構造を図で確定しない。状態名や数値は仮説として表示する。

SVGにはviewBox、role=img、aria-labelを付ける。文字を極端に小さくせず、矢印や領域の意味を文章でも説明する。JavaScriptは不要。CSSは担当rootのboard.css。外部フォント・画像・CDN・iframeは使わない。リンクによる出典URLは許可するが、ページ表示のネットワーク依存にしない。

`index.html`は完成した全候補へリンクする。試走では3件、最終では15件。未作成候補へ壊れたリンクを置かず、予約IDは未作成の文字として示す。候補内の他担当IDもpeerファイルがない間は文字とし、存在しないファイルへリンクしない。

## JSON

`candidate.schema.json`が必須項目と型を定義する。各担当の雛形はtemplates内。`【記入】`を残したものは完成候補にしない。数値や条件が未定なら空欄ではなく、未定内容・決める論点を書く。

| フィールド | 記録する内容 |
| --- | --- |
| `source_evidence` | MDのpath、節、Status宣言、根拠となる記述。Statusはsources.json掲載の宣言をそのまま使う。 |
| `design_hypothesis` / `experience` | 提案、狙う体験、具体的な判断と代償。 |
| `placement_assumption` | 既存場所・小物への作用か、配置未定か。新地図を作らない。 |
| `components` | components.jsonの記述語彙、またはproposedな新規機能。catalogは実装済み保証ではない。 |
| `effects` | effect-contract.mdの最小項目。複数Effectは分ける。 |
| `provides_traits` | 他担当が期待できる候補の性質。例は「配置を入力として受け取る」。正式コンポーネントIDではない。 |
| `refs` | 予約ID、参照の種類、必要な性質、fallback、解決状況。 |
| `unresolved_refs` | 不在・不一致のID、またはID未指定の接続要求。空想で解決しない。 |
| `conflicts` / `uncertainties` | 衝突するMDと内容、補正案・理由、未決の採用判断。矛盾なしなら配列を空にし、本文で確認範囲を記す。 |
| `worldview` | 異化対象、成立し得る理由、曖昧に残す意味、INV-01〜11の自己確認。 |
| `requires_code` / `new_logic` | 必要性、理由、新規機能。unknownは理由と調査対象を記す。 |
| `prototype_cost` | 小／中／大／不明、理由、実装工程、想定する既存部品。推定時間を捏造しない。 |
| `role_details` | A/B/C固有の記述。一般的な共通Effectへ押し込まない。 |

予約参照の `kind` は、起動データとして不可欠な `data_dependency`、ゲーム中の相互作用の `interaction_loop`、なくても候補が成立する `optional_connection`。循環は種類別に検査する。data_dependencyが不可欠でも今回の成果は実行データではないので、未解決／起動循環は採用前の停止論点として残せる。

`resolution: reserved_unresolved` のrefsは同じtarget_idをunresolved_refsにも記す。ID未指定ならunresolved_refsのtarget_idをnullにし、required_traitsと要求を残す。参照先が同じ語彙のprovides_traitsを明示しなければ検証器は未一致として報告し、自然言語上の同義は人間が確認する。

## manifest.json

```json
{
  "run_id": "overnight-design-pilot-v1",
  "role": "A",
  "candidates": [
    {"candidate_id": "ROLE-A-001", "json_file": "ROLE-A-001.json", "html_file": "ROLE-A-001.html"}
  ]
}
```

manifestは参照一覧だけを持ち、要約・Status・マップ・コストを二重管理しない。検証器が個別JSONから読み、candidate_summariesとして出力する。上記は形の例で、未作成IDを完成扱いで登録しない。
