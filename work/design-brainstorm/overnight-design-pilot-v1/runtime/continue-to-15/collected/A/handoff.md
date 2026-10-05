# ROLE-A handoff — overnight-design-pilot-v1（追加15件・計30件）

**Status: Draft（担当作業の記録。採用判断・仕様確定ではない）**

今回の書き込み先は `runtime/continue-to-15/collected/A` のみです。旧root内の担当出力（`runtime/initial-only-no-deadline/roots/A/work/design-brainstorm/overnight-design-pilot-v1/A`）へは書いていません。共通パック、正本MD、src、tools、Studio、他担当は変更していません。コミット、プッシュ、実装、採用はいずれも行っていません。

001〜015のHTMLとJSONは読み取りのみで、書き換えていません。manifest、index、progress、events、handoffのみ30件へ追記更新しています。

## 1. 追加15件（016〜030）の内訳

| ID | 遊びの核 | 動詞 | category | requires_code | 試作コスト |
| --- | --- | --- | --- | --- | --- |
| ROLE-A-016 | 囮の音 — 索敵を外へ逃がす | 避ける（音で操作） | GimmickEvent | true | 中 |
| ROLE-A-017 | 仲間の合図 — 1匹の察知が枠全体に伝播 | 攻める（先頭から崩す） | MobEnemy | true | 中 |
| ROLE-A-018 | 巡回灯 — 光の内外で敵の反応が変わる | 避ける（暗がりを選ぶ） | GimmickEvent | true | 中 |
| ROLE-A-019 | 開けたままの扉 — 一度きりの通り抜け | 探す／引き返す | GimmickEvent | true | 大 |
| ROLE-A-020 | 巡回者 — 周期の崩れが合図になる | 避ける／観察 | NPC | true | 小 |
| ROLE-A-021 | 刻印の擦れ — 自分の痕跡が次の動きを決める | 探す／環境を利用 | GimmickEvent | true | 中 |
| ROLE-A-022 | 低温の通行帯 — 追うほど速く逃げられる | 避ける（間合い） | GimmickEvent | true | 中 |
| ROLE-A-023 | 消えない数 — 倒しても記録が残る | 攻める（順番） | MobEnemy | true | 小 |
| ROLE-A-024 | 開いた刹那だけ — 時間が読めない一方通行 | 探す／待つ | GimmickEvent | true | 中 |
| ROLE-A-025 | 見張り — 索敵を共有しない一匹 | 避ける／攻める | MobEnemy | true | 中 |
| ROLE-A-026 | 残った反応 — NPCの動きが痕跡として残る | 探す（痕跡） | NPC | true | 中 |
| ROLE-A-027 | 群の寄せ — 近くにいる個体が短時間だけ集まる | 攻める（一括） | MobEnemy | true | 中 |
| ROLE-A-028 | 消せない灯り — 敵の反応だけ鈍る場所 | 避ける（安全域） | GimmickEvent | true | 中 |
| ROLE-A-029 | 曲がった道標 — 通ると一度だけ向きが変わる | 探す（信じるか） | GimmickEvent | true | 小 |
| ROLE-A-030 | 残る音 — 鳴った装置がRunを通じてもう一度鳴る | 環境を利用／待つ | GimmickEvent | true | 中 |

追加15件はすべて `primary_map: 全マップ共通` / `classification: 全マップ共通` で、v0.3の予約枠と一致しています。MobEnemyは017、023、025、027の4件、GimmickEventが9件、NPCが2件です。

## 2. 追加回で扱った要件

