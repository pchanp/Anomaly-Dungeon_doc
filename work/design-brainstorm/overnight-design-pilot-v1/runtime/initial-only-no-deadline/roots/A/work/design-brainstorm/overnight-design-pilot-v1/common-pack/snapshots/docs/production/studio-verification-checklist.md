# Studio検証チェックリスト

**Status: Draft（最小Runとマップ改修向け）**
**更新日: 2026-10-03**

## 目的

Gitの`src/`とRoblox Studioの実プレースは自動同期されない。このチェックリストは、Git側の変更をStudioへ反映した後に、何を確認したか・何が未確認かを記録するための共通手順である。

これはゲーム仕様や不具合台帳の正本ではない。検証結果は、該当する設計資料、[開発ワークボード](../workboard.md)、または[制作トラブルシューティング](troubleshooting.md)へ反映する。

## 実施記録

検証ごとに以下を記録する。

```text
日付:
対象コミット:
Studioプレースへ反映した内容:
テスト環境: Play Solo / Start Server + Players / 実機
参加Client数:
実施者:
結果: Pass / Fail / Blocked
観察事項:
OutputのError・Warning:
残件と反映先:
```

数値のフレームレート目標や品質閾値は未決定である。負荷を確認した場合は、操作可能性、見通し、Streamingの挙動、発生した警告を観察事項として具体的に残す。

## 検証環境の記録

Studioを操作できない場合、推測で `Pass` にせず、接続状態と試行内容をここへ残す。

### 2026-10-03: Studio MCPが復旧。複数Clientは起動できず、1Clientで2項目のみ検証

- 日付: 2026-10-03
- 対象コミット: `57e2c7a`（HEAD。`src/` ではなく `docs/` のみの変更）。**`src/` を最後に変更したコミットは `c74a276`**（`fix: build the dungeon off the party reception thread`）。
- テスト環境: Play Solo（`start_stop_play`）。2回目のセッションは入力経路の回復を試すため、1回目を停止してから再起動した。
- 参加Client数: **1**（目標2以上）
- 実施者: 担当エージェント（Studio MCP経由）
- 結果: **`Blocked`（5項目: 1・2・4・5・6）／`Pass`（2項目: 3・7）**。項目別の根拠は下記「複数Client／Party Run の実施結果」。

#### 記録の訂正

これまでの実施記録は対象コミットを `b316d14` としているが、`b316d14` は `docs: add whisper anomaly design` で `src/` を変更していない。検証対象のコードは `c74a276` までを含む。対象コミットの記載は `c74a276` へ訂正する。

#### Studio MCPの状態（復旧した記録）

- `Roblox_Studio` MCPは **ツール公開済みの状態で接続していた**。2026-10-02の `tools=0` 障害は本セッション時点で解消している。
- 開いているプレースは **「異変のダンジョン」（placeId 99417611378273）**。`Edit` / `Client` / `Server` の全DataModelが利用可能。
- 使用したツール: `list_roblox_studios` / `get_studio_state` / `start_stop_play` / `execute_luau` / `inspect_instance` / `search_game_tree` / `script_read` / `character_navigation` / `get_console_output`。

#### 複数Clientを起動できなかった理由（再現可能）

`start_stop_play` は `is_start` と `studio_id` のみを受け付ける。**Client数やサーバーモードの指定引数が存在しない。** 実行するとStudioの現在のテスト設定（既定はPlay Solo）がそのまま適用される。

- 観測: `start_stop_play(true)` 直後の `Players:GetPlayers()` は **1人**（`amaiking32`）。利用可能DataModelは `Client` と `Server` のみで、Clientは1つしか公開されない。
- Studio側の「Start Server and Players」の人数設定はStudioのUIにのみ存在し、MCPから変更する手段がない。`roblox_studio` MCPはResources / ResourceTemplates も公開していない（`list_mcp_resources` は `does not support resources` を返した）。
- サーバー側に `Player` インスタンスを生成する Roblox API は存在しないため、1人セッションから2人目を湧かせることはできない。

したがって、人数に依存する項目（①先着順、②上限5人、④途中参加拒否、⑥切断）は本セッションでは**検証不能**である。

#### セッション中に発生したツール側の障害

