# 現在の実装状況

**Status: Implemented（実装棚卸し）**
**Studio確認日: 2026-09-30**

この資料は、Roblox Studioのプレース「異変のダンジョン」を直接確認して記録した実装状況である。設計の採用を意味する資料ではない。`Draft` や `Idea` の内容が偶然プロトタイプに含まれていても、設計確定とは扱わない。

本稿末の「最小Runの実装（2026-09-29追加）」は、Play Solo中に確認できた事実と、確認できなかった事項を分けて記録したものである。

## 起動確認

2026-09-26にPlay Soloで初期化を確認した。マップ、スキル、デバッグフロア、ロビー接続、巨人Visual、クライアント処理が初期化され、巨人アニメーションは49フレーム・71 Boneを認識した。確認した範囲では新規のScript Errorは発生していない。

## 実装済みの基盤

- サーバー生成のClosed Stacksマップとロビー。
- サーバー生成のAbandoned TSUTAYAマップ。7ルーム、通路、出口端末、泉、観測体、異常通路をもち、デバッグフロアから読み込める。
- サーバー生成の8月31日マップ。10ゾーン、12本のTrail、出口端末、帰還面、泉、観測体、異常通路、8/32専用Parts11個、日付板2枚を生成する。
- 8月31日マップの地形生成。`AugustTerrain`が自然地形・湖のへこみ・尾根・ゾーンの平坦化・地表メッシュ生成を担当する。谷底は正弦波の重ね合わせ、尾根は複数の滑らかな山の重なりで作り、湖は谷の南に絶対高で掘る。ゾーンの床板は地形と高さが一致し、境界に段差の壁は残さない。
- 8月31日マップの湖面。円柱を水平に寝かせた円盤で、水面は地形より高く縁は地形で覆われる半径を取る。湖底は湖底の泥、水際は砂、それ以外は草で塗り分ける。
- 8月31日マップのTrail。路面を地形高に沿って12スタッド程度に分割し、区間ごとに両端を地形に合わす。1枚の板で2点結ばないため、谷の起伏で路面の縁が壁にならない。
- 常設の都市ロビーとダンジョン入口ロビー。生成ダンジンモデルとは別のRuntimeモデルとして`LobbyService`が組み立て、都市→入口→パーティ受付の移動Interactionを持つ。
- 入口ロビーのパーティ受付。フィールド内在圈的参加者を先着順で最大5人まで受け付け、最初の参加者から30秒で締め切って出発する。デバッグ用の強制締切Promptを持つ。
- 正式Runのマップ抽選。`TSUTAYA`と`AUGUST_31`のみを同値の重みで等確率に抽選する。候補と重みは`MapDrawConfig`が持ち、抽選はプレイヤー状態を一切参照しない。
- `RunState`によるRunの状態機械。`IDLE` / `RECRUITING` / `DEPARTING` / `ACTIVE` / `RESULT` / `CLOSING`を持つ。プレイヤーのロビー帰属は`LobbyState`で持つ。
- 全Run終了を`RunService.Finish`へ集約した終了処理。成功、依頼未達の帰還、死亡、切断、8/32のRun Lifetime満了、異常化後のRun Lifetime満了を`RunOutcomes`が種別として保持する。
- Run終了時に必ずリザルト画面を出し、獲得物・喪失物・保有Questの達成状況・Credits変化を表示する。成功后「都市ロビーへ戻る」でロビーへ戻す。
- Inventory／Secure Slotのサーバー権威データ境界。総20枠、初期Secure Slot 4枠。成功時は全持ち帰り対象を獲得物、失敗時はSecure Slot内だけを獲得物・それ以外を喪失物として分類する。
- デバッグ用のアイテム付与端末。デバッグアイテムのみを付与し、Secure Slotの保持と喪失、リザルト分類を検証できる。正式な取得源は未実装である。
- 8月31日マップのServer側時間進行。`DAY`から`EVENING`、`NIGHT`を経て`AUG_32`へ進み、探索者がマップ内にいる間だけ進む。
- 夕方以降の帰還面開放と、8/32での帰還面閉鎖。8/32では団地前への移動、Anomaly Exposureの取得速度2.4倍、Run Lifetime300秒の強制帰還が始まる。
- 8/32専用Partsの非表示保持と、遷移時の一括表示。
- 8月31日マップの`Lighting`と`Atmosphere`のフェーズ別差し替えと、マップ再構築時の復元。
- 8月31日マップのフェーズ別`ClockTime`。`DAY=13.5`から`EVENING=18.4`、`NIGHT=23.2`、`AUG_32=23.6`まで補間する。Bind時に値を記録し、Unbind時に復元する。判断の経緯は`docs/decisions/007`を参照。
- `ENTRY`、`HALL`、`BOOKS`、`CISTERN`、`OBSERVATORY`、`GAMES`、`REGISTER`、`STAFF`、`WAREHOUSE`、`EXTRACTION`の各ルーム。`LOBBY`と`OUTSIDE`は廃止し、待避は`LobbyService`が別途buildする都市ロビーと入口ロビーが担う。
- 通路は`PASSAGES`（TSUTAYAは`LINKS`）だけを記述し、壁の開口部と通路の床はその一覧から導出する。到達不能部屋、1壁に衝突する通路、ルーム同士の重なりは`Build`時に`warn()`で報告する。
- 各ルームに `DoorPoints`、`EnemyPoints`、`AnomalyPoints`、`ItemPoints`、`GimmickPoints`、`SpecialPoints` を持たせる配置規約。
- ロビーからダンジョンへの入場と、通常・異常状態で共通の出口ポータルからの帰還。
- 実行時のマップ再生成と、探索中プレイヤーがいる場合の再生成抑止。
- HP、Anomaly Exposure、Player Anomaly、Player Run State、Run Lifetime、部屋名、ダンジョン内外などのプレイヤーAttribute。
- Anomaly Exposureが設定可能な閾値へ達したプレイヤー1人を異常状態にする処理。
- 異常状態への変化時に5分のRun Lifetimeを開始し、終了時に強制帰還させる処理。通常プレイヤーにも停止状態のLifetimeを保持する。
- レジ奥の出口制御端末を操作すると、参加者全員に共有される出口ポータルが起動する。
- TSUTAYAのアーカイブ棚を調べるとArchive Selection UIが開き、VHS／DVD／CD／Tapeの項目から選択できる。1回の検索では全項目が返らない。
- TSUTAYAのCRTでチャンネルを変更できる。停波ノイズを挟んで切り替わり、チャンネルごとに音が変わる。
- TSUTAYAの試聴機で個人試聴できる。試聴は一定時間で終わり、共有BGMはSERVER Stateとしてマップモデル直下に保持され、試聴では変わらない。
- デバッグフロアにマップ切替端末があり、登録済みのMap IDへ切り替える。Transition Portalの代替である。`RunState`が`IDLE`でない間は受け付けない。
- 都市ロビーの`ToDungeonEntrance`と入口ロビーの`ToCityLobby` pad、および入口ロビーの`PartyField`、参加者数と残り時間を示すBillboard、`ForceClose`強制締切Prompt。
- 都市ロビーに移動したキャラクターの初期配置。生成マップの`Enter`プロンプトのTouch入場は撤去し、`LobbyDungeonEntranceFix`は無効化している。
- `QuestState`、`QuestObjective`、`Credits`のプレイヤーAttribute。入場で`ACTIVE`、端末操作で`COMPLETED`、死亡で`FAILED`、帰還時に依頼達成なら`REWARDED`として`RunConfig.QuestRewardCredits`を加算する。未達成の帰還は`FAILED`で報酬なし。
- マップ生成の`M.Build`が生成モデルへ`MapId`、`MapDisplayName`を付与する。</new_string>
- 1人なら回復、2人以上ならダメージとなる泉。
- Magic Bolt、Roll、Stealthの3スキルと、サーバー側クールダウン・効果判定。
- R15移動アニメーション、Shift中のみ速度が上がる移動、Roll、Sneak。
- ロビー、生成マップ、デバッグフロア間の移動経路。