- **ソロで成立**：Partyの同意、同時入力、受け渡しを前提にした案はありません。refsは全件空配列です。協力も書いていません。
- **イベント介入**：016（音を投入）、021（通った道を選ぶ）、027（個体を一か所へ集める）、030（二度目の音を待つ）は、プレイヤーがイベント側の状態を自分で書き換える案です。
- **敵への複数対処**：017（枠内伝播）、023（記録の積み上げ）、025（共有しない見張り）、027（一括集合）で、個体の数や向きに対して複数の対処を要求します。
- **戦闘以外の対応**：018、019、021、022、024、025、026、028、029では、交戦しない通過が成立します。回避が常に可能で、回避時に報酬は得ない形にしました。
- **発生と退場**：MobEnemy4件はすべて spawn_condition と exit_condition を明記し、Run終了で枠ごと破棄します。終端での自然退出を持つのは013のみで、今回の4件はいずれも持ちません。
- **Entityとの違い**：MobEnemy4件はすべて「通常NPCの戦闘個体でありAnomaly Entityではない」と明記し、`AnomalySpawn` の枠と判断017の同時出現数を別系統として扱うと書きました。

## 3. 001〜015との重複回避

- 013（イベント由来の湧き枠）とは、017（枠内の合図伝播）と027（個体の集合）で役割を分けました。013が「湧く／枠が戻る」、追加2件は「すでにいる個体どうしの関係」です。
- 008（補充枠）とは、023（枠の個体数と記録の数を分離）で分けました。023は補充を扱いません。
- 014（帰還者の向き）とは、020（NPC周期の崩れ）と026（反応の残留）で分けました。014は向きだけ、020と026は時間と共有という要素を持ちます。
- 015（段階の提示）とは接触なし。追加15件に進行の提示はありません。
- 003（案内役の言葉）とは、029（物の向き）で分けました。029はNPCも言葉も使いません。
- 021と030はいずれも「痕跡が残る」系ですが、021は通った道が敵の通り道になる地形変化、030は音が鳴った事実の残留で、入力も結果も別です。

同じ仕組みの名称違い、数値違い、マップ違いの候補は追加していません。

## 4. refs と未解決参照

追加15件は refs を空配列にしました。unresolved_refs は ID未指定（null）の要求のみで、adoption_blocker の高いものが各1〜2件あります。主なものは次のとおりです。

1. 音の減衰・遮蔽とモブの聴覚を実装する方針（016、030）。
2. 同じ枠に属する個体の定義と伝播の上限を決める方針（017）。
3. 通常の湧き枠と本候補の枠を分離して実装する方針（023、025、027）。
4. 常設の光源（帯・灯り）をマップと切り離して定義する方針（018、022、028）。
5. 記録や反応をどこへ表示するかを決める方針（023、026）。既存HUDへ載せるか専用表示にするかは未決です。
6. 案の「向きが変わる扉」を既存のPortalとは別の機能として実装する方針（019、024）。
7. 案内NPC（003）と道標（029）の役割を分ける方針。

BとCの候補本文は読んでいません（peer-snapshotsは配布されていないため）。相手の内容を創作していません。

## 5. 表示確認

- `visual_check.status`: **unavailable**。担当セッションはBash・外部ディレクトリ・Studio・MCP禁止のため、ブラウザを起動できず、追加15件のHTMLレイアウト、SVG描画、index.htmlの表示を実ブラウザで確認できていません。
- `validate.py --pack-only` と `--role A --output runtime/continue-to-15/collected/A --stage final` は本担当では実行していません。管理側の担当です。
- 追加15件の `source_evidence` は、sources.json の `status_declarations` と snapshot の実見出しへ1件ずつ照合済みです。path はすべて entries に存在し、source_status はすべて完全一致、section はすべて実在します。

## 6. `manifest ID invalid/outside role` について（担当側で直せない問題）

管理側から `manifest ID invalid/outside role` が12件報告されました。**これは候補の不足や記述ミスではありません。** 共通パックのID判定が 016〜030 を弾く状態になっています。担当側で再做できることはなく、パックの修正が必要です。

パックの実害を確認しました。トップレベルの `common-pack-v0.3` と runtime A 側のコピーの両方で同一です。

