# 020: Run終了後のLobbyStateと物理位置の同期

**Status: Draft（論点の記録・要人間判断）**
**Date: 2026-10-03**

本記録は**採用した判断を含まない**。2026-10-03のStudio検証（Play Solo、1人セッション）で観察された不整合と、その背景にあるコード上の複数の書き込み経路を記録し、判断が必要な論点を明示する。解決案は本章の「判断候補」に留め，どれも採用していない。

## 背景

[006: 最小Runの実装で確定したサーバー境界](006-minimum-run-server-boundaries.md) は「プレイヤーのロビー帰属は `LobbyState` 属性で持つ。都市ロビー、入口ロビー、パーティ受付中、探索中、リザルト、の5値」と決めた。値の実体は `ReplicatedStorage/AnomalyDungeon/Shared/Config/RunConfig.luau` の `LobbyCity` / `LobbyEntrance` / `LobbyParty` / `LobbyRunning` / `LobbyResult` である。

2026-10-03の1人セッションで、落下死亡によりRunが終了した直後に下列の同時成立が観察された。

- キャラクタの物理位置: 都市ロビーのスポーン地点（`-1600, 6.1, 50`）
- プレイヤーの `LobbyState`: `ENTRANCE`（`CITY` ではない）

## 確認できた事実

下列はコードと2026-10-03の観測の両方で確認できた事実である。

- `RunService.Finish` は参加者に対して `LobbyState=RESULT` を設定する（`RunService.luau:72`）。
- `Finish` 内の移動は `h.Health>0` のときだけ `LobbyService.Teleport(p,'Result')` を呼ぶ（`RunService.luau:75`）。**死亡時は呼ばれない。**
- 一方 `RespawnLocation` は `lobby.GetCitySpawn()` が設定されている（`RunService.luau:238`）。したがって死亡時、キャラクタは `LobbyState=RESULT` のまま都市ロビーに出現する。
- `RunService` の `character()` は `M.Reset(p)` と遅延 `lobby.SendToCity(p)` を行うが（`RunService.luau:239-241`）、`LobbyState` 自体には触れない。`SendToCity` は `LobbyState=CITY` を書く（`LobbyService.luau:214-217`）。
- `PartyService.remove()` は退出者を `LobbyState=ENTRANCE` にする（`PartyService.luau:46`）。**この値は物理位置や所在ロビーへの帰属を一切参照しない。**
- `PartyService` の受付ループは0.25秒周期（`TICK=0.25`、`PartyService.luau:17,145-160`）で、`RunState` が `IDLE` / `RECRUITING` の間は在圏者へ `add`、非在圏者へ `remove` を呼ぶ（`PartyService.luau:95-103`）。
- `RunService.CloseRun` によるMap破棄は `PartyService` 側の受付状態を持たない。Run状態が `IDLE` へ戻った直後、次のループで元の参加者が `remove` される。

以上から、死亡→リスポーンと `remove()` の `ENTRANCE` 書き込みが競合し、`task.defer` 側の `CITY` が後勝ちになり **`ENTRANCE` が残る**と推測できる。**この競合の順序依存自体は未確認である（`Unconfirmed`）。** 観測は1回のみで、意図的に競合を発生させた記録ではない。

## 影響

- `LobbyState` は `StarterPlayer` 側の `RunController` が目的表示の切り替えに参照する。値が誤っていると「都市ロビーへ」「入口ロビーへ」の誘導先が実位置と食い違う。
- **影響は主としてUI層に限定される。** 受付ループは `LobbyState` ではなく `ReplicatedStorage.AnomalyState.RunState` を分岐条件にしており（`PartyService.luau:96`）、受付の開始・終了・上限判定は `LobbyState` の取り違えでは崩れない。`SkillService` / `SkillController` も `RunResultPending` でゲートしており `LobbyState` を見ていない。
- したがって現段階の深刻度は「案内表示が誤る」に分類される程度であり、受付機構の破壊ではない。ただし `LobbyState` を正本として参照する機能（複数Client受付、`LobbyState` に基づくRun侵入認可、切断時処理）が実装される前景に、食い違いが残る状態は望めない。

