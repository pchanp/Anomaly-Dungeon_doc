# 現在の実装状況

**Status: Implemented（実装棚卸し）**
**Studio確認日: 2026-09-29**

この資料は、Roblox Studioのプレース「異変のダンジョン」を直接確認して記録した実装状況である。設計の採用を意味する資料ではない。`Draft` や `Idea` の内容が偶然プロトタイプに含まれていても、設計確定とは扱わない。

## 起動確認

2026-09-26にPlay Soloで初期化を確認した。マップ、スキル、デバッグフロア、ロビー接続、巨人Visual、クライアント処理が初期化され、巨人アニメーションは49フレーム・71 Boneを認識した。確認した範囲では新規のScript Errorは発生していない。

## 実装済みの基盤

- サーバー生成のClosed Stacksマップとロビー。
- サーバー生成のAbandoned TSUTAYAマップ。7ルーム、通路、出口端末、泉、観測体、異常通路をもち、デバッグフロアから読み込める。
- サーバー生成の8月31日マップ。10ゾーン、12本のTrail、出口端末、帰還面、泉、観測体、異常通路、8/32専用Parts11個、日付板2枚を生成する。
- 8月31日マップのServer側時間進行。`DAY`から`EVENING`、`NIGHT`を経て`AUG_32`へ進み、探索者がマップ内にいる間だけ進む。
- 夕方以降の帰還面開放と、8/32での帰還面閉鎖。8/32では団地前への移動、Anomaly Exposureの取得速度2.4倍、Run Lifetime300秒の強制帰還が始まる。
- 8/32専用Partsの非表示保持と、遷移時の一括表示。
- 8月31日マップの`Lighting`と`Atmosphere`のフェーズ別差し替えと、マップ再構築時の復元。
- `LOBBY`、`ENTRY`、`HALL`、`BOOKS`、`CISTERN`、`OBSERVATORY`、`GAMES`、`REGISTER`、`STAFF`、`WAREHOUSE`、`EXTRACTION`、`OUTSIDE`の各ルーム。
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
- デバッグフロアにマップ切替端末があり、登録済みのMap IDへ切り替える。Transition Portalの代替である。
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
- マップは`CLOSED_STACKS`、`TSUTAYA`、`AUGUST_31`の3種だが、マップ間の遷移条件は未実装である。
- 出口の出現条件は`Shared/Definitions/MapDefinitions`が保持し、`RunService`が`ExitCondition.PromptName`で端末Promptを参照する。登録済みの条件種別は`TERMINAL`のみで、`CLOSED_STACKS`と`TSUTAYA`、`AUGUST_31`が該当する。マップごとの複数条件、達成件数、時間条件などは未実装。記録片仕様は廃止済み。
- `DebugMapSwitch`の`MapSwitchDeck`は実行時に空のFolderとして残っており、端末の読み込み用パッドが生成されない。8月31日をデバッグフロアから読み込む経路は未確認である。
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
- Abandoned TSUTAYAのArchive Selection UI、メディア視聴、Shared BGMなどの案。

## 確認した主な実装場所

- Git: `ServerScriptService/AnomalyDungeonServer/Maps/Generators/MapGenerator`
- Git: `ServerScriptService/AnomalyDungeonServer/Maps/Tsutaya/TsutayaGenerator`
- Git: `ServerScriptService/AnomalyDungeonServer/Maps/Tsutaya/TsutayaArchiveService`
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

## 関連資料

- [推奨Robloxプロジェクト構成](project-structure.md)
- [未実装機能の優先順位](implementation-priorities.md)
- [ゲームルール](game-rules.md)
