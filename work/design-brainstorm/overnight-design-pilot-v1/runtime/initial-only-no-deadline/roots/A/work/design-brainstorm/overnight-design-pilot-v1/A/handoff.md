# ROLE-A handoff — overnight-design-pilot-v1（試走3件）

**Status: Draft（今回の担当作業の記録。採用判断・仕様確定ではない）**

本ファイルは ROLE=A の作業結果と未確認事項の引き継ぎです。設計候補以外（正本の変更、コード、Studio、Git、コミット）は行っていません。採用判断も行っていません。

## 1. 件数と分類

| 候補ID | 主対象 | 分類 | category | design_status | requires_code | 試作コスト | conflicts | unresolved_refs |
| --- | --- | --- | --- | --- | --- | --- | ---: | ---: |
| ROLE-A-001 | 8/31 | マップ固有 | GimmickEvent | Draft | true | 中 | 3 | 3 |
| ROLE-A-004 | 廃TSUTAYA | マップ固有 | NPC | Draft | true | 中 | 2 | 3 |
| ROLE-A-013 | 全マップ共通 | 全マップ共通 | MobEnemy | Idea | true | 中 | 2 | 3 |

- 作成済み: 3件（HTMLと同IDのJSON）。index.html、manifest.json、board.css、progress.json、events.jsonl は件数に含めていない。
- 担当Aの予約15件のうち未作成: 002、003、005、006、007、008、009、010、011、012、014、015（12件）。
- 各マップ3件の枠はPilot Onlyのため未着手。013は「イベントから通常モブが生まれる」枠として作成済み。
- ROLE-A-014と015については、013と同じモブの変種にしない方針を適用する。今回の指示では3件で停止するため未作成。

## 2. 表示確認

- `visual_check.status`: **unavailable**。担当セッションはBash・外部ディレクトリ・Studio・MCP禁止のため、ブラウザを起動できずHTMLとSVGの実表示を確認できなかった。
- 未確認のもの: 3件のHTMLのレイアウト、3件のインラインSVGの描画（文字のはみ出し、矢印の意味、注記の可読性）、index.htmlの一覧表示、board.cssの適用。
- 検証器が要求する構造（SVGのviewBoxとroleとaria-label、必須section 8種、本文への候補IDとtitleとdesign_statusの記載）は各HTMLのソース上で整えている。これは静的な構造の確認であって、実ブラウザでの目視確認ではない。

## 3. 参照と接続

- peer-snapshotsは管理側から配布されていない。BとCの候補本文を読んでおらず、相手の内容を創作していない。
- 001からROLE-C-001とROLE-B-001へ optional_connection。いずれも resolution は reserved_unresolved で、unresolved_refsに理由を記載した。
- 004からROLE-B-004へ data_dependency（adoption_blocker: true）、ROLE-C-004へ optional_connection。
- 013からROLE-C-013とROLE-B-013へ optional_connection。
- ID未指定の接続要求が各1件（001: HUDと測定条件、004: Archive Selection UIの状態欄と対象棚の選び方、013: イベント「開いた」の表現と湧き枠の粒度）。いずれも adoption_blocker: true。
- data_dependency は004からB-004への1件のみ。これは起動データに関する未解決であり、採用前の停止論点として残す。循環は現時点で発生していない（interaction_loopの参照は無い）。
- 候補間の自己参照（001と004と013の相互参照）は張っていない。各候補は接続先なしでも成立する設計にした。

## 4. 重複と複製でないこと

- 001: 通常NPC1体と個人提示。攻撃で記録が止まる。8/31のフェーズを入力とする。
- 004: 通常NPC1体と依頼の印と、試聴候補からの除外。放置でも成立する。廃TSUTAYAのアーカイブを入力とする。
- 013: 湧き枠と個体上限を持つモブ。Anomalyの枠とは別で、マップ共通。
- 名称や数値やマップだけを変えた案は作っていない。3件とも、NPCか湧きか、GimmickEventかNPCかMobEnemyか、選択の構造、失うものが異なる。
- ただし001と004はいずれも「通常NPCと個人提示」という共通構造を持つため、朝のレビューで両者を並べて比的する価値がある。統合は提案していない。

## 5. 世界観の留保（確定していないもの）

- 世界の起源、アノマリーの正体、博士の真意は、どの候補でも確定していない。理由として創作していない。
- NPCは説明役ではない。会話で得られるのは「その場所で何をしているか」だけで、世界の理由は答えない（world/information-design.mdに従う）。
- 型を分離した。点検役と客は通常NPC。013の個体は通常モブ（MobEnemy）。Anomaly Entity（whisper、Mad Stomper）とPlayer Anomalyは、どの候補にも混合していない。Player Anomalyは判断019により通常NPCとInteractionできないため、001、004、013のいずれでも提示、受け渡し、依頼成立は成立しない。
- 研究所（元同僚、whisper、判断018）に関する候補は今回の3件に含まれない（枠は010から012）。既存の連鎖（接触、追従先移送、機材へ閉じこもる、開くと二者消失と装置が残る）は未確定要素として尊重し、追加で確定していない。結末、装置の正体、博士の処分の真偽はいずれも確定していない。
- 現実の日本、実在のTSUTAYA、既存作品の再現は無い。INV-01からINV-11は自己確認として各JSONの worldview.invariants_checked に全11件を記載した。これは自己確認であり、検証器は内容の整合性を保証しない。
- 001の赤線や013の「開いた」の種類のように、世界設定の解釈になりうる要素は、未確定のまま記した。

## 6. requires_code と試作コスト