## 実装済みのアノマリープロトタイプ

### MiW

- デバッグフロアに棺を生成する。
- 棺の開封、開封後の棺消去、MiW出現。
- 開封時の死亡抽選と毒ガス抽選。
- 毒ガスのダメージ、移動制限、ParticleEmitter、Sound。
- 生存時のみ個人向けRun情報HUDを表示する観測Interaction。
- 座りモデルを表示するVisual Adapter。

### /dev/null

- デバッグフロアに固定配置する。
- 距離をサーバーで判定し、`NearDevNull` をプレイヤーごとに保持する。
- 近傍のToolを一時的に無効化する。
- Skill、Attack、Itemの通知を受け、プレイヤー個別の無効化Attributeとフィードバックを設定する。

### Mad Stomper相当の巨人プロトタイプ

- 現在のSystem IDは `GIANT`、表示名は `Giant Anomaly` であり、文書上の名称 `Mad Stomper` との対応は未確定。
- デバッグフロア上をランダムに移動する。
- `IDLE`、`APPROACHING`、`ACTIVE`、`CALMING`、`CALMED` の状態を持つ。
- 近傍プレイヤーのAnomaly Levelを増加させる。
- Heal FieldによるAnomaly Level低下と鎮静化。
- ストンプ通知、効果音、カメラシェイク。
- インポート済みスキンメッシュと49フレーム・71 Boneの歩行アニメーション。

