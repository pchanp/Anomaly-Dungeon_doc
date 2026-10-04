# ROLE=C handoff — overnight-design-pilot-v1 試走（PILOT_ONLY）

**Status: Draft（実行側の記録。ゲーム仕様の採用記録ではない）**

RUN_ID: `overnight-design-pilot-v1` ／ 担当: C（スキル）／ モード: `PILOT_ONLY`
出力先: `work/design-brainstorm/overnight-design-pilot-v1/C/`

## 1. 件数と分類

| 候補ID | 主対象マップ | 分類 | 系統 | rank | design_status | review_status |
| --- | --- | --- | --- | --- | --- | --- |
| ROLE-C-001 巻き戻し地点 | 8/31 | マップ固有 | アクション | 1（候補値） | Idea | unreviewed |
| ROLE-C-004 試聴の記録 | 廃TSUTAYA | マップ固有 | 探索 | null（理由あり） | Idea | unreviewed |
| ROLE-C-013 息を揃える窓 | 全マップ共通 | 全マップ共通 | 補助 | null（理由あり） | Idea | unreviewed |

完成 3件（001 / 004 / 013）。未作成 12件: 002、003、005、006、007、008、009、010、011、012、014、015。
`index.html`、`manifest.json`、`board.css`、`progress.json`、`events.jsonl`、本ファイルは件数に数えていない。

候補間の判断は意図的に分けている。001は「時間を位置の参照先に変える」、004は「視聴の終了時点を情報保持の判断に変える」、013は「連携に音と受付制限を加える」。名称や数値、マップだけが違う複製ではない。

## 2. 表示確認

**未確認。** `progress.json` の `visual_check.status` は `unavailable`、`checked_ids` は空である。
理由: ROLE=C の担当指示で Bash、task、MCP、外部ディレクトリ、外部調査、Git、Studio を使用禁止とされたため、ブラウザを開く手段がなかった。日時の取得も Bash 禁止のため行っていない。

- 各 HTML は必須 section（sources / hypothesis / diagram / effects / uncertainties / connections / cost / role-details）を持ち、候補固有のインライン SVG を1つ以上持つ。SVG は viewBox、role="img"、aria-label を付与済み。外部スクリプト、フォント、CDN、iframe は使っていない。
- **要管理側の確認:** 3つの HTML をブラウザで開き、SVG が切れず読めるか、文字が潰れていないか、`board.css` が適用されているかを確認してほしい。`<link rel="stylesheet" href="board.css">` は自分の出力先にコピーした `board.css` を参照する。
- `index.html` から3件へのローカルリンクと、候補間のリンク（001→004、004→001/013、013→004）はすべて自分の出力先内の実在ファイルを指す。存在しないファイルへのリンクは置いていない。

## 3. 検証の状態

**ROLE=C では Python 検証を実行していない。** 担当指示で Bash と Python 検証が禁止され、共通パック README が求める開始時の `pack-only` 検証も担当では走らせられていない。

- `pack-integrity.json` のファイル一覧と `sources.json` の掲載パスは Read で目視しただけで、SHA-256 の再計算はしていない。**ハッシュ不一致を検出できていない。**
- `scripts/validate.py` は読み根部まで読んでおり、スキーマ必須項目、候補IDパターン、HTML section、SVG 属性、`manifest.json` の形、`progress.json` の state、`events.jsonl` の行形式を理解した上で記載を合わせた。**機械検証の通過は保証していない。**

**管理側に依頼する検証:**

```sh
python3 work/design-brainstorm/overnight-design-pilot-v1/common-pack/scripts/validate.py --pack-only
python3 work/design-brainstorm/overnight-design-pilot-v1/common-pack/scripts/validate.py --role C --output work/design-brainstorm/overnight-design-pilot-v1/C --stage pilot
```

失敗した場合は候補側を直すのが担当の仕事だが、今回は書き直す手段が Bash を通さないため、編集は管理側から也可能。

## 4. 参照（refs / unresolved_refs）

