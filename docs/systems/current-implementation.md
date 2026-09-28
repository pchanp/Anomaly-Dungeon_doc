# 現在の実装状況

**Status: Implemented（実装棚卸し）**
**Studio確認日: 2026-09-28**

この資料は、Roblox Studioのプレース「異変のダンジョン」を直接確認して記録した実装状況である。設計の採用を意味する資料ではない。`Draft` や `Idea` の内容が偶然プロトタイプに含まれていても、設計確定とは扱わない。

## 起動確認

2026-09-26にPlay Soloで初期化を確認した。マップ、スキル、デバッグフロア、ロビー接続、巨人Visual、クライアント処理が初期化され、巨人アニメーションは49フレーム・71 Boneを認識した。確認した範囲では新規のScript Errorは発生していない。

## 実装済みの基盤

- サーバー生成のClosed Stacksマップとロビー。
- `LOBBY`、`ENTRY`、`HALL`、`BOOKS`、`CISTERN`、`OBSERVATORY`、`GAMES`、`REGISTER`、`STAFF`、`WAREHOUSE`、`EXTRACTION`、`OUTSIDE`の各ルーム。
- 各ルームに `DoorPoints`、`EnemyPoints`、`AnomalyPoints`、`ItemPoints`、`GimmickPoints`、`SpecialPoints` を持たせる配置規約。
- ロビーからダンジョンへの入場と、通常・異常状態で共通の出口ポータルからの帰還。
- 実行時のマップ再生成と、探索中プレイヤーがいる場合の再生成抑止。
- HP、Anomaly Exposure、Player Anomaly、Player Run State、Run Lifetime、部屋名、ダンジョン内外などのプレイヤーAttribute。
- Anomaly Exposureが設定可能な閾値へ達したプレイヤー1人を異常状態にする処理。
- 異常状態への変化時に5分のRun Lifetimeを開始し、終了時に強制帰還させる処理。通常プレイヤーにも停止状態のLifetimeを保持する。
- レジ奥の出口制御端末を操作すると、参加者全員に共有される出口ポータルが起動する。
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

- 現在の入場・帰還は単一マップ内のテレポートであり、Party StateによるTransition Portalではない。
- 出口の出現条件は`Shared/Definitions/MapDefinitions`が保持し、`RunService`が`ExitCondition.PromptName`で端末Promptを参照する。登録済みの条件種別は`TERMINAL`のみで、`CLOSED_STACKS`のみ。マップごとの複数条件、達成件数、時間条件などは未実装。記録片仕様は廃止済み。
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
- マップ案にある8月31日／8月32日、SEKIGAHARA、KOROHKAN、Observation Mapの各機能。
- Abandoned TSUTAYAのArchive Selection UI、メディア視聴、Shared BGMなどの案。

## 確認した主な実装場所

- Git: `ServerScriptService/AnomalyDungeonServer/Maps/Generators/MapGenerator`
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