| 場所 | 現在の記述 | 影響 |
| --- | --- | --- |
| `common-pack-v0.3/scripts/validate.py:369` | `re.fullmatch(r'ROLE-'+role+r'-(00[1-9]\|01[0-5])',cid)` | manifest の candidate_id が016以降だと `manifest ID invalid/outside role` となり、`continue` される |
| `common-pack-v0.3/candidate.schema.json:12` | `"pattern": "^ROLE-[ABC]-(00[1-9]\|01[0-5])$"`（candidate_id） | 016以降のJSONは schema 不正になる |
| `common-pack-v0.3/candidate.schema.json:174` | `"pattern": "^ROLE-[ABC]-(00[1-9]\|01[0-5])\\.html$"`（html_file） | 016以降のHTMLファイル名も不正になる |

この正規表現が受け付けるのは 001〜015 だけです。予約（reserved-ids.json）は016〜030まで用意されており、`validate.py:404` の文言も `final requires all 30 reserved IDs`、`validate.py:237` の予約配分も全マップ共通18件です。つまり**予約とチェックだけがずれている**状態です。

報告が12件で15件ではない点については、当方では説明できません。当方の新規15件はいずれも該当するため、検証器の全走査なら `manifest and candidate file set differ`（validate.py:399-400）、`final requires all 30 reserved IDs`（:404）、`progress completed IDs differ`（:425）も同時に出るはずです。この3件が出ていないことから、報告は途中経過か一部を切り出したものと思われます。

### 不足しているファイルはない

当方の新規15件は15/15で揃っており、以下は確認済みです。

- 30件すべての `candidate_id` がファイル名と一致（`manifest/JSON ID mismatch` は出ません）。
- 30件すべての `primary_map` と `classification` が `全マップ共通` で、予約の `primary_map` と一致します。
- `category` は `GimmickEvent` / `NPC` / `MobEnemy` のみで、担当Aの許可集合内です。
- 15件すべてのHTMLに `id="hypothesis"` と `id="diagram"` があり、SVGに viewBox・role=img・aria-label があります。
- 15件すべてのJSONに必須項目（schema_version、requires_code_reason、invariants_checked、mob_contract、html_file）が揃っています。
- `manifest.json` は30件、`index.html` は30件へのリンク、`progress.json` は `state: completed` で `completed_ids` 30件です。
- `events.jsonl`、`handoff.md`、`board.css` は揃っています。

### 管理側にお願いする修正

1. `validate.py:369` の正規表現を30件まで広げる（例：`r'ROLE-'+role+r'-(00[1-9]|01[0-9]|02[0-9]|030)'`）。
2. `candidate.schema.json:12` と `:174` の pattern を同様に広げる。
3. `candidate.schema.json:421`（reference の target_id）と `:469`（unresolved の target_id）も広げること。当方の15件は refs が空、target_id は null のみなのでこれらは妨げになりませんが、016以降を指す参照を後から書いた場合に備えておく必要があります。
4. **上記を直したら `pack-integrity.json` の再生成が必須です。** `validate.py:245-253` がパック内の全ファイル集合と sha256 を `pack-integrity.json` と照合するためです。放任すると `pack hash mismatch: candidate.schema.json` が出ます。

修正すると他の担当者の出力にも影響が出るため、担当からはパックへ書き込んでいません（書き込みは `runtime/continue-to-15/collected/A` のみという指示のため）。

なお `visual_check` は unavailable のままなので、パック修正後も `review_items` に `visual_check_pending_or_unavailable` が残るのは想定内です。

## 7. 世界観の留保

- 世界の起源、アノマリーの正体、博士の真意は、追加15件のどれでも確定していません。
- NPCは所有の目的だけを持ちます（020の巡回者、026の反応を示す通常NPC）。014の見送りとは別物です。
- Player Anomalyは判断019により通常NPCとInteractionできません。020の周期、026の残留はいずれも通常のプレイヤーのみに成立する個人提示として書いています。
- 017、023、025、027のモブは通常の戦闘NPCであり、Anomaly Entityではありません。枠も判断017の同時出現数とは別枠として扱います。
- 研究所の構造、whisperの既存連鎖、元同僚の行方、装置の正体、博士の処分の真偽は、追加15件でも一切確定していません。全マップ共通の案は、特定マップの器材・NPC・Quest・Party人数を発動必須条件にしていません。
- 正式なマップ配置、建物構造、区画の割り当ては提案せず、各マップの判断に委ねています。SVGは作用関係の模式図であり、地図ではありません。
- INV-01からINV-11は自己確認として追加15件すべてのJSONに記載しています。検証器は内容の整合性を証明しません。