## 判断が必要な論点

いずれも未決であり、代行で埋めていない。

1. Run終了から次の受付開始まで、`LobbyState` の正本は物理位置か属性か。属性を正本とするなら、リザルト表示を保持する都市ロビー滞在中は何値を保つのか。
2. 死亡でRunが終了したとき、リザルト画面を表示したまま保持すべきか、それとも都市ロビーへ戻してよいか。保持するなら `LobbyState` は `RESULT` のまま都市ロビー위에立たせることになる。
3. `PartyService.remove()` は「パーティ受付の退出」を扱う処理と「ロビー帰属の更新」を1つの関数で担う形になっている。`ENTRANCE` を書く責務を `RunService` / `LobbyService` 側へ移すか否か。
4. 004（都市入口）で決める入口提示と、006 で決めた5値との関係をどこで確定させるか。

## 判断候補（いずれも未採用）

判断材料として、コードから自然に導かれる3案を挙げる。**この3案の優劣は判断していない。** 採用は人間が行う。

- 案A（単一 writer）: `LobbyState` の書き込みを `RunService` に集約し、`PartyService` は「受付への希望」を通知するにとどめる。`remove()` の `ENTRANCE` 書き込みをなくし、`RunState` が `IDLE` へ戻った時点で参加履歴を破棄する形になる。責務は明確になるが、`PartyService` から `RunService` への依存が増える。
- 案B（物理位置を正本）: `LobbyState` を導出値とし、`LobbyService.IsInPartyField` と同種の位置判定を基準に再計算する。同期的な食い違いが原理的に起きないが、リザルト表示を保持する都市ロビー上の状態を `CITY` と区別できなくなる。論点2の判断が前提になる。
- 案C（局所修正）: 変更範囲を最小にし、`character()` が `LobbyState` を必ず `CITY` へ確定したうえで、例外として `RunResultPending=true` の間だけ `RESULT` を優先する。案Aと案Cが混在するため、後続の受付機構の実装で亀裂が生じやすい。

## 検証が必要な事項

- 死亡でRunが終了した直後に `LobbyState` が何になるかを1人セッションで再確認し、競合順序を固定するか、記録する。
- 成功帰還・依頼未達帰還では `RESULT` → `RunResultPending` 解除後の `CITY` へ正しく戻るか。**2026-10-03には未確認**（自然帰還での到達に失敗したため）。
- 2人以上のRunで、参加者が残り1人である場合に死亡者の `LobbyState` の更新が他参加者の受付へ影響しないか。
- `LobbyState` を参照するUIが、この不整合のもとで誤った誘導をどの頻度で見せるか。

## 未決事項

- 論点1〜4はいずれも[開発ワークボード](../workboard.md) の「最小Runの複数Client検証」「リザルトUIの実表示検証」からのエスカレーションであり、人間が仕様判断をする必要がある。`Needs Human` のまま据え置く。
- コード変更は行っていない。修正の着手はいずれの案も、この判断の確定後である。

## 関連資料

- [現在の実装状況](../systems/current-implementation.md)
- [Studio検証チェックリスト](../production/studio-verification-checklist.md)
- [開発ワークボード](../workboard.md)
- [006: 最小Runの実装で確定したサーバー境界](006-minimum-run-server-boundaries.md)
- [004: 都市入口と情報提示の設計方針](004-city-entry-and-information-design.md)
- 実装領域: `ServerScriptService/AnomalyDungeonServer/Services/RunService.luau`、`Services/PartyService.luau`、`Services/LobbyService.luau`、`ReplicatedStorage/AnomalyDungeon/Shared/Config/RunConfig.luau`、`StarterPlayer/StarterPlayerScripts/AnomalyDungeonClient/UI/RunController`