| 参照先 | 種類 | 解決状況 | 備考 |
| --- | --- | --- | --- |
| ROLE-A-002 | interaction_loop | reserved_unresolved | 8/31のフェーズ遷移時刻と遷移結果の共有提示。フォールバックは本候補がギミック非依存で成立する旨。 |
| ROLE-A-004 | interaction_loop | reserved_unresolved | 試聴機と棚の操作がServer側の操作事実として記録されること。フォールバックは試聴機とArchive Selection UIの既存挙動のみ。 |
| ROLE-A-013 | optional_connection | reserved_unresolved | 同時成立条件の個人提示と共有提示の分離。フォールバックは記録を個人単位の事実としてのみ保持。 |
| ROLE-B-004 | optional_connection | reserved_unresolved | 固有品と博士Questの直接報酬の区別。フォールバックは物品を生成せず、項目名と選択結果のみを扱う。 |
| ROLE-C-001 | optional_connection | draft_available | required_traits「個人単位の連携入力受付窓を開ける」は ROLE-C-001 の provides_traits に一致。 |
| ROLE-C-004 | optional_connection | draft_available | required_traits「試聴中は移動、通常攻撃、他のスキル発動を受け付けない」は ROLE-C-004 の provides_traits に一致。 |

未解決参照の内訳は ROLE-C-001 が 2件（うち ID 未指定 1件）、ROLE-C-004 が 3件（うち ID 未指定 2件）、ROLE-C-013 が 3件（うち ID 未指定 2件）。ID 未指定のものは「どの予約 ID に対応するのかが、この段階では不明」という意味で、target_id を null にして要求だけを記録した。`adoption_blocker` はすべて false で、`data_dependency` の参照は1件も行っていない（起動データ依存を主張していないため）。

**`peer-snapshots` は配布されていない。** A と B の候補本文は読んでおらず、実現を仮定していない。他担当へ伝える必要のある要求は、各候補の `refs.required_traits` と `unresolved_refs` にだけ記載した。

## 5. 世界観の留保（保留した意味）

- **001:** 前相の位置を参照できるのは、地形が記憶の結果なのか、時計が何かを戻した結果なのか、それとも別の理由なのか。8/32で地図が再構築された後に何が残るかも未確定。
- **004:** 残った項目が店内側の記録なのか、本人が記憶として持っているだけなのか。他者に口頭で説明しても記録が増えないのか。
- **013:** 窓を開いたときに何かが応じるのか、応じないのか。応じた場合もどのアノマリーが何としてきたかは語らない。

3件とも INV-01（ルールは明確、意味は曖昧）を守るため、操作と終了条件は具体的に書き、原因と起源は仮説として留めた。INV-03（起源・正体・博士の真意を断定しない）に従い、博士、组织史、Anomalyの正体は書いていない。INV-02 に従い、実在の日本の都市や実際のTSUTAYA店舗、既存作品のプロパティは流用していない。INV-06 に従い、SVG は作用関係の模式図であり、地図や建物の配置は提案していない。

**型の一致（INV-04）:** 3件とも Player Anomaly の専用攻撃・固有帰還には触れていない。Heal で全 Anomaly Entity を鎮静できる、SHADE で全 Entity を検知不能にできる、cure で Exposure を消せる、という一般化は一切書いていない。001 は Mad Stomper のHeal Field との**順序が未定義**であることを記録しただけで、鎮静の経路を用意していない。013 は窓の開始をSound Interaction の**入力として記録する**だけで、どのアノマリーが応じるかは個別資料の定義に委ねると明記した。

## 6. requires_code と試作コスト

3件とも `requires_code: true`。3件とも新規実装の経路が current-implementation.md に存在しないためで、true は必要性の記録であってコード生成の許可ではない。

| 候補 | 必要な新規経路 | prototype_cost | 帯の根拠 |
| --- | --- | --- | --- |
| 001 | 8/31フェーズ遷移の購読点／個人のアンカー記録と1回消費／記録位置へのテレポートと着地検証／遷移後の発動受付封じ | 中 | フェーズ進行、地形、Lighting、Run Lifetime、帰還面は既存実装で流用可。既存部品に無い4点で、検証ログが要る。 |
| 004 | 個人試聴セッションの開始終了通知と早期終了の許可／試聴中の操作受付封じ／未閲覧1件の本人限定記録と単回消費 | 中 | 試聴機、棚、Archive Selection UI、PreviewDuration、共有BGM の分離はすべて既存。音響の伝播にもアノマリーにも触れず調整は UI と個人状態に閉じるが、新しいスキル発動経路と本人属性の保存先が要る。 |
| 013 | 連携窓の状態と指名先の検証／窓の開通中の入力受付切替／窓の開始終了のSound Interaction記録 | 中 | RunState、Player Attribute、既存3スキルは流用可。窓と記録は新規。複数人競合は1人セッションでは検証できず未確認を含む。 |

