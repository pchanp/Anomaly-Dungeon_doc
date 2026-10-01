# 開発ワークボード

**Status: Draft（運用開始前）**
**更新日: 2026-10-01**

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
| `In Progress` | 実行中。担当セッションと範囲を明記する | 担当エージェント |
| `Verify in Studio` | Git側の変更または設計は揃ったが、実プレースでの確認が未完了 | 人間またはStudio操作担当 |
| `Done` | 完了条件を満たし、正本へ結果を反映済み | なし |
| `Parked` | 価値はあるが、現時点では実行しない | 人間 |

`Ready` の項目だけをエージェントへの作業指示へ展開する。`Needs Human` を自動で実装へ進めない。

## 初期実行キュー

### P0: 実装・Studio検証

- [ ] **最小Runの複数Client検証**
  - 状態: `Ready`
  - 担当: Studio操作担当
  - 次アクション: 2人以上で、受付、30秒締切、満員、強制締切、途中参加拒否、切断、全員終了を確認する。
  - 完了条件: [Studio検証チェックリスト](production/studio-verification-checklist.md) の「複数Client／Party Run」結果を記録し、不具合は本書またはトラブルシューティングへ切り出す。
  - 正本: [現在の実装状況](systems/current-implementation.md)、[最小Runの範囲](decisions/005-minimum-lobby-run-scope.md)

- [ ] **リザルトUIの実表示検証**
  - 状態: `Ready`
  - 担当: Studio操作担当
  - 次アクション: 成功と失敗の両方で、獲得物、喪失物、Quest状況、Credits、都市ロビーへ戻る操作を確認する。
  - 完了条件: クライアント画面で表示と復帰を確認し、未確認の表示・入力問題を記録する。
  - 正本: [現在の実装状況](systems/current-implementation.md)

- [ ] **8月31日景観変更のStudio検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当
  - 次アクション: Trail、Prompt、カメラ、移動、8/32遷移、負荷とStreamingを実プレースで確認する。
  - 完了条件: [008](decisions/008-august-31-landscape-composition.md) の検証事項を記録し、GitソースとStudioプレースの反映関係を確認する。
  - 正本: [008: 8月31日の景観構成](decisions/008-august-31-landscape-composition.md)

- [ ] **TSUTAYA「閉店直後のアーカイブ」改修のStudio検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当
  - 次アクション: 背表紙、小物、照明が通路、Prompt、Raycast、移動、負荷を阻害しないか確認する。
  - 完了条件: [009](decisions/009-tsutaya-closing-time-archive.md) の検証事項を記録し、必要なら改修案を `Inbox` として追加する。
  - 正本: [009: TSUTAYAを「閉店直後のアーカイブ」として再構成する](decisions/009-tsutaya-closing-time-archive.md)

### P1: 最小Runを継続可能なゲームへつなぐ基盤

- [ ] **正式Inventory／ItemStackの最小仕様を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: Item ID、スタック、所有者、所在、マップ上の取得源、Run終了時の移管。
  - 完了条件: Quest回収とSecure Slotを一つのデータモデルで扱える最小仕様を、既存資料の正本へ記録する。
  - 正本: [現在の実装状況](systems/current-implementation.md)、[未実装機能の優先順位](systems/implementation-priorities.md)

- [x] **Secure Conversionの成長経路を決定する**
  - 状態: `Done`
  - 担当: 人間
  - 決定: 都市ロビーのアノマリー研究室で、レアルート品を消費して通常スロット1枠をSecure Slotへ変換する。総枠数は増えない。
  - 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)、[経済と成長](systems/economy-and-progression.md)

- [ ] **Capacity Expansionの詳細を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 決定済み: 総インベントリ枠を増やす強化を設け、Secure Conversionと同種のレアルート品を消費する。
  - 判断対象: 交換レート、上限、追加枠の初期種別、入出庫時点、Player Anomaly時の制約。
  - 完了条件: 初期4枠・総20枠と矛盾しない仕様を決め、Inventory実装指示へ展開できる状態にする。
  - 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)、[ゲームループとポータル遷移](systems/game-loop.md)

- [ ] **QuestとDiscoveryの最小分離を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: 1ランに保持できるQuest数、達成・失敗・報酬の記録、FILE／Discoveryとの境界。
  - 完了条件: 現行の単一Quest Attributeから移行できる最小データモデルと、リザルトへの表示範囲を決める。
  - 正本: [クエスト](systems/quests.md)、[未実装機能の優先順位](systems/implementation-priorities.md)

- [ ] **異常化後のRun終了を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: Player AnomalyとしてのRun継続可否、帰還方法、資産・Quest・報酬の扱い。
  - 完了条件: 現行の`TRANSFORMED_TIMEOUT`仮実装を維持・変更・撤回のいずれかに判断できる。
  - 正本: [ゲームルール](systems/game-rules.md)、[現在の実装状況](systems/current-implementation.md)

- [ ] **スキルビルドの最小仕様を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: 4枠案の採否、取得、強化、失効、通常成長とPlayer Anomaly時の強化の関係。
  - 完了条件: 現在の3スキル実装との移行方針を含め、最初のビルド実装単位を定義する。
  - 正本: [ゲームルール](systems/game-rules.md)、[経済と成長](systems/economy-and-progression.md)

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
