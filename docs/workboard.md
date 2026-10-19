# 開発ワークボード

**Status: Draft（実行キュー・棚卸し）**
**更新日: 2026-10-15（資料更新差の解消を反映）**

## 現在の概要

2026-10-15にローカル文書・作業記録・Git状態を棚卸し。Studio・GPU・公開URLの現在状態は再検証していない。実プレース検証は10月7日の6Client記録と、10月13日の8/31限定Play・岩Edit配置の記録を範囲別に参照する。

| 領域 | 現状 | 次にすること |
| --- | --- | --- |
| 最小Run | ユーザーがP0のStudio確認完了を報告 | 現行P0は完了。新たな問題があれば別件で切り出す |
| リザルト・LobbyState | リザルトP0はユーザー確認で完了。判断020の設計採否は別件 | LobbyStateの責務判断がなお必要かを別途整理 |
| 8/31 | ユーザーがP0をStudio確認済み。現行マップ修正は解決扱い | 新アセット等に基づく再制作は別範囲。再制作の全体設計は別途定義 |
| TSUTAYA | ユーザーがP0をStudio確認済み。現行マップ修正は解決扱い | 再制作の具体的範囲・工程は別途定義。編集原本化の完了はこの報告から推定しない |
| Inventory・Quest・出現・スキル | 基本方針は一部決定、最小データモデル等は判断待ち | P1の各判断対象を絞る |
| W01 | 評価資料完成。20枚すべて見送り、主因は動作・残像。次の3構図を記録 | W01-02で試作指示を文書化。③は敵・斬撃なし |
| W03／W05／W06 | 岩の通常Import未完了、W05は固定手順・v004保存・Studio導入と纏絲勁ソロ試作を確認、UI編集Prototypeあり | W03は検証条件判断。W05は前後逆の原因修正・v005方向検証済み。修正版の再公開・見た目・複数Client検証。W06はロードマップ段階 |
| 制作ワークショップ | BASE-01／02の文書基盤を配置済み | 実制作・自動化・全6部屋の完成とは区別 |
| ABC追加45案 | 各15件の補正・検証・共有記録あり。採用は未実施 | 人間の採用／保留／却下レビュー |
| Idea・保留運用 | モーフ・smudge・戦場は保留。領域センサーはDraft・未追跡 | 採用・実行を自動再開しない |
| HTML公開・ローカル共有 | Pages公開の過去記録あり。現在の公開状態・ローカル資産の別端末共有は未確認 | 必要時に確認。未追跡資産の共有範囲を整理 |

従来のP0・4件はユーザー確認により完了。マップの再制作は現行修正から切り分け、対象・新アセット・工程・検証条件を定義してから着手する。今回、新しいマップ制作は開始していない。