`prototype_cost.band` はゲーム内試作の見積もりであり、候補生成にかかった時間とは別の数値である。所要時間は次項のとおり未計測。

## 7. 所要時間と実測できなかったこと

- `progress.json` の `started_at` と `ended_at` は null。`events.jsonl` の全行の `at` も null。各行に理由ノートを記し、検証器が「時刻不明の行には理由が必要」を満たすようにした。
- 読み込み時間、初回3件の経過、3件バッチの生成／検証／修正時間、総経過、セッション内待機、停止〜再開の空白は**すべて未計測**。推測で埋めていない。集計は `scripts/summarize_timing.py` で行うが、実行は管理側。
- `usage` は input_tokens、output_tokens、cost、currency、measurement_source のすべて null。トークンと費用は管理サービスが実測値を返すまで不明であり、自己申告の数値は使っていない。
- `execution.model` には提示された設定 `opencode/space-bunny-free` のみを記録。プロバイダとセッションIDは確認できず null。
- 再試行: JSON と HTML の書き出し後、日本語として成立しない語が複数箇所に混入したため、001 を2回、004 を2回、013 を2回、該当箇所を直接編集で書き直した。同じファイルへの連続3回目の失敗は起きていない。うち001 は JSON の書き直し時にHTMLから抽出した文字列と食い違いが生じたため、JSON 全体を1回書き直した。**修正にかけた時間も未計測。**

## 8. 停止理由

PILOT_ONLY の指示に従い、001・004・013 の3件で停止し `progress.state` を `awaiting_pilot_review` にした。本番12件へは進んでおらず、停止は外側の強制ではなく指示に基づく自主的な区切りである。予算・期限・同一エラー3回による停止ではない。

## 9. 朝に採用判断を要する論点

判断はしない。論点のみ列挙する。

1. **001 のランク1採用。** skill-build.md は「各系統のランク1はまだ3案に達していない」と記す。001 をアクション系ランク1の3件目に置く場合、ランク1の3解放＋レベル3条件をどのスキルで満たすかが必要になり、ランク2（バックステップ等）の解放可能性が変わる。候補の `conflicts` 1件目に記載した。
2. **001 と current-implementation.md の関係。** 新しいスキル発動とビルド取得・強化システム（未実装）のどちらに依存させるか。前者なら INV-11 が守る現行2マップ最小Runの実装範囲に影響が出る可能性がある。`conflicts` 2件目。
3. **001 の着地安全。** 8/32遷移後に Parts が衝突化する条件下で、アンカー位置が通行不能になる場合の処理（発動拒否／押し出し／落下ダメージ）が未確定。安全を保証しない設計のままでよいか、案の採用を保留するか。
4. **004 の rank。** 探索系ランク1は開錠の1案のみで系統構成が未確定のため、rank を null とした。1か2のどちらに置くかで系統構成が変わる。
5. **004 の記録対象。** 未閲覧項目のうちどの1件を選べるか（選択式か規則か）が未実装。記録後に同じ棚を再検索できるかも未確定で、「1件だけ残す」ことの価値が成立するかが左右される。
6. **004 の個人限定性。** 記録が本人だけに見える設計としている。Recognition の保存先を個人、Party、共有で分けるという既存の認知アノマリーの論点と接続するため、個別設計に委ねるか、共通契約にするかを決める必要がある。
7. **004 の音像依存。** 004 は音の伝播に依存しない設計にしたため、音の未決定領域には触れない。ただし「試聴」を Sound Interaction として記録するかは個別判断が必要（`conflicts` 1件目）。
8. **013 の rank。** 補助系ランク1にはヒール（仮称）とcureの2案がある。rank を null とした。採否と順位は管理側の判断による。
9. **013 の相互作用。** 窓の開始をどの Interaction として記録するか、Sound 以外を併用するか。「記録した時点ですでに結果を示す」書き方をしてしまった場合の差し戻し（`conflicts` 1件目）。
10. **013 の複数人検証。** 2人が同時に窓を開いたときの競合は、1人セッションでは検証できない。PlaySolo の制約は current-implementation.md に「複数人での挙動は未確認」と明記されている。管理側が複数人で試せるか確認が必要。
11. **013 と whisper の関係。** whisper は Sound Interaction を受理する設計だが、本候補は「何も起きるとも、起きないとも書いていない」という立場である。whisper 側で窓開始を受理する場合の結果は未定義であり、必要なら個別資料側で決める必要がある。
12. **003 の仮定。** 3件とも「窓の長さは未確定」「連携できる入力は未確定」「個人記録の保持期間は未確定」と書いた。採用時に数字を決める場合、絶対値ではなく全マップ共通の相対的な長さから決めるほうが文書間の矛盾を避けやすい。判断は管理側。
13. **実在の身体技術の扱い。** `real_techniques` は3件とも空配列。外部調査ができないため Confirmed を書けず、既存の作品から技名や演出を借りて空白を埋めることもしていない。実在の身体技術を使う案を出すなら、確認できた一次資料の URL を添えて別案とする必要がある。
14. **原文の表記ゆれ。** `anomaly-interaction.md` は冒頭の Status を「ステータス: Draft」と表記しており、他の文書が使う「Status: 」（英語表記）とは先頭の表記が違う。sources.json の status_declarations にもその表記で登録されている。候補の `source_status` は sources.json の登録文言に合わせてある。原典側の表記を直すかどうかは管理側の判断で、候補側からは変更していない。