- **合成キーボード入力が途中から届かなくなった。** 開始直後は `user_keyboard_input` の `keyDown`/`keyUp`（`HoldDuration=0.35` に対応）で `DUNGEON ENTRANCE` の ProximityPrompt が実際に発火した。以降は `E`、`LeftShift` のいずれも効果なく、クライアント側に `UserInputService.InputBegan` の計測フォルダを立ててもイベントが1件も届かなかった。
- **`screen_capture` が `MCP error -32001: Request timed out` を返し、回復しなかった。** Playの停止・再起動後も同様。`user_mouse_input` もタイムアウトした。
- 一方、`execute_luau`（Server / Client / Edit）、`character_navigation`、`get_console_output`、`get_studio_state` は終始応答した。
- 推測: Studioウィンドウの入力フォーカスとビューポート取得が失われた状態。**原因未確定（`Unconfirmed`）。** ProximityPrompt の発火確認は `screen_capture` が使えないため画面表示側からも確認できなかった。

#### テスト前の既存状態（結果の誤認回避）

- **Play開始前から `Workspace.AnomalyDungeon` が空の `Model`（`Seed=92026`、`descendants=0`）として存在した。** セッション最初のEdit時inspectionで既にあり、本セッションの操作で作成したものではない。
- `CityLobby` / `DungeonEntranceLobby` / `DebugFloor` はEditモードには存在せず、すべて `LobbyService` / `DebugFloorService` が実行時に生成する。`DebugMapSwitch` 読み込みのMapもPlay開始時は存在しなかった。
- Play停止後にEditモードを再確認し、`ReplicatedStorage.KeyProbe` 等のハーネス残骸がないこと、上記の実行時モデルがEditモードに残っていないことを確認した。

#### 共通事前確認の結果

- 対象コミットと変更ファイル: **充足**（`57e2c7a` / `src/` は `c74a276`）。ただし従来の `b316d14` 表記は訂正が必要。
- `src/` をプレースへ反映した経路: **未記録**。本セッションは同期を行っていない。代わりに、プレース内7モジュールが `src/` と**バイト一致**することを確認した（`LobbyConfig` 1291、`RunConfig` 1209、`MapDrawConfig` 456、`PartyService` 5877、`LobbyService` 10246、`RunService` 16212、`MapDrawService` 1517。長さ・バイト和・位置重み付き和がすべて一致）。したがってプレスは既に `c74a276` までの内容を含む。ただし反映操作の経路そのものは未記録のままである。
- Outputの確認: **充足**（下記）。
- テスト前の既存生成物・デバッグ状態: **充足**（上記）。

#### OutputのError・Warning

**ゲームのScript Error / Warningは発生していない。** 2セッションの `get_console_output` に現れたのは次の初期化ログのみである（`[LOBBY] city + dungeon entrance ready` / `[ANOMALY] Prototype ready` / `[SKILL SERVER] ready enhanced` / `[LOBBY LINK] disabled` / `[DEBUG FLOOR] ready at 1200, 1000, 0` / `[GIANT VISUAL] textured skinned model attached 28` / `[GIANT CLIENT] ready` / `[SKILL CLIENT] ready` / `[ARCHIVE UI] ready` / `[RUN RESULT] ready` / `[GIANT ANIMATION CLIENT] playing 49 bones 71` / `Walk animation made by @Zarubkin !` x2 / `[DEBUG] inventory terminal ready`）。

Outputに記録されたエラー2件は、**いずれも担当エージェントが `execute_luau` で動かした診断用スクリプトの失敗であり、ゲームの不具合ではない**。

- `KeyboardEnabled is not a valid member of ProximityPrompt "Workspace.DungeonEntranceLobby.ForceClose.ProximityPrompt"`（Script `AssistantCommand`, Line 7）
- `attempt to index nil with '__keyProbe'`（Script `AssistantCommand`, Line 17。1回目のセッション）

#### `DEBUG 強制締切` プロンプトの配置に関する訂正

ワークボードは「`DEBUG 強制締切` プロンプトは未配置で未確認」と記録していた。実プレースでは**配置済みである**。

- 実体: `Workspace.DungeonEntranceLobby.ForceClose` 内の `ProximityPrompt`。`ActionText="受付を強制締切する"`、`ObjectText="DEBUG 強制締切"`、`Enabled=true`、`HoldDuration=0.35`、`MaxActivationDistance=12`、`RequiresLineOfSight=false`、`ClickablePrompt=true`、親に属性 `DebugOnly=true`。
- **Editモードのプレースには `DungeonEntranceLobby` 自体が存在しない。** このプロンプトは `LobbyService` の `buildEntrance` が実行時に生成するものであり、手動配置は**不要**である。`current-implementation.md` の「未配置で未確認」は解消してよい。
- ただし `PartyService` 側の `FORCE_CLOSE` 分岐（受付を即時終了して参加者だけを出発させる）は未実行であり、`Pass` にはしていない。

