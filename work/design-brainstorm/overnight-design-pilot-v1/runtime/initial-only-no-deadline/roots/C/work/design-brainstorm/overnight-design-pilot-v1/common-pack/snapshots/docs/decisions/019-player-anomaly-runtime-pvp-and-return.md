# 019: Player Anomalyの単独発生、PvP、固有帰還

**Status: Accepted（採用済み）**
**Date: 2026-10-02**

## 背景

Player Anomalyを単なる即時失敗や、通常プレイヤーの上位形態にはせず、通常の協力ルールを崩す一時的な高リスク・高リターン状態として扱う。そのため、同時発生数、Exposure閾値超過後の扱い、PvP、帰還経路を共通ルールとして定める。

## 決定

- 1 Runで同時に存在できるPlayer Anomalyは1人までとする。
- 先行するPlayer Anomalyが存在する間に他の通常プレイヤーがExposure閾値を超えても、直ちにアノマリー化させない。先行者が死亡または帰還してランから退場した時点で、閾値超過済みの待機者から次の1人をアノマリー化する。
- サーバーはExposure閾値を先に超えた順で待機キューを保持し、先行Player Anomalyの退場時には先頭の待機者を次のPlayer Anomalyにする。
- 通常プレイヤー同士には、対象HPが最大HPの80%未満にならないPvP下限を常に適用する。
- 通常プレイヤーとPlayer Anomalyの組み合わせではPvP下限を双方に適用しない。両者は相手をキルできる。
- Player Anomalyは通常NPCおよび通常のReturn PortalとInteractionできない。Anomaly EntityがPlayer Anomalyへ示す反応は個別アノマリーで定め、攻撃性の喪失と過度な攻撃性の双方を許容する。
- Player Anomalyごとに固有Runtimeを開始する。通常攻撃は専用スキルへ変化し、固有Interactionを成功させれば専用のReturn Portalが出現する。
- 専用Portalから帰還した場合は、当該専用スキルに由来する、基本的には制限版のスキルをRun終了時に獲得する。
- Runtime満了まで生存した場合は通常のReturnと同じ処理で帰還する。

## 判断理由

同時発生を一人に限ることで、通常プレイヤー同士の協力・資産管理・Quest進行を別ゲームモードへ変質させない。待機を導入することで、Exposure閾値を超えた状態を無効化せず、先行者の退場後にもランの緊張を残す。

通常プレイヤー同士の安全下限は協力探索の基盤として維持する。一方、Player Anomalyとの間だけ相互キルを可能にすることで、アノマリー化が実際の対立と固有帰還判断を伴う状態になる。固有PortalとRuntime満了を並置し、危険な固有Interactionへ挑戦する選択と、生存を優先して通常帰還を待つ選択を作る。

## 影響

- Run Stateには、同時Player Anomaly、Exposure閾値超過順の待機キュー、各Player Anomaly Runtime、固有Portalの状態をサーバー権威で保持する必要がある。
- Combatは攻撃者だけではなく、攻撃者・対象の通常／Player Anomaly組み合わせでHP下限を判定する必要がある。
- 個別Player Anomaly資料は、Runtime、専用攻撃、固有Interaction、Portal出現条件、制限版スキルを定義できる。
- 現行の`TRANSFORMED_TIMEOUT`失敗処理は暫定実装であり、この判断をまだ反映していない。

## 未決定事項

- 待機状態の通知UIと、待機中に切断したプレイヤーのキュー処理。
- 専用Portal帰還とRuntime満了を、Quest、通常資産、Secure Slot、基本報酬の成功／失敗判定へどう接続するか。
- 各Player AnomalyのRuntime長、専用攻撃、固有Interaction、Portal条件、獲得する制限版スキル。
- Player Anomalyへのキル時の報酬、ペナルティ、リスポーンまたは観戦の扱い。

## 関連資料

- [ゲームループとポータル遷移](../systems/game-loop.md)
- [ゲームルール](../systems/game-rules.md)
- [現在の実装状況](../systems/current-implementation.md)
- [001: ゲームループとポータル遷移の設計方針](001-game-loop-and-portal-transitions.md)