## 8. requires_code と試作コスト

- 追加15件とも `requires_code: true` です。理由は各JSONの `requires_code_reason` に記載しており、コード生成の許可ではありません。
- 試作コストは小3件、中11件、大1件（019）です。実時間の見積もりは出していません。

## 9. 所要時間と停止理由

- 所要時間は**未計測**です。日時取得手段が担当へ禁止されているため、events.jsonlとprogress.jsonの時刻はすべてnullです。
- モデル: opencode/space-bunny-free。provider、session_id、費用、トークンはnullです。
- 停止理由: 追加15件の作成と、manifest／index／progress／events／handoffの30件更新を終え、パック側のID判定待ちの状態です。停止要因（期限、予算、同一エラー3回）はありません。

## 10. 前回までの引き継ぎ（要点のみ）

- 前回は `source Status mismatch` 4件（002、006、008、015）と、`source section not found` 1件（004）を修正しました。`effect-components.md` の宣言は「既定規則**に**合意済み」で、助詞1文字でも不一致になります。
- 管理側の検証は担当の編集より1巡遅れて検査しているようでした（004の修正が1巡後に報告に現れました）。今回の編集も1巡遅れて反映されると推定されます。
- 1巡目と2巡目で検証パスが別の場所を指していた可能性がありましたが、15/15件として認識された後は当該パスで通っています。今回の検証は `runtime/continue-to-15/collected/A` に対して行ってください。

## 11. 文字混入の記録

追加回の作成中に、日本語の生成文へ日本語以外の言語の断片が混入しました。検出した箇所は Write で保存し直し、文言を日本語へ戻して解消しています。解消した対象は ROLE-A-016 から ROLE-A-030 の各JSONとHTMLです。残存は無いと判断していますが、grepでの目視確認を推奨します。

### 初回分（001〜015）で検出した未修正の混入

grep で全体を調べたところ、初回分に次の1箇所が残っています。当日の指示で 001〜015 は書き換えないことになっているため、**変更していません**。管理側で直すか、書き換えを指示してください。

- `ROLE-A-002.json` の `effects[0].client_presentation`：「板の nearby の1行」。` nearby ` は日本語へ戻す必要があります（例：「板のそばの1行」）。

## 12. 採用判断が必要な論点（担当からは判断しない）

1. 通常の戦闘枠（008、013、017、023、025、027）と、Anomalyの同時出現数をどの程度分離するか。
2. 個体間伝播（017）と個体間の集合（027）を、通常の敵AIのどこへ実装するか。
3. 常設の環境（018の光、022の帯、028の灯り）を、マップの静的要素として保持するか、Runtimeで生成するか。
4. 音の入力（016の囮、030の装置）を、既存の環境音（Ambience）と分けるか共有するか。
5. 記録や反応の表示先（023、026、029）を既存HUDへ載せるか、専用表示とするか。
6. 案内NPC（003）と道標（029）を併存させるか。
7. 通過型ギミック（019、024）を既存のPortal系統へ近づけるか、別機能として置くか。
8. 追加15件と001〜015のどれを採用を優先するか。類似案（013と017、014と020、015と024など）が残る。

## 13. 再開手順

1. `progress.json`（state: completed、completed_ids 30件、mode: APPEND_COMMON_SOLO_15）と `manifest.json`（30件）を確認する。
2. 001〜015は書き換えない。修正要求があれば該当ファイルのみを編集し、HTMLとJSONの両方を同時に直す。
3. source_evidence を触るときは、sources.json の `status_declarations` と snapshot の見出しの両方を必ず照合する。
4. パックのID判定が直った後、管理側が検証を実行し、採用判断を行う。本担当は採用判断を行わない。

採用判断は行っていません。