[P0：Studio検証](#p0-実装studio検証) ／ [制作](#制作ワークショップ次の試走準備) ／ [資料照合](#資料照合共有範囲の整理) ／ [P1：基盤の判断](#p1-最小runを継続可能なゲームへつなぐ基盤) ／ [保留](#保留中の設計運用) ／ [完了記録](#直近の完了記録) ／ [棚卸し記録](#2026-10-15棚卸し記録) ／ [検証ログ](#詳細な検証ログ)

## 実行キュー

### P0: 実装・Studio検証

2026-10-15にユーザーから4件すべてStudio確認済みとの報告を受領し、完了履歴へ移動した。現在この区分の未完了項目はない。新しい不具合や再制作の検証は別タスクとして扱う。

### 制作ワークショップ：次の試走準備

#### W05：固定リターゲット手順・Studio導入・纏絲勁試作（2026-10-17）

- Shade高速化（2026-10-18）: 50スタッド／0.3秒・暫定25ダメージ＋0.5秒Stunと判定／経路の枠をStudio実装。実測50、壁停止23.35、複数対象各1回・範囲外・Stun中断・表示OFFを確認。[記録](systems/shade-prototype.md)。

- Shade適用（2026-10-18）: ユーザー確認でスロット3のStealthをShade表示へ変更。shade.fbxの親子循環・座標系を補正してR15化、v002で方向・実入力・効果継続と解除を確認。公開ID／人間の見た目レビューは残る。[記録](../work/animations/motions/shade/README.md)。

- ローリング移動調整（2026-10-18）: スロット2単独で約20スタッドへ変更。実測19.9712、壁前停止・Stun中断をPlay Solo確認。[記録](systems/movement-animation-integration.md#ローリング単独で約20スタッド移動2026-10-18追記)。

- 2026-10-18追記: Sprinting Forward Roll／Standard Runを固定手順でR15化し、既存ローリング／Shift走行へStudio適用。実入力・方向Yaw0°／90°・Stun停止・保存再読込を確認。公開ID発行と人間の見た目レビューは未完了。[実装と残件](systems/movement-animation-integration.md)。

- 状態: `In Review`（固定スクリプト・保存再読込・Studioソロ再生／攻撃試作を確認。v005方向修正・ソロ再生確認済み。修正版の公開ID・正式採用は未完了）
- ユーザー指定: Mixamo→公式R15の固定手順化と作業部屋MDへの記録、Studio Import、纏絲勁実装。スロット4・設定分離した暫定数値で試作する承認あり。
- 実施: [固定スクリプトとMD](../work/animations/scripts/README.md)。基準軸・A/T姿勢を補正し、15ボーン・1〜65FをBake。現行v004は腰移動を脚長比で変換し、別プロセスの保存・再読込・FBX出力を検証。
- 導入: FBX Import成功。余分なルート・骨軸を保存済みPoseアダプタで補正し、実行用65KeyframeをStudioへ配置。
- 試作: 纏絲勁を既存4枠目に追加。実Client入力、25＋遅延8、0.5秒Stunと解除、小威力Parry、壁遮蔽、Cooldown拒否、リザルト中断、実R15のAnimationTrack再生をPlay Soloで確認。
- 次: 見た目・接地・接触、複数Client／PvP・複製を検証。公開ID `95405144949752` の前後逆を再現。出力basisをanatomical v2へ修正し、Yaw0°／90°で旧版Fail・v005 Pass。旧IDはlegacy扱いで採用を拒否し、現在Studioは検証済みv005で再生。修正版の再公開と公開ID再検証が必要。ゲーム公開・プレース保存は未実施／未確認。
- 正本: [試作仕様](systems/tensikei-prototype.md)、[結果・証拠](../work/animations/motions/hook-punch-sample/studio/RESULT-20261017.md)。元v001・v002と既存Sourceを保持。
- 2026-10-18: 前半3倍・後半2倍（約0.889秒）へ高速化し、約0.167秒で主判定開始。判定Boxと一致するStudio用ワイヤーフレームを追加。ソロで命中・非命中・壁遮蔽・単一対象・Client表示・中断掃除を確認。[QA](../work/animations/motions/hook-punch-sample/studio/fast-hitbox-qa-20261018.json)。


#### W01-02：3構図の試作指示を具体化する

- 状態: `Ready`
- 担当: Codex（文書作成のみ）
- 目的: 見送り理由「動作・残像が伝わらない」を受け、ユーザー指定3構図を次の試作指示へ展開する。
- 確認済み: ①横スクロール視点で敵をすり抜け＋残像＋斬撃、②①の右斜め上三人称版という解釈、③右斜め上三人称・敵なし・斬撃なし・残像強調。
- 次の作業: 3案のBrief、見分ける評価項目、最小の生成枚数・設定・停止条件の案を記述する。未指定の敵外見・衣装等をゲーム仕様にしない。
- 変更範囲: 新しいW01タスク文書。既存PNG・batch・レビュー・ゲーム仕様は保持。
- 完了条件: 動作と残像の評価を分離し、要求・暫定案・未決事項が区別された作業指示を提示できる。
- 正本: [3構図のBrief](../work/icon-generation/tasks/W01-01/composition-directions.en.md)、[前回の評価結果](../work/icon-generation/tasks/W01-01/runs/review-20261015/RESULT.md)
- 境界: Readyは指示の文書化だけ。画像生成、GPU起動、モデル切替、外部公開は含まない。

#### W03-01：岩材質の通常Import検証準備

- 状態: `Needs Human`
- 担当: Codex（制作・編集専用）／人間（検証先・実行範囲の判断）
- 判断対象: 検証先、コピーの保存・再読込、時間上限、実行可能範囲。今回Studioの現在状態は未照合。
- 次の作業: 条件決定後に入力を固定し、通常FBX Importを1試行する。
- 完了条件: 通常Import・見た目・衝突・Play・保存再読込を証拠付きで区別し、未確認を成功扱いしない。
- 正本: [作業指示](production/workshop/tasks/W03-01.md)、[既存材質試作](references/material-preview.md)
- 備考: 既存試作を無断で置換・削除しない。本番配置・ゲーム公開・有料素材は対象外。

### 資料照合・共有範囲の整理

#### ローカル成果の保管・共有範囲を確認する

- 状態: `Inbox`
- 担当: Codex（差分整理）／人間（バイナリ保管・共有対象）
- 現状: 判断023・024、W01生成ツール、ワークショップ資料等に未追跡・未コミットのローカル成果がある。GitのHEADだけでは別端末で再現できない。
- 次の作業: 文書・ツール・バイナリを分け、共有対象・保管先・未共有範囲を提示する。コミット／プッシュは別作業。
- 完了条件: 既存変更を保全し、共有すべき対象と取得方法を特定する。バイナリ保管は人間判断を反映する。
- 正本: [制作環境の棚卸し](production/workshop/inventory-2026-10-14.md)、[受け渡し契約](production/workshop/shared/handoff.md)

### P1: 最小Runを継続可能なゲームへつなぐ基盤

#### 正式Inventory／ItemStackの最小仕様を決定する

- 状態: `Needs Human`
- 担当: 人間
- 判断対象: Item ID、スタック、所有者、所在、マップ上の取得源、Run終了時の移管。
- 完了条件: Quest回収とSecure Slotを一つのデータモデルで扱える最小仕様を、既存資料の正本へ記録する。
- 正本: [現在の実装状況](systems/current-implementation.md)、[未実装機能の優先順位](systems/implementation-priorities.md)

#### Quest／Discoveryのデータモデルと交換状態を定義する

- 状態: `Needs Human`
- 担当: 人間
- 判断対象: Questの受注・放棄・完了・失敗状態、博士Questの解放条件、Discoveryの保存・UI、複数人のQuest入力と切断時の扱い。
- 完了条件: `QuestService`、Discovery、アノマリー出現補正、研究室交換UIを実装指示へ展開できる最小データモデルを定義する。
- 正本: [014: Quest枠、Discovery、博士Questによる研究解放](decisions/014-quest-discovery-and-research-unlocks.md)、[未実装機能の優先順位](systems/implementation-priorities.md)

#### Run単位のアノマリー出現コンポーネントを定義する

- 状態: `Needs Human`
- 担当: 人間
- 決定済み: 候補外の博士Quest対象は何も起こさない。同種の同時出現上限はアノマリーごとのコンポーネントで持ち、特定アイテムが個別出現確率や同時出現数をRun単位で変動させ得る。
- 判断対象: コンポーネントのデータ形式、解決後の枠、変動アイテム、重ね方、出現判定順。
- 完了条件: Anomaly SystemとItem Interactionの実装指示へ展開できる最小データモデルを定義する。
- 正本: [017: Run単位のアノマリー出現コンポーネント](decisions/017-run-anomaly-spawn-components.md)

#### 異常化後のRun終了を決定する

- 状態: `Needs Human`
- 担当: 人間
- 決定済み: 同時Player Anomalyは1人まで。閾値超過者は先行者の死亡／帰還まで待機する。通常プレイヤー同士はHP 80%下限、Player Anomalyとの間は相互キル可能。固有InteractionのPortal帰還とRuntime満了帰還を設ける。
- 判断対象: 固有Portal帰還・Runtime満了時のQuest／資産／基本報酬の精算、待機者へのUI、実装優先順位。
- 完了条件: 現行の`TRANSFORMED_TIMEOUT`仮実装を置き換える終了・精算処理を実装指示へ展開できる。
- 正本: [ゲームルール](systems/game-rules.md)、[現在の実装状況](systems/current-implementation.md)

#### スキルビルドの最小仕様を決定する

- 状態: `Needs Human`
- 担当: 人間
- 決定済み: 通常スキルは攻撃・探索・補助・アクションの4系統。解放時レベル1、強化上限レベル3。各系統の次ランクは直前ランクの3スキル解放と、そのうち1つのレベル3が条件。奥義はランク解放数に含めず、ランクごとのスキル強化で取得する方針。
- 判断対象: 4枠案の最終採否、ランク1の不足スキル、奥義の具体的解放条件、装備・切替・失効、通常成長とPlayer Anomaly時の強化の関係。
- 完了条件: 現在の3スキル実装との移行方針を含め、最初のビルド実装単位を定義する。
- 正本: [通常スキルとビルド](systems/skill-build.md)、[ゲームルール](systems/game-rules.md)、[経済と成長](systems/economy-and-progression.md)

### P1: 終了処理と候補レビュー

#### Run終了後のLobbyStateの責務を決定する

- 状態: `Needs Human`
- 担当: 人間
- 判断対象: 死亡リザルト中の帰属・位置、Party退出処理と都市帰還処理の書き込み責務。競合原因は推測を含むため再現確認も必要。
- 完了条件: 判断020の採否を記録し、修正対象と死亡・通常帰還・切断後の検証条件を定める。
- 正本: [020: LobbyStateと物理位置](decisions/020-lobby-state-authority-and-physical-location.md)

#### ABC全マップ共通追加45案をレビューする

- 状態: `Needs Human`
- 担当: 人間
- 対象: Ling回のROLE-A/B/C-031〜045、各15件。機械検証エラー0・全45HTML描画確認は記録済み。ゲーム内検証・採用は未実施。
- 判断対象: ソロPvE探索としての面白さ、似た用途の案、必要な新規ロジック、初回試作へ絞る候補。
- 完了条件: 候補ごとに採用／保留／却下と理由を記録し、採用案だけ実装可能な粒度へ整理する。
- 資料: [補正済み45案と検証記録](../work/design-brainstorm/overnight-design-pilot-v1/runtime/ling-common-plus-15/collected/README.md)、[全回のレビュー入口](../ABC-REVIEW.md)
- 備考: 初回45案と、未完の追加37案は別回。元出力・複製・予約IDを新規成果物として数えない。

## 保留中の設計・運用

#### 追加のスロット強化とCapacity Expansionの数値設計

- 状態: `Parked`
- 担当: 人間
- 保留理由: 交換レート、上限、入出庫時点、Player Anomaly時の制約、別種のスロット強化は、現時点の仕様範囲では決めない。
- 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)

#### 全身モーフ・利用履歴・マップ別強敵を検討する

- 状態: `Parked`
- 保留理由: 性能・スキル制限、既存通常攻撃との優先順位、履歴の用途、強敵の出現と挑戦段階が未決定。
- 再開条件: 最初に試すモーフと戦闘対象、変更する既存仕様を選ぶ。
- 正本: [モーフ、ビルドと任意挑戦](systems/morph-build-and-optional-foes.md)（Idea、コミット`4b7613c`）

#### smudgeの接触・音楽干渉を検討する

- 状態: `Parked`
- 保留理由: Interactionが壊れる範囲、変質状態が鍵になる対象、音楽干渉の成立条件、固有品・専用スキルが未定。
- 再開条件: 試すInteraction一種類と、音楽入力・観察できる結果を決める。
- 正本: [smudge](anomalies/smudge.md)（Idea、コミット`aa41c0e`）

#### 領域センサー式大型NPCのDraftをレビュー・共有する

- 状態: `Inbox`
- 現状: ローカルに文書とシステム一覧へのリンクあり。2026-10-15のGit確認でも未追跡。Studio未検証。
- 次アクション: 行動選択・追跡・攻撃判定の範囲をレビューし、コミット対象を決める。
- 資料: [領域センサー式大型NPC](systems/region-triggered-boss-actions.md)（ローカルDraft）

#### 新マップ「戦場」の採否を検討する

- 状態: `Parked`
- 保留理由: PvP例外と情報提示原則の衝突、ループのマルチプレイ境界、報酬・終了条件が未決定。
- 再開条件: マップ固有例外を許す範囲を人間が判断する。
- 正本: [戦場](systems/map-battlefield.md)（Idea）

#### OpenCodeを単一実行で運用する

- 状態: `Parked`
- 現状: ユーザー方針は単一実行。無料提供側の429・Endpoint unavailableによる中断記録あり。並走が原因との断定はしていない。
- 再開条件: 次の依頼範囲・モデルを決め、保存場所と終了条件を確認する。今回新規起動はしない。
- 資料: [単一実行の補足指示](../work/design-brainstorm/overnight-design-pilot-v1/runtime/ling-common-plus-15/SINGLE-RUN-OPERATIONS.md)

#### iCloud管理外への作業場所移動を検討する

- 状態: `Parked`
- 現状: Documents配下がiCloud管理対象である調査記録あり。調査時の書き込み成功は将来の容量保証ではない。移動は未実施。
- 再開条件: ユーザーが移動先と時期を決定し、作業セッション停止後に手順を組む。

## 直近の完了記録

### 資料更新差の解消 — `Done`

- マップ：判断024に合わせ、ETR-01〜08の到達点を整理。旧全体案と8/31の現在方式を分離し、実装棚卸しも整合。
- Secure Slot：判断010に従い、スキル強化という旧記述を研究室・レアルート品による強化へ修正。経路設計済みと実装未完了を区別。
- W05：保存検査にSource Actionが存在することを反映。Target Actionなしの検査時点と、その後の骨格実行記録を区別し、現在blendへの保存は未確認と明記。
- 入口：W01評価完了・新3構図、岩Edit配置／通常Importの区別を反映。
- 正本: [資料整合の記録・証拠](production/workshop/runs/DOCS-20261015/RESULT.md)、[ETR](systems/editor-templates-and-runtime-maps.md)、[優先順位](systems/implementation-priorities.md)、[Hook Punch](../work/animations/motions/hook-punch-sample/README.md)
- 完了範囲：文書の矛盾・更新差の整理。blend保存・互換性・元FBX出典・他マップ移行・新アセット制作の完了は意味しない。保管・共有は別Inboxに残す。

### P0：ユーザーのStudio確認により完了

#### 最小Runの複数Client検証

- **状態:** `Done`
- **確認者:** ユーザー
- **確認受領日:** 2026-10-15（実際の検証日時・条件は未記録）
- **結果:** ユーザーがStudio確認済みと報告。通常成功帰還・未達帰還を含むP0残件を完了扱いとする。
- **根拠:** セッション発言「p04件はスタジオ確認済みです。マップ修正に関しては新しいアセットなどをもとに再作成するので一旦解決にしたいです。」
- **記録の範囲:** 人間の確認報告と完了判断を受領。Codexによる再テスト、Client数、対象コミット、項目別の測定結果を追加したものではない。
- **正本:** [現在の実装状況](systems/current-implementation.md)、[最小Runの範囲](decisions/005-minimum-lobby-run-scope.md)
- **検証履歴:** [詳細ログ 1](#verification-log-1)

#### リザルトUIの実表示検証

- **状態:** `Done`
- **確認者:** ユーザー
- **確認受領日:** 2026-10-15（実際の検証日時・条件は未記録）
- **結果:** ユーザーがStudio確認済みと報告。リザルト実表示・精算等のP0確認待ちを解消。
- **根拠:** セッション発言「p04件はスタジオ確認済みです。マップ修正に関しては新しいアセットなどをもとに再作成するので一旦解決にしたいです。」
- **記録の範囲:** 人間の確認報告と完了判断を受領。Codexによる再テスト、Client数、対象コミット、項目別の測定結果を追加したものではない。
- **正本:** [現在の実装状況](systems/current-implementation.md)、[Studio検証チェックリスト](production/studio-verification-checklist.md)
- **検証履歴:** [詳細ログ 2](#verification-log-2)

#### 8月31日景観変更のStudio検証

- **状態:** `Done`
- **確認者:** ユーザー
- **確認受領日:** 2026-10-15（実際の検証日時・条件は未記録）
- **結果:** ユーザーがStudio確認済みと報告。現行マップへの修正対応は解決扱い。新しいアセット等に基づく再制作へ進む方針で、旧修正キューを継続しない。
- **根拠:** セッション発言「p04件はスタジオ確認済みです。マップ修正に関しては新しいアセットなどをもとに再作成するので一旦解決にしたいです。」
- **記録の範囲:** 人間の確認報告と完了判断を受領。Codexによる再テスト、Client数、対象コミット、項目別の測定結果を追加したものではない。
- **正本:** [008: 8月31日の景観構成](decisions/008-august-31-landscape-composition.md)、[024: 編集原本化](decisions/024-editable-august-map-authoring.md)、[編集手順・限定検証](production/editable-map-workflow.md)
- **検証履歴:** [詳細ログ 3](#verification-log-3)

#### TSUTAYA「閉店直後のアーカイブ」改修のStudio検証

- **状態:** `Done`
- **確認者:** ユーザー
- **確認受領日:** 2026-10-15（実際の検証日時・条件は未記録）
- **結果:** ユーザーがStudio確認済みと報告。現行マップへの修正対応は解決扱い。新しいアセット等に基づく再制作へ進む方針で、旧修正キューを継続しない。
- **根拠:** セッション発言「p04件はスタジオ確認済みです。マップ修正に関しては新しいアセットなどをもとに再作成するので一旦解決にしたいです。」
- **記録の範囲:** 人間の確認報告と完了判断を受領。Codexによる再テスト、Client数、対象コミット、項目別の測定結果を追加したものではない。
- **正本:** [009: 閉店直後のアーカイブ](decisions/009-tsutaya-closing-time-archive.md)
- **検証履歴:** [詳細ログ 4](#verification-log-4)

### アイコン評価

#### W01-01：SHADEの意味・画風分離と評価準備

- 状態: `Done`
- 担当: ユーザー（採否判断）／Codex（記録反映）
- 現状: 2026-10-15に4層のBrief、20枚の入力固定、オフライン比較ページを作成。画像ハッシュと模擬DOM検証はPass。実ブラウザ表示・ダウンロードは未確認。
- 結果: ユーザーが20候補すべて「見送り」と判断。画像版・判断者・発言を記録。主因は「動作・残像が伝わらない」と追加確認。背景別・サイズ別の評価は未提示。
- 後続: W01-02へ分離。3構図は指示として記録済みで、生成枚数・条件は未指定。
- 完了条件: 対象画像版・条件・判断者・理由を記録し、人間評価と生成成功・正式採用を分離する。
- 正本: [作業指示](../work/icon-generation/tasks/W01-01/TASK.md)、[評価入口](../work/icon-generation/tasks/W01-01/runs/review-20261015/README.md)、[実施結果](../work/icon-generation/tasks/W01-01/runs/review-20261015/RESULT.md)
- 判断記録: [20候補の見送り](../work/icon-generation/tasks/W01-01/runs/review-20261015/human-review.json)
- 備考: 完了は準備資料と採否記録の範囲。見送り理由は確認済み。ブラウザ実表示は独立検証していない。元画像は保持。


### 制作ワークショップの初期文書基盤 — `Done`

- BASE-01：既存資産・文書の棚卸し、入力ハッシュ、更新差・未確認事項を記録。
- BASE-02：共通作業規約、受け渡し・検証・視覚設計、TASK／RESULT、W01／W03の次回指示を配置。
- 正本: [ワークショップ入口](production/workshop/README.md)、[整備記録](production/workshop/runs/BASE-20261014/RESULT.md)
- 完了範囲は文書整備・静的確認。人間の完成文書レビュー、別担当での再開、実制作、GPU・Studio検証、外部依存導入は含まない。

### 設計判断の完了

#### Secure Conversionの成長経路を決定する

- 状態: `Done`
- 担当: 人間
- 決定: 都市ロビーのアノマリー研究室で、レアルート品を消費して通常スロット1枠をSecure Slotへ変換する。総枠数は増えない。
- 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)、[経済と成長](systems/economy-and-progression.md)

#### レアルート品の分類と取得経路を決定する

- 状態: `Done`
- 担当: 人間
- 決定: レアルート品をスキル強化用とスロット強化用に分け、前者を相対的に出やすくする。アノマリー相互作用、低難度以外のQuest、チュートリアルQuestを取得経路にする。
- 正本: [011: レアルート品の分類と取得経路](decisions/011-real-route-acquisition.md)、[経済と成長](systems/economy-and-progression.md)

#### アノマリー相互作用による固有スキル取得を決定する

- 状態: `Done`
- 担当: 人間
- 決定: アノマリーの一部または関連アイテムを専用スキルと交換する。博士の調査Questと研究対象外のレアアノマリーの双方で、相互作用成立時に同一Runのパーティ全員へ固有品を出現させる。
- 正本: [012: アノマリー相互作用による固有スキル取得](decisions/012-anomaly-linked-skill-acquisition.md)、[アノマリー相互作用](systems/anomaly-interaction.md)

#### Capacity Expansionの基礎仕様を決定する

- 状態: `Done`
- 担当: 人間
- 決定: 総インベントリ枠を増やす強化を設け、Secure Conversionと同種のレアルート品を消費する。追加枠は通常スロットとして始まり、Secure化は別途Secure Conversionで行う。
- 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)、[ゲームループとポータル遷移](systems/game-loop.md)

#### QuestとDiscoveryの最小分離を決定する

- 状態: `Done`
- 担当: 人間
- 決定: 同時受注は博士Quest 1件、その他Quest 3件、合計4件。DiscoveryはQuest枠を消費しない発見・認識記録とする。博士Quest受注中は対象アノマリーの個別出現確率を1.40倍へ上げ、対応する固有品を専用スキルへ交換できる。Party Runは開始時の異なる対象をサーバーが固定し、重複なしで補正する。アノマリー発生ごとに全候補は0.90倍へ減衰し、途中脱落後も補正を維持する。
- 正本: [016: Party Runにおける博士Quest出現補正の固定](decisions/016-party-professor-quest-spawn-snapshot.md)、[クエスト](systems/quests.md)

#### Player Anomaly待機者の選出順を決定する

- 状態: `Done`
- 担当: 人間
- 決定: サーバーはExposure閾値を先に超えた順で待機キューを保持し、先行Player Anomalyの退場後に先頭をアノマリー化する。
- 残件: 待機状態のUIと、待機中の切断時の扱いは「異常化後のRun終了を決定する」で扱う。
- 正本: [019: Player Anomalyの単独発生、PvP、固有帰還](decisions/019-player-anomaly-runtime-pvp-and-return.md)、[ゲームループとポータル遷移](systems/game-loop.md)

### 成果物の共有

#### ABC候補の補正・補完と公開用一覧 — `Done`

- 追加45案の生成・収集・機械検証・HTML表示確認を記録し、`1f2d72a`でプッシュ。採用判断は上記別項目。
- [成果物・検証の記録](../work/design-brainstorm/overnight-design-pilot-v1/runtime/ling-common-plus-15/collected/README.md)
#### イントロHTMLの共有 — `Done`

- `1d7bd33`でHTMLをプッシュし、Pages公開確認済み。Roblox実装や演出採用を意味しない。
- [HTMLプロトタイプ](../work/intro-animation/intro-v1.html)
#### モーフ・強敵とsmudgeのIdea記録 — `Done`

- `4b7613c`、`aa41c0e`で文書化・プッシュ。採用・実装は保留欄で管理。
- [モーフと強敵](systems/morph-build-and-optional-foes.md)、[smudge](anomalies/smudge.md)

## 2026-10-15：棚卸し記録

- 確認範囲: このWorkboard、current-implementation、implementation-priorities、ETR資料、判断010・020・023・024、Studioチェックリスト、編集マップ工程、ABC追加45案の結果、W01の採否・3構図、ワークショップ・材質・アニメーションの記録。Git HEADは `788a3bc`、既存未コミット差分あり。
- W01-01を完了記録へ移動。後続の3構図はW01-02として分離し、Readyの範囲を指示の文書化に限定した。
- 8/31の「移行前の判断待ち」をInboxの資料照合へ変更。判断024の限定実装を参照し、保存・実歩行等は既存P0に追加。全マップの境界決定済みとはしない。
- W05の記録差、古いSecure Slot記述、未共有ローカル資産をInboxへ切り出した。W02・W04・W06の代表試作や自動化はロードマップ上の候補を維持し、一括起動しない。
- 通常帰還、リザルト、TSUTAYA、LobbyState、Inventory／Quest等、ABCレビュー、保留項目は追加の完了根拠がないため状態を維持。
- 残る資料差: ETR資料の未実装表記と判断024、current-implementationの旧生成記述、implementation-prioritiesのSecure Slot拡張経路、Hook Punchの実施範囲。今回は更新案の入口を記録し、仕様・コードの正本は変更していない。
- 過去の詳細検証ログと完了判断は保持。現在のStudio状態・公開先・GPU稼働・レビューHTMLの実表示は確認していない。今回の変更対象はこのWorkboardのみ。

### 棚卸し後のユーザー確認

2026-10-15、ユーザーがP0の4件をStudio確認済みと報告したため、上記棚卸し時点の「P0検証待ち」を更新してDoneへ移動した。マップ修正は新アセット等で再制作する方針により現行対応を解決扱いとする。再制作そのものの完成・設計確定・新アセット採用は意味しない。過去の未確認ログは当時の記録として残す。

## 目的

この文書は、開発中に人間が次に判断・確認すべき作業を一箇所で見るための実行キューである。ゲーム仕様、実装状況、判断理由、再発する障害の正本にはしない。

- 仕様・未決定事項の正本は `docs/world/`、`docs/systems/`、`docs/anomalies/` に置く。
- 採否と理由は `docs/decisions/` に置く。
- 実装優先順位と依存関係は [未実装機能の優先順位](systems/implementation-priorities.md) に置く。
- 再発する制作上の障害は [制作トラブルシューティング](production/troubleshooting.md) に置く。

本書には、上記の資料を実行可能な作業へ切り出したものだけを置く。アイデア段階のマップや、判断材料が不足した世界観上の案は `Parked` として扱い、実行キューへ混ぜない。

## 状態

| 状態 | 意味 | 次に動く人 |
| --- | --- | --- |
| `Inbox` | 発見済みだが、範囲・優先度・正本が未整理 | 人間またはCodex |
| `Needs Human` | 仕様、優先順位、権限、費用などの判断が不足 | 人間 |
| `Ready` | 対象と完了条件が揃い、作業指示を生成できる | 担当エージェント |
| `Blocked` | 実行を試みたが、環境・権限・依存作業で停止 | 障害を解消できる担当 |
| `In Progress` | 実行中。担当セッションと範囲を明記する | 担当エージェント |
| `Verify in Studio` | Git側の変更または設計は揃ったが、実プレースでの確認が未完了 | 人間またはStudio操作担当 |
| `Done` | 完了条件を満たし、正本へ結果を反映済み | なし |
| `Parked` | 価値はあるが、現時点では実行しない | 人間 |

`Ready` の項目だけをエージェントへの作業指示へ展開する。`Needs Human` を自動で実装へ進めない。

## 更新ルール

1. 作業の区切りで、担当者は状態、結果、残った判断を更新する。
2. 同じ原因の障害が2回発生した場合は、原因と回避策を [制作トラブルシューティング](production/troubleshooting.md) へ移す。
3. 設計採否が必要になった場合は `Needs Human` に戻し、決定後は該当する設計資料と必要に応じてDecision Logを更新する。
4. `Done` にする前に、正本への反映先を各項目に追記する。Studio確認が必要な変更は、確認前に `Done` にしない。

## 指示への展開

`Ready` の項目を作業指示にする際は、次のテンプレートを使う。

```text
目的:
対象:
正本・参照資料:
変更してよい範囲:
変更しない範囲:
完了条件:
検証方法:
Studio確認:
コミット／プッシュ:
不明点・エスカレーション条件:
報告形式:
```

このテンプレートは、判断が未完了の項目を実装へ誤って進めないための境界でもある。

## 詳細な検証ログ

過去の実施記録と当時の障害を保持する。現在の状態・次アクションは上部の実行キューを参照。2026-10-07の6Client検証の詳細は[Studio検証チェックリスト](production/studio-verification-checklist.md)を正本とする。

<a id="verification-log-1"></a>

### 検証ログ 1: 最小Runの複数Client検証

- [ ] **最小Runの複数Client検証**
  - 状態: `Verify in Studio`（2026-10-07: 旧Blocked5項目を解消。通常帰還の終了経路は残る）
  - 担当: Studio操作担当（要人間）
  - 最新結果（2026-10-07）: 6Clientで旧Blockedの項目1・2・4・5・6をPass（試した経路）。項目3も再確認。項目7は全参加者死亡・マップ破棄・次受付までPass。通常成功帰還／未達帰還の終了確認は残る。
  - 起動方法: `StudioTestService:ExecuteMultiplayerTestAsync(6, ...)`。各Clientは別studio_idで操作。過去の「人間のUI操作が必須」という前提は現在の環境では不要。
  - 次アクション（最新）: 通常成功帰還・未達帰還での終了と、別項目のリザルトUI・精算を確認する。以下のBlocker・次アクションは過去の経緯として残す。
  - 詳細: [2026-10-07の6Client実施記録](production/studio-verification-checklist.md)。コード変更・同期・ゲーム公開なし。テスト終了とEditへの復帰を確認済み。

  - 実施記録（2026-10-02）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「最小Run: 複数Client／Party Run」全7項目が未確認。`current-implementation.md` の既知未確認事項「複数人での挙動は未確認」はそのまま残る。コードは読み取りのみで変更していない。
    - OutputのError・Warning: なし（Studio未起動のため取得していない）
    - 残件と反映先: 全7項目の実プレース確認。`DEBUG 強制締切`プロンプトは `current-implementation.md` に「未配置で未確認」と記録があり、着手前に配置確認が必要。
  - 実施記録（2026-10-02・2回目）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションでもStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: 「複数Client／Party Run」全7項目が未確認のまま。`StudioMCP` は`opencode.json`に設定済みでバイナリも存在するが、2026-10-02T01:05Zの接続は `tools=0`、本セッション（01:56Z開始）には接続記録自体が無い。`StudioMCP` への直接stdioハンドシェイク（protocolVersion 2024-11-05 / 2025-06-18）も30秒間応答なし。`list_roblox_studios` が使えないためプレースの特定すらできていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照）
    - 残件と反映先: 全7項目。接続障害の詳細は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「検証環境の記録」にある。
  - 実施記録（2026-10-03・3回目）:
    - 日付: 2026-10-03
    - 対象コミット: `57e2c7a`（HEAD。`docs/` のみ）。**`src/` を最後に変更したコミットは `c74a276`**。従来の記録にある `b316d14` は `src/` を変更していないdocsコミットであり訂正が必要。
    - Studioプレースへ反映した内容: なし。**ただしプレース内7モジュール（`LobbyConfig` / `RunConfig` / `MapDrawConfig` / `PartyService` / `LobbyService` / `RunService` / `MapDrawService`）が `src/` とバイト一致することをlength・バイト和・位置重み付き和で照合した。** プレースは既に `c74a276` までを含む。同期操作自体は行っていない。
    - テスト環境: Play Solo（`start_stop_play`）。2回起動し、2回目は入力経路の回復を試すための再起動。
    - 参加Client数: **1**（目標2以上）
    - 実施者: 担当エージェント（Studio MCP経由。`tools>0` で接続済み）
    - 結果: **`Blocked`（項目1・2・4・5・6）／`Pass`（項目3・7）**
    - 観察事項:
      - 項目3「受付中にフィールド外へ出たプレイヤーが残らない」は `Pass`。`RunState=RECRUITING` 中にフィールド外へ出ると `RunState=IDLE`、`LobbyState=ENTRANCE`、参加者 `0 / 5`、看板「受付していません」へ戻り、次の受付を開始できた。
      - 項目7「全員終了後に生成マップが破棄され次のRunが開始できる」は条件付き `Pass`。唯一の参加者が終了すると `workspace.AnomalyDungeon` が消滅し `RunState=IDLE` へ戻り、再入域で新しい受付（30秒）が始まった。**ただし終了経路はハーネスによる落下死亡で、成功帰還・依頼未達帰還での確認はできていない。**
      - 項目4「途中参加拒否」は1Clientでは成立しない。唯一の参加者は常に `InDungeon=true` で、入口ロビーへ移動すると `RunService.Tick` の `KillY` 判定で死亡する（実際に確認）。進行中Runに居ないClientが必要。
      - 項目5「`DEBUG 強制締切`」は `Blocked`。Proンプト自体は配置済みだが（`Workspace.DungeonEntranceLobby.ForceClose`、`ActionText="受付を強制締切する"`、`ObjectText="DEBUG 強制締切"`、Editモードには無く `LobbyService` が実行時生成）、`FORCE_CLOSE` 分岐を起動できなかった。
      - **ワークボードの「`DEBUG 強制締切` プロンプトは未配置」という前提は誤りだった。** 実行時生成のため手動配置は不要。`current-implementation.md` の「未配置で未確認」も訂正してよい。
      - 1Clientでも確認できた付随事項: 受付開始（`RunState=RECRUITING` / `LobbyState=PARTY`）、参加者数と残り秒数の表示（フィールド看板・`EntranceBoard`）、30秒満了での `DEPARTING` → `ACTIVE`、Map抽選（1回目 `TSUTAYA` / 2回目 `AUGUST_31`、毎回別seed）、`Room` の実際の部屋名への更新。
      - `RunState` 属性はプレイヤー属性ではなく **`ReplicatedStorage.AnomalyState`（`Folder`）の属性**である。`current-implementation.md` の `AnomalyState:RunState` はこのパスを指す。
      - 死亡でRun終了した直後、キャラクタは都市ロビー（`-1600, 6.1, 50`）にいるのに `LobbyState` が `CITY` ではなく `ENTRANCE` だった。下記「未確認の論点」と同一の論点。
    - OutputのError・Warning: **ゲームのScript Error / Warningは0件**。Outputに残ったエラー2件は担当エージェントの `execute_luau` 診断スクリプトの失敗（`KeyboardEnabled is not a valid member of ProximityPrompt`、`attempt to index nil with '__keyProbe'`）であり、ゲームの不具合ではない。
    - 残件と反映先: 項目1・2・4・5・6の5項目。`current-implementation.md` の「複数人での挙動は未確認」は、人数上限・切断・途中参加・強制締切が未確認のまま残る。ツール障害は [制作トラブルシューティング](production/troubleshooting.md) へ記載。
  - Blocker理由: 複数Clientを起動できないこと。`start_stop_play` は `is_start` と `studio_id` のみを受け付け、Client数やサーバーモードの指定引数が存在しない。Studioの「Start Server and Players」の人数設定はStudioのUIにのみありMCPから変更できない（`roblox_studio` MCPはResourcesも公開していない）。Roblox APIにサーバー側での `Player` 生成方法が無いため、1人セッションから2人目を湧かせることも不可能。加えて、合成キーボード入力と `screen_capture` がセッション途中に途絶し、`DEBUG 強制締切` のProximityPromptを操作できなかった。
  - 次アクション: 人間がStudioのPlayテスト設定を「Start Server and Players / 2人以上」に変更したうえでPlayを起動する。2Clientで受付先着順と途中参加拒否、6Clientで上限5人、2Clientで切断を実行する。`DEBUG 強制締切` は受付開始直後にプロンプトを操作し、30秒を待たずに出発することと参加者だけが出発することを確認する。
  - 完了条件: [Studio検証チェックリスト](production/studio-verification-checklist.md) の「複数Client／Party Run」結果を記録し、不具合は本書またはトラブルシューティングへ切り出す。
  - 未確認の論点（2026-10-03追加）:
    - Runが死亡で終わった直後に、キャラクタは都市ロビーにいるのに `LobbyState` が `ENTRANCE` になる。`RunService.character()` の遅延 `lobby.SendToCity`（`CITY`）と、`PartyService` の0.25秒周期 `remove()`（`ENTRANCE`）の順序の競合が疑われる。都市ロビー滞在中に `ENTRANCE` が残る影響範囲は確認していない。**論点と判断候補は [020: Run終了後のLobbyStateと物理位置の同期](decisions/020-lobby-state-authority-and-physical-location.md) に記録した（判断未採用・要人間判断）。**
    - 影響は主として `RunController` の目的表示に限られ、受付ループは `LobbyState` ではなく `ReplicatedStorage.AnomalyState.RunState` を分岐条件にしているため受付機構は崩れない。
  - 正本: [現在の実装状況](systems/current-implementation.md)、[最小Runの範囲](decisions/005-minimum-lobby-run-scope.md)

<a id="verification-log-2"></a>

### 検証ログ 2: リザルトUIの実表示検証

- [ ] **リザルトUIの実表示検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当
  - 実施記録:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「リザルト／Inventory」全5項目が未確認。`src/` の読み取りのみで、サーバー送信値（`RunService.Finish`）とクライアント描画（`RunResultController`）の対応は静的に確認したにとどまる。コードは変更していない。
    - OutputのError・Warning: なし（Studio未起動のため取得していない）
    - 残件と反映先: 全5項目の実プレース確認。判断を要する論点は下記「未確認の論点」。
  - 実施記録（2026-10-02・2回目）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションでもStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: 「リザルト／Inventory」全5項目が未確認のまま。Studio MCPは2026-10-02T01:05Zの接続で `tools=0`、本セッション（01:56Z開始）には接続記録が無く、`StudioMCP` の直接stdioハンドシェイクも30秒間応答なし。下記「未確認の論点」の前提となる画面確認は開始できておらず、論点の解消には至っていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照）
    - 残件と反映先: 全5項目と下記「未確認の論点」。接続障害の詳細は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「検証環境の記録」にある。
  - Blocker理由: Studio MCPがツール0件で接続できず、Play／複数Clientを起動できない。Studio操作可能なセッションまたは人間が必要。
  - 未確認の論点（Studio表示前に仕様判断を要する可能性）:
    - 死亡失敗時、`RunResultController` は `ResetOnSpawn=false` なのでリザルト画面は保持される。一方サーバー側は `CharacterAdded` の `character()` で `M.Reset(p)` と `lobby.SendToCity(p)` を実行する（`RunService.luau:239-241`）。このため「死亡リザルト表示中も都市ロビーへ移動済みの状態」になる可能性がある。死亡リザルトを保持したいか、それとも成功時のみResultへ留めるwantは未定義。`LobbyState=RESULT` と物理位置のどちらを優先するかの判断が必要。
    - 失敗時の `Gained` / `Lost` は `Inventory.Settle(p, success)` の実装に依存する。Secure Slotのみ残す仕様が実装と一致するかはStudio未確認。
  - 再現手順（Studio操作担当が実行）:
    1. `src/` をStudioプレースへ反映し、反映経路と対象コミットを記録する。
    2. Play Soloで都市ロビーへ入り、`DUNGEON ENTRANCE` で入口ロビー、`PartyField` に入る。
    3. 成功経路: Map条件を解除して出口ポータルから帰還する。リザルト画面で獲得物・Quest達成状況・Credits変化・インベントリ／Secure枠表示を確認する。
    4. 失敗経路: Run中に死亡させる（落下 或 泉の毒）。死亡直後のリザルト画面、喪失物表示、画面保持と都市ロビー位置を確認する。
    5. いずれの画面でも「都市ロビーへ戻る」を押し、`LobbyState` が `CITY` へ戻り次の受付_buffを開始できることをOutputと 属性で確認する。
    6. リザルト表示中にスキルとDashを試み、実行されないことを確認する。
    7. 空の獲得物・喪失物が「なし」と表示されることを確認する。
  - 完了条件: [Studio検証チェックリスト](production/studio-verification-checklist.md) の「リザルト／Inventory」5項目にPass／Failを記録し、不具合は本書またはトラブルシューティングへ切り出す。
  - 正本: [現在の実装状況](systems/current-implementation.md)、[最小Runの範囲](decisions/005-minimum-lobby-run-scope.md)

<a id="verification-log-3"></a>

### 検証ログ 3: 8月31日景観変更のStudio検証

- [ ] **8月31日景観変更のStudio検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当（要人間）
  - 実施記録（2026-10-02）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「8月31日: 景観・フェーズ」全5項目が未確認。`008` の「検証が必要な事項」5項目も未確認のまま。DAY／EVENING／NIGHT／AUG_32の遷移確認は実プレースを起動できないため着手できていない。`StudioMCP` は2026-10-02T01:05Zの接続で `tools=0`、本セッション（01:56Z開始）には接続記録が無く、直接stdioハンドシェイク（protocolVersion 2024-11-05 / 2025-06-18）も30秒間応答なし。`list_roblox_studios` が使えないため、Gitの`src/`とStudioプレースの反映関係の確認にも着手できていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照。ゼロであることは意味しない）
    - 残件と反映先: 全5項目。復旧手順は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「復旧後に必要な手順」を参照。
  - 備考: 本項目には本セッションのほかに実施記録が無い。上記が最初の記録である。
  - Blocker理由: Studio MCPがツール0件で接続できず、Playを起動できない。Gitソースとプレースの反映関係の確認にもStudio操作を要する。Studio再起動は破壊的な操作のため、勝手に試行せず人間に委ねる。
  - 次アクション: Trail、Prompt、カメラ、移動、8/32遷移、負荷とStreamingを実プレースで確認する。
  - 完了条件: [008](decisions/008-august-31-landscape-composition.md) の検証事項を記録し、GitソースとStudioプレースの反映関係を確認する。
  - 正本: [008: 8月31日の景観構成](decisions/008-august-31-landscape-composition.md)

<a id="verification-log-4"></a>

### 検証ログ 4: TSUTAYA「閉店直後のアーカイブ」改修のStudio検証

- [ ] **TSUTAYA「閉店直後のアーカイブ」改修のStudio検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当（要人間）
  - 実施記録（2026-10-02）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「TSUTAYA: 閉店直後のアーカイブ」全5項目が未確認。`009` の「検証が必要な事項」5項目も未確認のまま。棚追加のPart数・PointLight数・負荷は実プレースを起動できないため計測できていない。`StudioMCP` は2026-10-02T01:05Zの接続で `tools=0`、本セッション（01:56Z開始）には接続記録が無く、直接stdioハンドシェイク（protocolVersion 2024-11-05 / 2025-06-18）も30秒間応答なし。Archive Shelf／CRT／試聴／出口端末の操作可否確認にも着手できていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照。ゼロであることは意味しない）
    - 残件と反映先: 全5項目。復旧手順は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「復旧後に必要な手順」を参照。
  - 備考: 本項目には本セッションのほかに実施記録が無い。上記が最初の記録である。
  - Blocker理由: Studio MCPがツール0件で接続できず、Playを起動できない。Gitソースとプレースの反映関係の確認にもStudio操作を要する。Studio再起動は破壊的な操作のため、勝手に試行せず人間に委ねる。
  - 次アクション: 背表紙、小物、照明が通路、Prompt、Raycast、移動、負荷を阻害しないか確認する。
  - 完了条件: [009](decisions/009-tsutaya-closing-time-archive.md) の検証事項を記録し、必要なら改修案を `Inbox` として追加する。
  - 正本: [009: TSUTAYAを「閉店直後のアーカイブ」として再構成する](decisions/009-tsutaya-closing-time-archive.md)
