# Robloxプロジェクト構成

**Status: Designed（構成方針）**
**Studio確認日: 2026-09-26**

## Gitソースの移行状況

2026-09-27に、Git管理下の`src/`を本資料の責務分離へ合わせて整理した。Server、Client、Shared、Anomalies、Maps、Debugの配置を反映し、Rollback／Backupはbaseline commitで参照できるため削除した。

この変更はGit上のソース構成に対するもの。Rojo等の自動同期は導入しておらず、Roblox Studio上のInstance構成への反映とPlayテストは別途必要である。Remote、Asset、Workspaceの実体名は既存挙動を維持するため変更していない。

この資料は、現在のStudio構成を整理し、設計資料にある案を将来どこへ実装するか判断できるようにする。以下の「推奨構成」は段階的な移行先であり、現プレースを一度に移動する指示ではない。

## 現在の構成概要

```text
ReplicatedStorage
├── AnomalyPrototype/{Config, Definitions, Remotes}
├── AnomalyState
├── GiantAnomalyAssets
├── GiantAnomalyShared/{GiantConfig, Remotes}
├── MovementAnimations
├── AnomalyNotice
└── SkillEvent

ServerScriptService
├── AnomalyPrototype/{Bootstrap, DebugFloor, DungeonManager, MapGenerator, SkillServer}
├── AnomalyPrototypeService
├── AnomalySystem/{GiantAnomalyController, GiantAnomalyService, GiantImportedVisualAdapter}
├── DebugLobbyLink
├── LobbyDungeonEntranceFix
└── MiWVisualAdapter

ServerStorage
├── AnomalyAssets
├── GiantAnomalyAssets
├── RBX_ANIMSAVES
└── 複数のRollback／Backupフォルダ

StarterPlayer/StarterPlayerScripts
├── AnomalyClient
├── AnomalyPrototypeClient
├── GiantAnomalyClient
├── GiantImportedAnimationClient
├── R15MovementAnimations
└── SkillClient

Workspace
├── AnomalyDungeon/{Rooms, Connections, Roofs}
├── 実行時生成されるDebugFloor
├── 実行時生成されるAnomalies
└── 編集用またはインポート由来のモデル
```

### 現在の課題

- MiW、/dev/null、巨人でConfig、Remote、Service、Clientの置き場所が統一されていない。
- `AnomalyPrototype`という名前が、マップ、スキル、デバッグ、アノマリー本体の複数責務を持つ。
- 接続修正用ScriptやVisual Adapterがトップレベルへ増えている。
- バックアップがプレース内に蓄積しており、有効実装との区別にコストがかかる。
- Runtime生成物、編集用テンプレート、インポート元モデルの境界が不明瞭。
- Studio上のコードがこのドキュメントリポジトリの `src/` と同期されていない。

## 推奨構成

```text
ReplicatedStorage
└── AnomalyDungeon
    ├── Shared
    │   ├── Config
    │   │   ├── RunConfig
    │   │   ├── SkillConfig
    │   │   └── AnomalyConfig
    │   ├── Definitions
    │   │   ├── AnomalyDefinitions
    │   │   ├── MapDefinitions
    │   │   ├── ItemDefinitions
    │   │   └── SkillDefinitions
    │   ├── Types
    │   └── Constants
    ├── Remotes
    │   ├── Run
    │   ├── Anomalies
    │   ├── Inventory
    │   ├── Skills
    │   └── UI
    └── Assets
        └── Animations

ServerScriptService
└── AnomalyDungeonServer
    ├── Bootstrap.server
    ├── Services
    │   ├── RunService
    │   ├── PlayerStateService
    │   ├── MapService
    │   ├── PortalService
    │   ├── AnomalyService
    │   ├── ExposureService
    │   ├── InventoryService
    │   ├── QuestService
    │   ├── DiscoveryService
    │   └── SkillService
    ├── Anomalies
    │   ├── MiW
    │   ├── DevNull
    │   ├── MadStomper
    │   └── MemorySwapper
    ├── Maps
    │   ├── Generators
    │   └── Runtime
    └── Debug
        ├── DebugFloorService
        └── TestCommands

ServerStorage
└── AnomalyDungeonAssets
    ├── Anomalies/{MiW, DevNull, MadStomper, MemorySwapper}
    ├── Maps/{Templates, RoomKits}
    ├── Items
    └── NPCs

StarterPlayer
└── StarterPlayerScripts
    └── AnomalyDungeonClient
        ├── Bootstrap.client
        ├── Controllers/{Run, Anomaly, Skill, Movement, Interaction}
        ├── UI/{HUD, Inventory, Quest, Discovery, Archive}
        └── Effects/{Camera, Audio, Visual, Visibility}

StarterGui
└── AnomalyDungeonGui
    ├── RunHUD
    ├── SkillHUD
    ├── InventoryHUD
    ├── QuestHUD
    └── DebugHUD

Workspace
└── Runtime
    ├── ActiveMap
    ├── Anomalies
    ├── NPCs
    ├── Projectiles
    ├── Effects
    └── Debug
```

