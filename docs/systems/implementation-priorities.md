# 未実装機能の優先順位

**Status: Draft（実装計画）**
**更新日: 2026-09-28**

この優先順位は、現在のStudio実装とDraft／Idea資料の依存関係を整理したもの。設計案を採用済みに変更するものではない。仕様確定が必要な項目は、実装より先に確認する。

## 優先度の基準

- 他機能が依存する基盤か。
- サーバー権威とマルチプレイヤー整合性に影響するか。
- 現在のプロトタイプの重複・競合を減らせるか。
- 小さく検証してロールバックできるか。
- 仕様が実装可能な粒度まで確定しているか。

## P0: 実装前の基盤整理

### 1. 状態名とIDの確定

- SANは廃止し、Anomaly LevelとAnomaly Exposureの責務境界を確定する。
- `GIANT`／`Giant Anomaly`／`Mad Stomper`の対応を確定する。
- Run、Map、Anomaly、Player AnomalyのID規約を定める。

**理由:** 現在は複数の試作用Attributeが同じ概念領域を表しており、このまま新機能を接続すると互換処理が増える。

### 2. Run StateとPlayer Stateの最小モデル

- Runの開始、活動中、帰還、死亡、終了をサーバー状態として定義する。
- プレイヤー個別状態を1か所から参照できるようにする。
- 既存AttributeはAdapter経由で段階移行する。

**完了条件:** 現在の入場、帰還、死亡、異常化、Run Lifetime終了が同じ状態機械を通る。

### 3. Remoteとフォルダ構成の整理

- 機能別Remoteフォルダを定義する。
- Debug、Runtime、Assetsの境界を明確にする。
- プレース内バックアップを追加し続けない運用へ移行する。

## P1: コアループを成立させる機能

### 1. Inventory／ItemStackの最小実装

- アイテムID、スタック、所有者、ワールド配置のモデル。
- Run終了時に持ち帰る／失う処理。
- Secure Slotは仕様確定後にこの基盤へ追加する。

**依存する将来機能:** Memory Swapper、Quest回収、報酬、Secure Slot。

### 2. QuestとDiscoveryの分離

- Run目的であるQuestと、FILE・発見・実績を別データにする。
- まず1種類の回収Questと1種類のDiscoveryで縦に検証する。

### 3. Portal Service

- 現在のReturn処理をService境界へ移す。
- Transition Portalは過半数、30秒、残留プレイヤー、Party Stateの仕様確定後に追加する。

## P2: アノマリー基盤の統合

### 1. 既存3プロトタイプの共通登録

- MiW、/dev/null、巨人を共通のAnomaly定義・生成・状態参照へ接続する。
- 個別挙動は独立Moduleに維持する。
- デバッグフロアから個別に生成・リセットできるようにする。

### 2. /dev/null共通Gate

- Skill、Attack、Itemの結果発生直前に共通の許可判定を置く。
- 入力そのものを奪わず、サーバー上の結果だけをnull化する。
- ダッシュ、ジャンプ、インベントリ操作はDraftのため、対象追加前に仕様を確定する。

### 3. 正式なAnomaly Exposure

- P0で確定した状態名を用いる。
- 発生率、ポータル、Player Anomalyへ接続できるイベント境界を作る。
- 数式と閾値は別途決定が必要。

## P3: 依存基盤完成後の機能

### Memory Swapper

Inventory／ItemStack、`LastRecognizedPlayer`、マルチプレイヤー所有権が必要。これらより先にNPCだけを作らない。

### Visible / Invisible Inversion

Exposure、Player Anomaly状態、Visible／Invisible Component分類、Clientごとの表示規約が必要。

### Party State Transition

Run State、Portal Service、MapDefinitions、Exposure、Quest、Inventoryが必要。重み式と確定遷移条件は未決定。

### Secure Slot

InventoryとRun終了処理の完成後に実装する。枠数、対象、入出庫タイミング、Player Anomaly時の扱いは未決定。

## P4: アイデア段階のマップ

`map-gimmick-ideas.md`の各マップは採用未確定のため、現時点では実装しない。基盤完成後、1マップずつ設計を `Designed` へ更新してから着手する。

## 推奨する次の実装単位

1. マップごとの出口出現条件を定義する。
2. Run Lifetimeを操作する特殊イベントのAPIを定義する。
3. Run StateをPortal Serviceへ接続する。
4. 入場・死亡・通常帰還・異常化後帰還・強制帰還をPlayテストする。
5. その後、Inventory／ItemStackへ進む。

## 関連資料

- [現在の実装状況](current-implementation.md)
- [Robloxプロジェクト構成](project-structure.md)
- [ゲームルール](game-rules.md)
- [ゲームループとポータル遷移](game-loop.md)