### 複数Client／Party Run の実施結果（2026-10-03）

| # | 項目 | 判定 | 根拠・制約 |
| --- | --- | --- | --- |
| 1 | 2人以上でPartyFieldへ入り、先着順で参加できる | `Blocked` | 2人目のClientを起動できない。先着順のコード（`PartyService.add` の `table.insert(order,player)`）は未実行。 |
| 2 | 6人目は上限5人を超えて参加できない | `Blocked` | 6Client必要。`LobbyConfig.PartyMax=5` はプレース内の実物とバイト一致で存在することを確認しただけで、上限判定の実行は未確認。 |
| 3 | 受付中にフィールド外へ出たプレイヤーが、出発参加者に残らない | **`Pass`** | `RunState=RECRUITING` 中にフィールド外（`Z=60`、半径35の判定外）へ移動すると、`ReplicatedStorage.AnomalyState.RunState` が `IDLE` へ戻り、プレイヤーの `LobbyState` は `ENTRANCE` へ戻り、フィールド看板は「参加者 0 / 5 / 受付していません」(`/EntranceBoard` は「Run状態: IDLE」) へ戻った。 |
| 4 | 締切後にフィールドへ入ったプレイヤーは進行中Runへ途中参加できない | `Blocked` | 1Clientでは検証できない。唯一の参加者は常に `InDungeon=true` であり、入口ロビー（`Y≈0`）へ移動すると `RunService.Tick` の `if r.Position.Y<current.KillY then h.Health=0 end` に当たり死亡する。実際に試して死亡・Run終了となった。進行中Runに居ないClientが必要。 |
| 5 | `DEBUG 強制締切` が受付を即時に終了し、参加者だけを出発させる | `Blocked` | プロンプトの入力が合成できない。`HoldDuration=0.35` 必要な `keyDown`/`keyUp` が途中で届かなくなった（上記）。`StartRun` は `FORCE_CLOSE` 時に `出発 / <Map名> / 強制締切` を通知するが、`reason` はサーバー上に記録されない（`RunService.luau:169`）ため、事後に `TIME_UP` と区別する手段も無い。 |
| 6 | Run中または結果表示中の切断で、残った参加者のRun状態が不整合にならない | `Blocked` | 切断される2人目のClientが必要。 |
| 7 | 全参加者の終了後に生成マップが破棄され、次のRunが開始できる | **`Pass`（条件付き）** | 唯一の参加者が終了した直後、`workspace.AnomalyDungeon` は `descendants=nil` へ消滅し、`RunState` は `IDLE` へ戻り、フィールド看板は「受付していません」(`/EntranceBoard` は「Run状態: IDLE」) へ戻った。その後にフィールドへ入ると新しい受付が `RunState=RECRUITING` /「参加者 1 / 5 / 受付中 / 残り 30 秒」で開始した。**ただし終了経路は通常の帰還ではなく、ハーネスが参加者を入口ロビー（`Y=5`、August_31の `KillY` 未満）へ移動させたことで発生した落下死亡（`RunOutcomes.DEATH`）である。** 成功帰還・依頼未達帰還での確認はできていない。 |

#### 1Clientで併せて確認できた事項（複数Client必須の項目ではない）

- 受付開始: `PartyField` の範囲判定はXZ寸法とY許容のpolled判定（`TICK=0.25`）で、フィールド内へ入ると `RunState=RECRUITING`、プレイヤーの `LobbyState=PARTY` となった。
- 受付表示: フィールドの `BillboardGui` は「PARTY FIELD / 参加者 1 / 5 / 受付中 / 残り N 秒」、`EntranceBoard` は「参加者 1 / 5 / 受付締切まで N秒」を表示した。秒数は減少していく。
- 30秒締切: 残り秒数が尽きると `DEPARTING` → `ACTIVE` へ進み、生成されたMapへ参加者が移動された。例外なし。
- Map抽選: 1回目のRunは `TSUTAYA`（`descendants=484`、`Seed=82657`）、2回目は `AUGUST_31`（`descendants=14007`、`Seed=75394`）。毎回異なるseedで作り直されている。
- Run突入後の属性: `LobbyState=RUNNING`、`InDungeon=true`、`QuestState=ACTIVE`、`Room` が実際の部屋名（`02 / VHS 試写室`、`01 / 県道沿い / 夕方の坂`）へ更新される。
- `RunState` 属性の実体はプレイヤー属性ではなく **`ReplicatedStorage.AnomalyState`（`Folder`）の `RunState` 属性**。`current-implementation.md` の `AnomalyState:RunState` という表記はこのパスを指す。プレイヤー側の `GetAttribute("RunState")` は常に `nil` になる。