## 部分実装または設計との差があるもの

- 現在の入場・帰還は単一マップ内のテレポートであり、Party StateによるTransition Portalではない。TSUTAYAはデバッグフロアから直接読み込む形式であり、Transition Portalではない。
- TSUTAYAのメディア項目は名前と選択結果のみを持ち、映像・音声の実体は未実装である。
- TSUTAYAの共有BGMは固定音源のループであり、選択UIは未実装である。
- マップは`CLOSED_STACKS`、`TSUTAYA`、`AUGUST_31`の3種だが、マップ間の遷移条件は未実装である。正式Runの候補は`TSUTAYA`と`AUGUST_31`の2種で、`CLOSED_STACKS`はデバッグ用途として残す。
- 生成ワールドはRunの生存期間に一致する。全Partyメンバーが終了すると破棄し、次のPartyでは初期状態の新しいマップを生成する。8月31日の時計と環境状態は次のRunへ持ち越さない。
- `RunState`の新しい状態は`AnomalyState:RunState`と`M.GetRunState()`の両方から同じ値を返す。既存の`InDungeon`、`PlayerRunState`、`QuestState`、`QuestObjective`、`Room`、`Credits`は二重の意味を持たせる実装にした。
- 出口の出現条件は`Shared/Definitions/MapDefinitions`が保持し、`RunService`が`ExitCondition.PromptName`で端末Promptを参照する。登録済みの条件種別は`TERMINAL`のみで、`CLOSED_STACKS`と`TSUTAYA`、`AUGUST_31`が該当する。マップごとの複数条件、達成件数、時間条件などは未実装。記録片仕様は廃止済み。
- `DebugMapSwitch`の`MapSwitchDeck`からデバッグフロア上のパッドで各マップを読み込める。8月31日と`TSUTAYA`の読み込みはPlay Soloで確認済みである。
- `QuestState`と`Credits`はプレイヤーAttribute上の単一ラン目標であり、`QuestService`として分離したデータモデルではない。</new_string>
- 4スキル枠を想定したUIはあるが、現在サーバー実装されているスキルは3つで、ビルド取得・強化システムは未実装。
- /dev/nullは限定対象のプロトタイプであり、ダッシュ、ジャンプ、インベントリ操作など文書にある候補すべてをnull化しない。
- Mad Stomperの最終名称、外見、鎮静ルール、再活性化条件は確定していない。

## 未実装