## 10. 再開手順

1. 管理側が `progress.json` と `manifest.json` を読む。`state` が `awaiting_pilot_review`、`completed_ids` が3件であることを確認する。
2. `scripts/validate.py --pack-only`、続いて `--role C --output work/design-brainstorm/overnight-design-pilot-v1/C --stage pilot` を実行する。エラーが出た箇所のみ候補側で修正する。
3. 3件の HTML をブラウザで実表示確認し、SVG と CSS が見えることを確認する。`progress.json` の `visual_check` を checked に更新できるなら、`checked_ids` に3件を入れる。
4. 管理側から `RESUME_AFTER_PILOT` の明示指示があった場合のみ、残り12件を3件ずつ（002-003、005-006、007-008、009-010、011-012、014-015 の順を推奨）作成する。6／9／12／15件で `progress.json` を更新し、15件で `--stage final` を実行する。
5. 12件を作る際は、各マップの在庫を先に確保する。C-002 と C-003（8/31）は地形とフェーズ、C-005 と C-006（廃TSUTAYA）は店内経路、C-007 から 009（SEKIGAHARA）は Idea の戦場、C-010 から 012（研究所）は元同僚 whisper と判断018、C-014 と C-015（全マップ共通）は地図非依存。003 は C-001 と同じアクション系に寄せないよう、別系統を選ぶ。C-007 から 009 は Idea のマップなので配置を確定しない。
6. 他担当のスナップショットが配布されたら、各候補の `refs` の `resolution` を `draft_available` に更新し、`unresolved_refs` の該当分を削除する。ID 未指定の要求に ID が割り当てられたら、`unresolved_refs` の target_id を埋め、`refs` へ移す。
7. 時刻が取得できるようになったら、`events.jsonl` の `at` を実測値で埋め、`progress.json` の `started_at`／`ended_at` と `usage` を管理サービスの実測値に置き換える。実測できないままなら null のまま残す。

## 11. 書き込み範囲の確認

書いたのは自分の担当フォルダ `work/design-brainstorm/overnight-design-pilot-v1/C/` のみである。共通パック、正本 `docs/`、`src/`、`tools/`、AGENTS.md、README.md、Studio、他担当の出力、以前の work は読み取り以外で変更していない。Git の操作、コミット、プッシュ、accepted 化、実装の生成は行っていない。`board.css` は共通パックの `templates/board.css` のコピーであり、元ファイルは変更していない。