#### 追加で出た観察事項（未解決）

死亡でRunが終了した直後、キャラクタは都市ロビーのスポーン地点（`-1600, 6.1, 50`）にいるのに **プレイヤーの `LobbyState` は `CITY` ではなく `ENTRANCE` になっていた**。`RunService.character()` が `task.defer` で `lobby.SendToCity`（`LobbyState=CITY`）を呼ぶのに対し、`PartyService` の0.25秒周期ループが `remove()` で `LobbyState=ENTRANCE` を上書きするため、実行順序が競合している可能性がある。`[開発ワークボード](../workboard.md)` の「リザルトUIの実表示検証」の「未確認の論点」（`LobbyState` と物理位置のどちらを優先するか）と同一の論点に属する。

#### 残件と反映先

- 項目1・2・4・5・6: 複数Clientを起動できる環境で再検証が必要。1Clientで代替できない項目を含む。
- `current-implementation.md` の「複数人での挙動は未確認」のうち、受付の離脱とRun終了後のマップ破棄のみ解消。人数上限・切断・途中参加・強制締切は未確認のまま。
- `current-implementation.md` の「`FORCE_CLOSE` はデバッグ用プロンプトが未配置で未確認」のうち「未配置」の部分は解消（実行時生成のため配置不要）。実行確認は未了。
- ツール障害（Client数指定の不可、入力と画面取得の途絶）: [制作トラブルシューティング](troubleshooting.md) へ記載。

2026-10-02の記録は以下。

### 2026-10-02（追記）: Studioと残存StudioMCPの再起動後も tools=0

- 日付: 2026-10-02
- 対象コミット: `b6f1116`（HEAD。`tools/forest-ferrets/` のみの変更で、ゲームの`src/`には無関係。`src/`と本チェックリスト系を最後に変更したコミットは `b316d14`）
- 実施内容: 人間側がRoblox Studio本体と残存していた`StudioMCP`プロセスを再起動した。接続の再初期化と利用可能ツール数の確認を要請された。
- 結果: `Blocked`。**再起動では解決せず、依然として `tools=0`。** P0の検証には着手していない。
- 備考: 本セッション中に無関係なコミット `b6f1116` が追加された。作業対象は`src/`と`docs/`であるため検証範囲は変わらないが、着手時はHEADを改めて確認すること。

#### 再起動後に観測した事実

- Roblox Studio本体は新規PIDで再起動している（`54590` → `56332`）。
- 再起動直前に残っていた9個の`StudioMCP`プロセスは消えている。観測時点では`StudioMCP`プロセスは1つも動作していない。
- opencodeの自動再接続は2026-10-02 02:05Z / 03:06Z / 04:07Zと1時間間隔で試行され、**すべて `tools=0`（各約10.0〜10.1秒）** であった。再起動後（04:10Z以降）の成功記録は無い。
- 2026-10-02T04:17:47Z に `MCP connection closed` server=Roblox_Studio が記録され、それ以降の再接続は発生していない。
- 新規に起動したStudioに対して `StudioMCP` を単独起動し、MCP stdioハンドシェイク（`Content-Length` フレーミング、`initialize` → `notifications/initialized` → `tools/list`、`protocolVersion` 2025-06-18）を送信した結果、**45秒間 stdout / stderr ともに1バイトも出力されなかった**。再起動前の30秒プローブと同じ挙動である。
- 本セッションから呼び出し可能なのは、ローカルファイル操作、Git参照、Web検索、およびHappierのセッション管理MCPのみ。`Roblox_Studio`名前空間のツールは依然として1件も公開されていない。

#### 再発防止の記録

Studio本体の再起動と残存`StudioMCP`の終了は、2026-10-02に一度試行されたが**効果 はなかった**。次に同じ障害へ到達したセッションは、再起動を繰り返す前にopencode本体の再起動（セッションの作り直し）を試すこと。セッションのツール一覧は開始時に確定するため、`tools>0`で再接続しても同一セッション内では新たに生じたツールを参照できない。

### 2026-10-02: Studio MCPがツール0件で接続できず