- Party Stateと重み付きポータル遷移。
- Quest、FILE、Achievement、Discoveryの分離されたデータモデル。
- Secure Slotと正式なInventory／ItemStack。
- 複数種のIndividual Anomalyと正式な選出・解除フロー。
- Visible / Invisible Inversion。
- Memory Swapperと `LastRecognizedPlayer`。
- マップ案にあるSEKIGAHARA、KOROHKAN、Observation Mapの各機能。
- 8月31日マップの共通Anomaly System適用、8/32での強制Anomaly発生、Rare Loot、フェーズごとの日付板の時刻、実音源への差し替え。
- 8月31日マップの建造物・商店街・学校・追加植生の作り直し。現状は旧生成物を流用しており、参照イメージに合わせていない。
- 尾根の急斜面の段差。分割を細かくするか、尾根を緩やかにするかは未検討である。
- 湖と`APARTMENT`を結ぶTrail。湖はTrailのネットワークに含まれていない。
- 隣接ゾーンの高さの差。最大15スタッドあり、ゾーン間に傾斜の土手が生まれる。ゾーン配置の平坦化は未検討である。
- マルチプレイヤー向けのサーバー割当、並列Run、再接続、サーバー間移動。これらは最小版のRunでは仮置きであり未実装である。
- Secure Slotの拡張手段、拡張上限、コスト、入出庫タイミング、Player Anomaly時の制約。拡張値の受け取り口だけが`SecureSlotCapacity`で用意されている。
- 異常化後のRun Lifetime満了の扱い。最小版では失敗として扱い基本報酬を支払わない。生存したまま失敗が確定する経路になるため、帰還手段と生存報酬を含めて別途決める必要がある。
- リザルト画面での獲得物・喪失物の表示詳細と、保有Questを複数持つためのデータモデル。現在はQuest 1件を固定で送っている。
- マップ抽選のseed表示と再抽選可否、将来の重み付けの可視化。
- Abandoned TSUTAYAのArchive Selection UI、メディア視聴、Shared BGMなどの案。

## 確認した主な実装場所

- Git: `ServerScriptService/AnomalyDungeonServer/Maps/Generators/MapGenerator`
- Git: `ServerScriptService/AnomalyDungeonServer/Maps/Tsutaya/TsutayaGenerator`
- Git: `ServerScriptService/AnomalyDungeonServer/Maps/Tsutaya/TsutayaArchiveService`
- Git: `ServerScriptService/AnomalyDungeonServer/Services/LobbyService`
- Git: `ServerScriptService/AnomalyDungeonServer/Services/PartyService`
- Git: `ServerScriptService/AnomalyDungeonServer/Services/MapDrawService`
- Git: `ServerScriptService/AnomalyDungeonServer/Services/InventoryService`
- Git: `ServerScriptService/AnomalyDungeonServer/Debug/DebugInventoryTerminal`
- Git: `ReplicatedStorage/AnomalyDungeon/Shared/Config/LobbyConfig`
- Git: `ReplicatedStorage/AnomalyDungeon/Shared/Config/MapDrawConfig`
- Git: `ReplicatedStorage/AnomalyDungeon/Shared/Definitions/RunOutcomes`
- Git: `StarterPlayer/StarterPlayerScripts/AnomalyDungeonClient/UI/RunResultController`
- Git: `ServerScriptService/AnomalyDungeonServer/Maps/August/AugustGenerator`
- Git: `ServerScriptService/AnomalyDungeonServer/Maps/August/August31Service`
- Git: `ReplicatedStorage/AnomalyDungeon/Shared/Config/AugustConfig`
- Git: `ServerScriptService/AnomalyDungeonServer/Debug/DebugMapSwitch`
- Git: `StarterPlayer/StarterPlayerScripts/AnomalyDungeonClient/UI/ArchiveSelectionController`
- Git: `ServerScriptService/AnomalyDungeonServer/Services/RunService`
- Git: `ServerScriptService/AnomalyDungeonServer/Services/ExposureService`
- Git: `ServerScriptService/AnomalyDungeonServer/Services/SkillService`
- Git: `ServerScriptService/AnomalyDungeonServer/Anomalies/*`
- Git: `StarterPlayer/StarterPlayerScripts/AnomalyDungeonClient/*`
- Git: `ReplicatedStorage/AnomalyDungeon/Shared/Config/*`
- Git: `ReplicatedStorage/AnomalyDungeon/Shared/Definitions/*`
- `ServerStorage/AnomalyAssets`
- `ServerStorage/GiantAnomalyAssets`

上記のGit構成は2026-09-27に整理した。Studio確認時のInstance構成は本資料冒頭の確認日の状態であり、自動同期されていない。

## 最小Runの実装（2026-09-29追加）