- 3件とも `requires_code: true`。理由は各JSONの requires_code_reason に記載。いずれも必要性の記録であり、コード生成の許可ではない。
- 3件とも `prototype_cost.band: 中`。実時間の見積もりは出していない（試作コストは生成にかかった時間とは別の物である）。
- 未実装または未確認の前提を明示した箇所: NPCState（Unconfirmed）、通常の敵AIは未実装、正式なItemStackと取得源（SRC-01）、個人提示UIの経路、湧き枠の共通表現、性能（8/31は1マップあたり約13,000 BasePartという記録がある）。

## 7. 所要時間と停止理由

- 所要時間: **未計測**。日時取得手段が担当へ禁止されているため、events.jsonl の at と progress.json の started_at と ended_at はすべて null。管理側の観測開始時刻 2026-10-04T05:18:48Z は管理側の記録であり、本担当の実測時刻として使っていない。
- 停止理由: `PILOT_ONLY` のため試走3件（001、004、013）で停止し、`state: awaiting_pilot_review`。管理側の停止または続行指示を待つ。本番12件へは進んでいない。
- モデル、provider、費用: model のみ実行環境の設定値として `opencode/space-bunny-free` を記入。provider と session_id と費用とトークンは確認手段がないため null。
- 待機: events.jsonl に wait_start を記録。管理側が停止するまで待機する。

## 8. 採用判断が必要な論点（担当からは判断しない）

1. 001の先行手掛かりの位置づけ。8/31の「危険度上昇はExposure速度と帰還閉鎖だけ」という記述に第三の表現（測定値）を足すか。危険度にはせず観察記録にとどめるか。
2. 001の提示の粒度。段階の手掛かりを「進行中である」以上の情報として出していいか。残秒を一切出さない制約を維持するか。
3. 001のNPC状態機械の置き場所。8/31マップ固有に置くか、共通NPCの枠として置くか。他のマップのNPC案（002から012）との共通化の要否。
4. 004のArchive Selection UIの変更可否。既存の選択結果に状態欄（依頼印）を追加してよいか。できない場合の代替提示経路。
5. 004の所持基盤依存。data_dependency（B-004）が未解決である。個人所持が無ければ除外Effectは保留される。004はdata_dependencyを持つ唯一の候補であり、採用前にこの依存を解消する必要がある。
6. 004の対象棚の選び方。固定するかRun開始時に選ぶか。棚の位置は候補側で固定していない。
7. 013の湧き枠とAnomaly枠の関係。別枠のRun状態を認めるか。共通化するなら判断017との関係を別途記述する必要がある。
8. 013の0.90倍減衰との算入範囲。通常モブの発生をアノマリー発生回数に算入しないという本候補の案の採否。
9. 013の数値。上限、枠の粒度、補充周期、終端の定義、湧き先の通行。すべて未確定で、実数を置いていない。
10. 全候補共通の提示UI方針。個人提示を既存HUDへ載せるか、専用UIとするか。ID未指定の接続要求として各1件に残している。

## 9. 検証と実表示について（管理側の担当）

- `validate.py --pack-only` と、`validate.py --role A --output work/design-brainstorm/overnight-design-pilot-v1/A --stage pilot` は本担当では実行していない（担当専用指示）。結果は未確認である。
- ブラウザでの実表示確認も本担当では実施していない。上記のとおり unavailable として記録した。
- 検証器がレビュー事項として挙げると考えられる点: proposed コンポーネントの使用、Partial または NotImplemented または Unconfirmed の実装状態、requires_code の理由、conflicts と uncertainties の全件、未解決参照、data_dependency 1件、視覚確認の未実施。
- 作業の透明性のため1件記録しておく。作業途中にシェル実行を1回誤って呼び出した（出力のみで、ファイル操作、ネットワーク、Git操作は行っていない）。以後のファイル作成と編集はネイティブのWriteとEditのみで行い、共通パック、正本、他担当、src、tools、Studioには触れていない。

## 10. 再開手順（RESUME_AFTER_PILOT の場合）

1. このフォルダの `progress.json`（state は awaiting_pilot_review）と `manifest.json` を読む。completed_ids は ROLE-A-001、ROLE-A-004、ROLE-A-013 の3件である。
2. 同じ3件は作り直さない。既存ファイルを読み、必要なら本文とJSONの両方を同時に修正する。
3. 次の3件を作る。候補順は ROLE-A-002（8/31）、ROLE-A-003（8/31）、ROLE-A-005（廃TSUTAYA）。3件単位で保存し、合計6件、9件、12件、15件の時点で progress 検証（stage は progress）を行う。
4. 15件で stage final の検証を行い、全リンク、HTMLとSVGの表示、未解決参照、コストを確認する。
5. events.jsonl には各 batch の candidate_ids を実測時刻とともに追記する（時刻取得手段が使える場合）。使えない場合は null のまま、note に理由を記す。
6. 既存の予約IDと provides_traits の語彙は再利用できる。ただし相手の候補が配布されるまで refs の resolution は reserved_unresolved のまま据え置き、未解決の理由だけを更新する。
7. ブラウザ確認ができる場合は visual_check.status を checked にし、checked_ids には実表示を確認したIDだけを記す。できない場合は unavailable と理由を維持する。
8. SEKIGAHARAと研究所の枠（007から012）では、地形、部屋、正式配置の新規案を作らない。既存の記述（SEKIGAHARAの勢力と戦況はIdea、研究所の建物構造は未確定）を前提に据える。
9. 共通枠（014、015）は013と同じモブの変種にしない。別の判断と別の代償を持つ案にする。