## 責務の境界

- `Definitions`はIDと静的データを保持し、実行状態を持たない。
- `Services`はサーバーが決定するゲーム上の事実とライフサイクルを管理する。
- `Anomalies`は個別アノマリーの状態・判定を持ち、UIや入力処理を直接所有しない。
- Clientの`Controllers`はRemoteを通じてサーバーの事実を受け取り、入力要求を送る。
- Clientの`Effects`と`UI`はプレイヤー固有の知覚差、カメラ、音、表示を担当する。
- `ServerStorage`はテンプレート資産、`Workspace/Runtime`は現在のランで生成された実体を保持する。
- RollbackはGit履歴または外部バックアップで管理し、長期的にはプレース内へ増やし続けない。

## 設計案から実装先への対応

| 設計要素 | 主な実装先 | 依存先 | 現状 |
| --- | --- | --- | --- |
| Run開始・終了 | `RunService` | PlayerState、Map、Inventory | 部分実装 |
| Return Portal | `PortalService` + Run Remote | Run、Map State | 単一マップ版を実装済み |
| Transition Portal | `PortalService` | Party State、MapDefinitions | 未実装・Draft。`MapDefinitions` は実装済み |
| Party State | `RunService`または専用集約Module | Exposure、Quest、Inventory | 未実装・Draft |
| Anomaly Exposure | `ExposureService` | PlayerState、Anomaly、Portal | サーバー権威の基礎実装済み |
| Player Anomaly | `PlayerStateService` + 個別Module | Exposure、Visibility | Mad Stomper変異を基礎実装済み |
| Visible / Invisible Inversion | Client `Visibility` + Server PlayerState | Component分類 | 未実装・Draft |
| Secure Slot | `InventoryService` | Run終了、永続データ | 未実装・Draft |
| ItemStack／認識履歴 | `InventoryService` | ItemDefinitions | 未実装・Draft |
| Memory Swapper | `Anomalies/MemorySwapper` | ItemStack、Visibility | 未実装・Draft |
| MiW | `Anomalies/MiW` + HUD Controller | Run情報、Effects | プロトタイプ実装済み |
| /dev/null | `Anomalies/DevNull` + 入力結果の共通Gate | Skill、Item、Combat | 限定プロトタイプ実装済み |
| Mad Stomper | `Anomalies/MadStomper` + Effects | Exposure、Skill | 巨人プロトタイプ実装済み |
| Quest | `QuestService` + Quest UI | Run、Map | 属性ベースの単一目標のみ実装済み・分離は未実装 |
| FILE／Discovery | `DiscoveryService` + Discovery UI | 永続データ | 未実装・Draft |
| Archive Selection UI | Client `UI/Archive` | Map gimmick、Discovery | 未実装・Idea |
| マップ固有ギミック | `Maps/Runtime/<MapId>` | 共通Service | TSUTAYAは `Maps/Tsutaya` にプロトタイプ実装、他の案は未実装 |
| マップ切替（開発用） | `Debug/DebugMapSwitch` → `RunService.Build` | MapDefinitions | 実装済み。Transition Portalとは別用途 |
| マップ別出口条件 | `Definitions/MapDefinitions` | Map、Run | 定義への参照と差し替え口は実装済み、条件種別は`TERMINAL`のみ |

## 移行ルール

1. 動作中のScriptを一度に移動しない。
2. 先に共通ID、Remote名、Service境界を文書化する。
3. 既存プロトタイプへAdapterを置き、新構成へ1機能ずつ移す。
4. 移行単位ごとにPlay Soloと複数Clientで確認する。
5. 移行済み機能だけを `Implemented` として記録する。
6. `src/`とStudioは自動同期されない。Git側の配置変更をStudioへ反映する場合は、移行単位ごとに手動で配置とScript種別を確認する。

## 関連資料

- [現在の実装状況](current-implementation.md)
- [未実装機能の優先順位](implementation-priorities.md)
- [ゲームルール](game-rules.md)