都市ロビーからダンジョン入口ロビーを経て、抽選された1マップを探索してリザルトを挟み都市ロビーへ戻る、最小Runの縦一列为実装済み。正式Runの候補は `TSUTAYA` と `AUGUST_31` の2種で、`CLOSED_STACKS` はデバッグ用途に残した。Transition Portal、Party State、パーティ別の並列Runは範囲外である。

### Runの状態機械

`RunService` がサーバー権威で `IDLE` / `RECRUITING` / `DEPARTING` / `ACTIVE` / `RESULT` / `CLOSING` を保持し、同じ値を `AnomalyState:RunState` と `M.GetRunState()` から参照できる。プレイヤーのロビー帰属は `LobbyState` 属性で `CITY` / `ENTRANCE` / `PARTY` / `RUNNING` / `RESULT` を表現する。従来の `InDungeon`、`PlayerRunState`、`QuestState`、`QuestObjective`、`Room` は互換のため維持し、新しいRun境界の開始と終了ではこれらをまとめて更新する。

### 実装したサービス

- `Services/LobbyService`: 都市ロビーとダンジョン入口ロビーを、生成ダンジンモデルとは別の常設Runtimeモデルとして構築する。都市ロビーには `CityLobbySpawn`、`ResultPad`、`DUNGEON ENTRANCE` の移動Interaction。入口ロビーにはパーティ用 `PartyField`、参加者数と残り時間の表示、`DEBUG 強制締切` のProximityPrompt。`LobbyConfig` に位置と受付秒数、`PartyMax` を置く。
- `Services/PartyService`: 30秒の受付、上限5人、強制締切。フィールド判定は `LobbyService.IsInPartyField` の範囲判定で、Touchイベントには依存しない。受付は満員でも30秒を待ち、強制締切スイッチだけが早期出発を許可する。途中参加は拒否し、切断時は除外して参加者が0なら受付をリセットする。
- `Services/MapDrawService`: `MapDrawConfig` の候補配列と重みから抽選する。現時点の重みは同値で、プレイヤー状態を一切参照しない。`CLOSED_STACKS` は候補に含まれない。
- `Services/InventoryService`: 20枠、初期Secure Slot 4枠のサーバー権威データ境界。付与、枠の制約、Run終了時の獲得物・喪失物への分類だけを持ち、正式なアイテムシステムを持たない。アイテムは `DebugGrant` でしか作らない。
- `Debug/DebugInventoryTerminal`: 都市ロビーのSpawn脇にデバッグ付与端末を置く。通常枠1個とSecure Slot 1個だけを加える。

### 終了とリザルト

成功、未達帰還、死亡、切断、8/32のRun Lifetime満了、異常化後のRun Lifetime満了は、すべて `RunService.Finish(player, outcomeId)` に集約する。終了種別と成功／失敗フラグは `Shared/Definitions/RunOutcomes` が保持し、ラベルもそこから送るためクライアントは表示文言を創作しない。`M.Extract(p, force)` は互換のため残し、第2引数に文字列を渡すと明示的な終了種別として扱う。

成功はQuest完了後の通常帰還のみ。成功時は `RunConfig.QuestRewardCredits` を支払い、所持中の持ち帰り対象をすべて獲得物とする。失敗時はSecure Slot内だけを獲得物に残し、それ以外を喪失物として破棄する。8/32のRun Lifetime満了は死亡扱いの失敗で、Creditsは支払わない。

Party全員が終了すると `RunService.CloseRun` が生成世界を破棄し、`Aug32Active`、borrowed Lighting、`ExitUnlocked`、`RunSeed`、`MapId` を落として次の受付可能状態へ戻す。次の出発では新しいseedで作り直し、8月31日の時計と環境状態は持ち越さない。マップ内の `world.Lobby` は都市ロビーではなく、Run終了の帰還先には使わない。

### 結果送信とUI

`ReplicatedStorage/AnomalyRunRemotes` に `Result`（サーバー→クライアント）と `ResultRequest`（クライアント→サーバー）を置いた。`Result` で送る内容は、成功／失敗、探索先、保有Questごとの達成状況、獲得物、喪失物、Creditsの前後と増減、インベントリとSecure Slotの枠数である。クライアントの `UI/RunResultController` は受け取った値だけを表示し、「都市ロビーへ戻る」で `ResultRequest` を送って `RunResultPending` を解除する。空の獲得物・喪失物は「なし」と表示し、仕様を偽装しない。

