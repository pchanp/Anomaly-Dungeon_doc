# OpenCode 3並走・設計候補の初回共通パック

**Status: Draft（実行準備資料。ゲーム仕様の採用記録ではない）**

RUN_IDは `overnight-design-pilot-v1`。A・B・Cが各15件、合計45件を設計するための配布物です。各担当は8/31・廃TSUTAYA・SEKIGAHARA・研究所を主な文脈とする候補を各3件、共通候補を3件作ります。

このパック作成時点ではOpenCodeを起動していません。候補も生成していません。以前の `overnight-design-v1/A/` の50件は入力・完成件数に含めません。

## 読む順序

1. [scope.md](scope.md) — 生成範囲、担当、15件の割り当て。
2. [invariants.md](invariants.md) — 世界観と型の境界。
3. [source-conflicts.md](source-conflicts.md) — 既存文書の記述差。
4. [effect-contract.md](effect-contract.md) と [components.json](components.json) — 記述語彙、実装状況の留保。
5. [candidate-format.md](candidate-format.md) — JSONの項目とHTML図の方針。
6. [ownership.md](ownership.md) — 読み書きの境界。
7. [pilot-and-timing.md](pilot-and-timing.md) — 3件試走、時刻記録、停止と再開。
8. [review-rules.md](review-rules.md) — 自動検証と朝の内容レビュー。
9. [prompts/common.md](prompts/common.md) と自分の [A](prompts/role-a.md) / [B](prompts/role-b.md) / [C](prompts/role-c.md)。

## 配布物

| ファイル | 用途 |
| --- | --- |
| `sources.json` / `snapshots/` | 作成時の正本MDの実バイト、Status宣言、SHA-256、Git HEAD。相対MDリンクを保つため関連外のMDも同梱。必読範囲はscopeで指定。 |
| `reserved-ids.json` | 45の予約枠。予約は内容の成立や採用を保証しない。 |
| `candidate.schema.json` | 設計候補メタデータv0.1。ゲームへ読み込むランタイム定義ではない。 |
| `templates/candidate.html` / `templates/board.css` | 人間が読む候補HTMLの雛形。仕組みの図は各候補固有に描く。 |
| `templates/candidate-{a,b,c}.json` | 各担当の未記入JSON雛形。候補数には数えない。 |
| `templates/progress.json` | 開始前は日時・モデル・費用をnullに保つ記録例。 |
| `reference/01-miw.html.txt` / `reference/vis.css.txt` | 指定の視覚ブレストの原文。形式参考だけに使う。元の文章・設定・図案は流用しない。 |
| `scripts/validate.py` | Python 3標準ライブラリだけの検証器。結果を標準出力へJSONで返し、候補を修正しない。 |
| `scripts/self_test.py` | 仮データで参照・循環・スキーマ・HTML検査を確認する。設計案は作らない。 |
| `scripts/summarize_timing.py` | 各担当のevents.jsonlから実測時間と停止〜再開の空白を集計する。 |
| `pack-integrity.json` | パックの各ファイルのSHA-256。配布後の書き換えを検出する。 |

HTML雛形は直接ブラウザで開けます。プレースホルダーが残るため、完成候補としての検証には通りません。SVG例は「情報を見る」と「条件成立で共有状態が変わる」の違いを示す形式説明です。

## 検証の使い方

以下は実行方法の説明です。OpenCodeの起動・再開・停止のコマンドは未設定です。

リポジトリルートからパックの検証:

```sh
python3 work/design-brainstorm/overnight-design-pilot-v1/common-pack/scripts/validate.py --pack-only
```

担当Aの3件試走後の検証（Aの出力先が作成された後）:

```sh
python3 work/design-brainstorm/overnight-design-pilot-v1/common-pack/scripts/validate.py --role A --output work/design-brainstorm/overnight-design-pilot-v1/A --stage pilot
```

途中は `--stage progress`、15件終了時は `--stage final` を使います。B/Cはroleとoutputを変えます。朝、他担当の完成済み出力コピーも検査する場合は `--peer B=/path/to/B --peer C=/path/to/C` を追加します。入力だけを読み、他担当には書きません。

終了コードは0=機械検証を通過、1=形式・整合性エラー、2=パック／入力／実行上の問題です。`review_items` は人間の判断が必要な事項です。0でも採用可能・世界観整合済み・ブラウザ目視済みを意味しません。

時間計測のログが揃った後の集計:

```sh
python3 work/design-brainstorm/overnight-design-pilot-v1/common-pack/scripts/summarize_timing.py /path/to/A/events.jsonl /path/to/B/events.jsonl /path/to/C/events.jsonl
```

## 実行前に残る設定

Happier/OpenCodeの起動方法、選ぶモデル、各作業root、終了日時、費用・トークン上限、外側の監視・停止手段は [run-config.json](run-config.json) で未設定です。これは準備状態の雛形です。管理側がパック外の管理フォルダへコピーして実行設定を埋め、配布したパックは変更しません。試走後に本番12件へ進める判断も管理側が行います。各セッションをこのパックだけで自動的に一晩動かす機能はありません。

別worktreeと別ディレクトリは衝突を減らしますが、OSのアクセス制御にはなりません。読み取り専用配布と書き込み制限の具体的設定は実行管理の準備で確認します。

パック自体の作成・検証結果は [validation-report.md](validation-report.md) に記録します。生成担当の所要時間は、実行前なので未計測です。
