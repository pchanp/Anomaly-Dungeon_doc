# Effect記述契約 v0.1

**Status: Draft（ブレストの記録形式。共通ゲーム仕様の正本はsnapshotのeffect-components.md）**

結果のEffect種別は `Damage`、`Heal`、`StateChange`、`Move`、`InformationChange`、`WorldChange`、`RuleOverride` の7種。Observation、Sound、Item、Skill、Combat、Environment等は入力・接続タグであり、結果のEffect種別とは別。

一つの候補が複数Effectを持つなら `effects` に別々に書く。即時Damageと持続StateChangeの終了条件・保存境界を一行でまとめない。

| 項目 | 記載内容 |
| --- | --- |
| `trigger` | 何の行為／イベントを起点にするか |
| `condition` | 状態・距離・所持・時間等の成立条件。未定数値は未定と書く |
| `kind` / `result` | 7種のいずれかと実際の変化 |
| `target` / `scope` | 誰／何へ作用し、個人・Party・Run等のどこへ反映するか |
| `lifetime` | `永続`、`同一Run中`、`同一マップ中`、`一時` |
| `resolution` | `instant` / `sustained` |
| `end_conditions` | 即時なら適用解決、持続なら解除。マップ／Run終了、切断等の扱いも説明 |
| `end_mode` | 複数終了条件は既定で `any`。例外なら `explicit_exception` と理由 |
| `stacking` | 即時はイベントごと、持続同一Effectは非加算1件。固定秒数の再適用は残り時間更新。例外は理由・対象を明示 |
| `server_validation` | Serverが確認する距離・状態・対象・権限と、不成立時の扱い |
| `client_presentation` | 個人提示と共有結果を分けた表現 |
| `feedback` | 成功・失敗・不明それぞれの手掛かり |

異なるEffectが同じ値・行動・世界状態へ競合するときは自動合算／後勝ちにせず、解決規則がなければ適用保留を記録する。今回のJSONでEffect IDは定義しない。候補IDとEffectの配列位置はブレスト記録の識別だけに使う。

WorldChangeで出現率・同時出現数に作用するなら、個人所持とServerのRun状態、Run終了時の破棄、博士Quest補正／発生回数減衰との競合を記す。RuleOverrideは対象の通常結果と優先順位を説明し、無制限の受け皿にしない。

`requires_code` はtrue / false / `unknown`。trueは新規実装の必要性を表すだけ。falseは必要な全経路が存在する根拠がある場合。動的なNPC／状態処理／報酬経路を、外見や既存Promptがあるだけでfalseにしない。未確認ならunknownと不足根拠を残す。

components.jsonのIDはこのパックの語彙であり、StudioのComponent IDや実装Serviceを保証しない。未掲載の機能は `availability: proposed` として必要性を書き、夜間に実装・カタログ追加しない。