`RunController` の既存HUDは維持し、`LobbyState` に応じて目的表示を切り替え、リザルト表示中はRun操作の案内へ切り替える。`SkillService` と `SkillController` は `RunResultPending` の間のスキルとDashを受け付けない。

### 既存処理との整合で変更した点
- `Services/LobbyDungeonEntranceFix` は無効化した。生成マップ内 `LOBBY/GimmickPoints/Enter` のTouch入場はパーティ受付を迂回するため、撤去して入場を `LobbyService` の受付と `RunService.StartRun` だけが認可するようにした。`RunService.Enter` も出発済みパーティ以外を受け付けない。
- `Debug/DebugFloorService` の初期配置とTick対象をデバッグフロア内に限定した。都市ロビーへの初期配置は `RunService` が担い、デバッグフロアはRuns中のプレイヤーへRun Lifetimeや状態リセットを触らなくなった。
- `Debug/DebugMapSwitch` は `RunService.GetRunState()` が `IDLE` でない間マップを受け付けない。正常Runの候補抽選とは別系統のまま。
- 生成マップはRun開始時だけ存在する。起動直後は `AnomalyDungeon` モデルが無く、デバッグフロアから `DebugMapSwitch` で読み込むか、入口ロビーの受付から出発する。
- 新規Remoteは未配置でも playable になるように `RunService` が実行時に生成する。プレースには手動で配置済み。

## 最小Runの未確認・未決定

- **異常化後のRun Lifetime満了の扱いは設計未確定。** 最小版では `TRANSFORMED_TIMEOUT` として失敗扱いにし、基本報酬を支払わない。異常化してから5分を過ごすと、生存したまま失敗が確定する経路になる。生存報酬や帰還手段の扱いを含めて別途決める必要がある。
- **`InventoryService` にはアイテムの所在情報がない。** 保持と喪失の判定と枠数だけを持ち、マップ上への配置、スタック、所有者、Item IDの規則は未実装。
- **Secure Slotの拡張は未実装。** `SecureSlotCapacity` 属性で拡張値を読み取るが、拡張手段・上限・コストは未決定。
- **受付開始はpolled 判定のため、入場から受付開始まで最大0.25秒の遅れがある。**
- **`DebugInventoryTerminal` の配置は都市ロビーのSpawn脇の固定位置で、ロビー構造を変更しても追随しない。**
- **複数人での挙動は未確認。** Play Soloは1人セッションだったため、パーティ上限5人、強制締切による即時出発、切断者を含む複数人でのRun終了順序は未確認。
- **クライアントのリザルト画面は未確認。** サーバー側の結果確定とRemote送信までは確認済みだが、リザルト画面そのものの表示確認はしていない。
- **マップ生成は `PartyService` の受付ループではなく別スレッドで走らせる。** 同一スレッドで走らせると、受付ループの実行予算と合算してマップ生成が script timeout で中断された。
- **2026-09-29にPlay Soloで見つかった3件の修正。** 2026-09-30に`src/`の内容でプレース本体へ反映した。反映状況は次のとおり。
  1. `Services/PartyService`: `depart` の `host.StartRun` を `task.spawn` で別スレッドに逃がす。**未反映。** `src/` にもプレース本体にも未実装のまま残る。
  2. `Services/RunService`: `M.Tick` の先頭で `local current=world` に取り込み、反復中は `current` を使う。`Finish` が `CloseRun` を呼んで `world` をnilにするため、そのまま `world.KillY` を読むと `attempt to index nil` になる。末尾の `if world~=current then return end` は必須。**2026-09-30に適用。** Run Lifetime満了で `Finish` が同期的に `CloseRun` する状況をPlay Soloで再現し、`Tick` が例外を投げず `world=nil` へ到達することを確認済み。
  3. `Debug/DebugInventoryTerminal`: `pad.CFrame` の初期化でCFrameにCFrameを渡していたのを `lobby.CityLobbySpawn.CFrame+Vector3.new(14,0,6)` に変更。反映済み。