- 日付: 2026-10-02
- 対象コミット: `b316d14`（`docs: add whisper anomaly design`、作業ツリーに `docs/workboard.md` の未コミット差分あり）
- Studioプレースへ反映した内容: なし。本セッションはStudioを操作していない。
- テスト環境: 起動せず（Play Solo / Start Server + Players いずれも未実行）
- 参加Client数: 0
- 実施者: 担当エージェント（Studio操作権限なし）
- 結果: `Blocked`
- 結果の概要: 対象4セクション（「最小Run: 複数Client／Party Run」7項目、「リザルト／Inventory」5項目、「8月31日: 景観・フェーズ」5項目、「TSUTAYA: 閉店直後のアーカイブ」5項目）の合計22項目を1件も検証していない。共通事前確認の4項目も未達。推測で `Pass` にした項目はない。

#### Studio MCPの接続状態（観測した事実）

- 設定は `~/.config/opencode/opencode.json` の `mcp.servers.Roblox_Studio`（`type: local`、`command: /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`）。
- バイナリは存在する（5,458,544 bytes、2026-09-27 15:51）。
- Roblox Studio本体は起動中（PID 54590、起動 2026-09-30T02:01:17Z）。
- `StudioMCP` のプロセスは複数起動している（残存プロセス。観測時点のPID: 10075 / 44105 / 44299 / 45126 / 45131 / 47252 / 55504 / 77708 / 84612）。
- opencodeのログ（`~/.local/share/opencode/log/opencode.log`）では、本セッション（2026-10-02T01:56:23Z開始）に `server=Roblox_Studio` の `mcp connected` 記録が存在せず、接続自体が確立していない。
- 直前の接続試行（2026-10-02T01:05:24Z）は `mcp connected server=Roblox_Studio tools=0` であり、接続は確立したものの公開ツールが0件だった。所要時間は各約10.2秒（応答待ちの上限に達した挙動）。
- 過去の正常時は `tools=28` で接続していた（2026-09-30 07:16〜13:22Z）。使用実績のあるツールは `list_roblox_studios` / `script_read` / `script_grep` / `multi_edit` / `start_stop_play` / `execute_luau` / `get_console_output`。最終使用は 2026-09-30 21:51頃。
- 直接プローブ: `StudioMCP` を単独起動し、MCP stdioハンドシェイク（`Content-Length` フレーミング、`initialize` → `notifications/initialized` → `tools/list`）を `protocolVersion` 2024-11-05 と 2025-06-18 の双方で送信した。30秒間 stdout / stderr ともに1バイトも出力されず、応答が得られなかった。
- Studio側のログ（`~/Library/Logs/Roblox/*Studio*.log`）にはMCP関連の行が存在しない。

#### 利用できたツール

本セッションから呼び出し可能なのは、ローカルファイル操作、Git参照、Web検索、およびHappierのセッション管理MCPのみである。`Roblox_Studio` 名前空間のツールは1件も公開されていないため、`list_roblox_studios` によるプレース列挙すら行えていない。

#### 実施しなかった操作と理由

- Studio本体の再起動、`Roblox_Studio` MCP設定の変更、StudioのPreferences変更は行っていない。再起動や設定変更は接続障害の回避に不可欠であり、権限外かつ破壊的な操作として人間側の判断に委ねる。
- `src/` の読み取り以外のコード確認は行っていない。静的確認は検証の代替にしない。

#### OutputのError・Warning

取得できていない。`get_console_output` が利用不可であり、StudioのOutput画面にもアクセスしていない。エラー・警告がゼロだったことを意味しない。

#### 復旧後に必要な手順

1. `Roblox_Studio` MCPが `tools>0` で接続される状態を確認する。接続できない場合はStudio本体の再起動を試す。
2. `list_roblox_studios` で対象プレース「異変のダンジョン」を特定し、開いているプレースと対象コミット `b316d14` の整合を確認する。
3. 共通事前確認の4項目をすべて満たしてから各セクションの検証に入る。
4. 8月31日とTSUTAYAは Decision 008 / 009 と、Gitの`src/`とプレースの反映関係を先に確認する。

#### 残件と反映先

- 「最小Run: 複数Client／Party Run」全7項目: [開発ワークボード](../workboard.md) の「最小Runの複数Client検証」。
- 「リザルト／Inventory」全5項目: 同「リザルトUIの実表示検証」。
- 「8月31日: 景観・フェーズ」全5項目: 同「8月31日景観変更のStudio検証」、正本は [008](../decisions/008-august-31-landscape-composition.md)。
- 「TSUTAYA: 閉店直後のアーカイブ」全5項目: 同「TSUTAYA「閉店直後のアーカイブ」改修のStudio検証」、正本は [009](../decisions/009-tsutaya-closing-time-archive.md)。
- 接続障害そのものによる再発は2件目（2026-10-02に2セッション連続）。原因と回避策は [制作トラブルシューティング](troubleshooting.md) へ移す。

## 共通事前確認

- [ ] 対象コミットと変更ファイルを記録した。
- [ ] Git側の`src/`をStudioプレースへ反映した経路を記録した。
- [ ] StudioのOutputを確認し、新規Errorと既知Warningを区別できる状態にした。
- [ ] テスト前の既存Runtime生成物やデバッグ状態が、結果を誤認させないことを確認した。

## 最小Run: 1人経路

- [ ] 都市ロビーからダンジョン入口ロビーへ移動できる。
- [ ] PartyFieldへ入ると受付人数・残り時間が表示される。
- [ ] 30秒締切後、受付参加者だけがRunへ出発する。
- [ ] `TSUTAYA` または `AUGUST_31` のどちらかが抽選され、マップが生成される。
- [ ] Run中に、入口ロビーやデバッグマップ切替が正式Runを迂回しない。
- [ ] Return、死亡、8/32のRun Lifetime満了など、確認対象の終了経路でRunが閉じる。
- [ ] 終了後、都市ロビーで次の受付を開始できる。

## 最小Run: 複数Client／Party Run

- [ ] 2人以上でPartyFieldへ入り、先着順で参加できる。
- [ ] 6人目は上限5人を超えて参加できない。
- [ ] 受付中にフィールド外へ出たプレイヤーが、出発参加者に残らない。
- [ ] 締切後にフィールドへ入ったプレイヤーは進行中Runへ途中参加できない。
- [ ] `DEBUG 強制締切`が受付を即時に終了し、参加者だけを出発させる。
- [ ] Run中または結果表示中の切断で、残った参加者のRun状態が不整合にならない。
- [ ] 全参加者の終了後に生成マップが破棄され、次のRunが開始できる。

## リザルト／Inventory

- [ ] 成功時、獲得物、Quest達成状況、Credits変化がクライアント画面に表示される。
- [ ] 失敗時、Secure Slot内の物だけが獲得物、その他が喪失物として表示される。
- [ ] 空の獲得物・喪失物が誤解のない表示になる。
- [ ] 「都市ロビーへ戻る」操作で、Result状態が解除され都市ロビーへ戻る。
- [ ] Result表示中にスキルやDashが実行できない。

## 8月31日: 景観・フェーズ

- [ ] 追加した樹木、草、電線、水辺小物がTrail、Prompt、カメラ、プレイヤー移動を遮らない。
- [ ] 地表、景観小物、Streamingの組み合わせで探索・操作が著しく困難にならない。
- [ ] `DAY`、`EVENING`、`NIGHT`、`AUG_32`の表示・照明・帰還条件が想定どおり遷移する。
- [ ] 8/32遷移時、専用Parts、Exposure倍率、Run Lifetime、帰還閉鎖が正常に動く。
- [ ] Run終了後、Lighting／Atmosphereなど一時的に借用した状態が復元される。

## TSUTAYA: 閉店直後のアーカイブ

- [ ] 背表紙、落下ケース、レジ、返却カート、小物が主要通路とPromptを塞がない。
- [ ] 視覚専用小物がRaycastやインタラクションの対象を妨げない。
- [ ] 店頭、売場、放送室、作業場の照明差が探索不能な暗さや過度な明るさにならない。
- [ ] 棚・小物・照明追加後も、Archive Shelf、CRT、試聴、出口端末を操作できる。
- [ ] Map生成、探索、帰還中に新規Errorが出ず、負荷上の問題を観察事項へ記録した。

## 結果の扱い

- `Fail`: 再現手順、対象コミット、Output、影響範囲をワークボードへ追加する。
- `Blocked`: Studio反映や必要なClient数など、検証できない理由をワークボードの該当項目へ記録する。
- `Pass`: 検証日・対象コミット・範囲を該当する実装棚卸しまたはDecision Logへ反映する。

## 関連資料

- [開発ワークボード](../workboard.md)
- [現在の実装状況](../systems/current-implementation.md)
- [Robloxプロジェクト構成](../systems/project-structure.md)
- [Robloxへの導入](roblox-import.md)
