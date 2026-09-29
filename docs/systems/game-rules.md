# ゲームルール

**Status: Draft（草案）**

この資料は、Run中のルール、ビルド、戦闘、帰還、サーバー責務に関する現時点の設計案を記録する。基本循環とポータル遷移の方針は、[ゲームループとポータル遷移](game-loop.md)を参照する。

## Run

1回のダンジョン探索を**Run**とする。協力PvE探索ローグライクとして、プレイヤーはRun中にどこまで進み、何を確保し、いつ帰還するかを判断する。

Run中には、少なくとも以下の状態が蓄積または変化し得る。

- HP
- スキルビルド
- 所持アイテム
- Secure Slot
- Anomaly Exposure
- Individual Anomaly
- マップ固有状態
- クエスト進行
- 各種フラグ

Run終了後は、持ち帰った資産・情報などをメタゲームへ反映する案とする。

最小Runでは終了時にリザルト画面を表示し、獲得物、喪失物、保有Questごとの達成状況を示してから都市ロビーへ戻る。成功して帰還した場合は持ち帰り対象を獲得し、死亡・未達帰還・8/32のRun Lifetime満了などの失敗時はSecure Slot内の物だけを獲得して、それ以外を喪失する案とする。総インベントリは20枠、そのうち初期4枠がSecure Slotであり、通常プレイヤーはスキル強化でSecure Slotを拡張できる。Secure Slotと正式なInventoryは未実装であり、拡張上限・対象・入出庫タイミングは未決定である。

## Runの終了と寿命

RunはHPが0になることだけで終了しない。ビルドはRunの限界を押し広げるためのものであり、Runを無限に継続可能にするものではない。

現時点では、以下を終了条件の候補として扱う。

- **Return**: プレイヤーがReturn Portalから脱出する、通常の任意終了。
- **Incapacitation**: HPが0になるなど、戦闘不能になる。
- **Anomaly Transformation**: Exposureなどにより通常プレイヤーとしてRunを継続できない状態に達する。
- **Map / World Termination**: 時間制限、世界崩壊、戦場の終結、空間の閉鎖など、マップ状態により終了する。
- **Triggered Termination**: 禁忌のアーカイブ閲覧、特定アイテムの使用、イベントの成立など、プレイヤー行動で終了フラグが成立する。

「Anomaly Transformation」が即座のRun終了になるか、Player Anomalyとして別の状態で継続できるか、その場合の帰還方法は未決定である。Player Anomalyの原則的な代償と利点は[ゲームループとポータル遷移](game-loop.md)に従う。

## スキルビルドとマップ

プレイヤーは1 Runにつき基本4つのスキルを装備する案とする。スキルはCombat、Mobility、Heal / Survival、Exploration / Utilityなどの役割を持ち得るが、枠を固定ロールにはしない。

標準的な構成のほか、探索能力を犠牲にした`Attack / Attack / Attack / Attack`のような極端な構成も成立し得る。マップは特定ビルドを必須にせず、特定ビルドが強く機能する状況を提供する。

各マップは独立したゲームシステムを増やすためのものではない。既存の基盤システムが、異なる状況で別の価値を持つようにする。具体案は[マップとギミック案](map-gimmick-ideas.md)に記録する。

## 戦闘とアノマリー

戦闘は、常時大量配置された敵だけを目的にするのではなく、探索中のイベントやアノマリー反応から発生する案とする。

```text
探索
    -> プレイヤーの行動
    -> ステージまたはアノマリーが反応
    -> 戦闘イベント発生
    -> 戦闘
    -> 探索へ復帰
```

戦闘イベントには、敵NPCの出現、追跡、包囲、増援、防衛、巨大アノマリーとの遭遇、NPC同士の戦闘への介入などが含まれ得る。

Anomaly Entityの発生は、個別マップが直接選択するのではなく、共通のAnomaly Systemによって確率的に扱う案とする。概念上は、Base RateにPlayer Modifier、Party Modifier、Map Modifier、Current Map Stateが影響する。

- 危険なAnomalyは発生してよい。
- 通常のゲーム進行を破壊するCriticalなAnomalyは、通常条件では抑制する。
- 特殊なアイテム、状態、Player Anomalyなどにより、通常は抑制されるAnomalyが発生し得る。

Exposureはダメージ値ではなく、Anomaly発生、Individual Anomaly、スキル、マップ状態、ポータル遷移、Run終了条件に影響し得る内部状態として扱う。ポータル遷移における役割は[ゲームループとポータル遷移](game-loop.md)を参照する。

## クエストと探索

- **Quest**は現在のRunの目的であり、特定アイテムの回収、地点への到達、対象の確認などを扱う。
- **Discovery**はFILE、Achievement、Anomaly情報、特殊アイテム、マップ記録などの長期的な探索・収集要素である。

Questの達成と、マップ全体を理解することは同義ではない。探索はアイテム収集だけでなく、構造の把握、危険予測、戦闘回避、イベントやギミックの理解を含む。

## ReturnとTransition

Return Portalはマップ攻略完了ではなく、現在のRunから帰還できる状態を意味する。原則としてサーバー共有状態とし、マップ固有のGimmickが成立すると有効化される案とする。有効化後もプレイヤーは探索を続けられる。

通常のマップ間にはTransition Portalを置く案とする。現時点の案では、活動中プレイヤーの過半数がPortalへ入るとTransitionを開始し、30秒のカウントダウンを行う。過半数条件が崩れればキャンセルし、死亡・離脱に応じて分母を再計算する。Soloでは本人の通過で開始できる。

Transition成立時に残っている活動中プレイヤーをどう扱うか、カウントダウンとParty Stateの評価タイミングを含め、最終仕様は未決定である。遷移先決定にParty Stateを用いる方針は[ゲームループとポータル遷移](game-loop.md)を参照する。

## ServerとClientの責務

ゲーム進行上の事実はServerが決定し、Clientは主に表現を担う。

| Server | Client |
| --- | --- |
| Map State、Anomaly State、NPC State、Combat Event | UI、音響、カメラ、エフェクト |
| Portal State、Quest State、Inventory、Secure Slot、Run State | 個人にのみ見える演出、Individual Anomalyによる知覚差 |
| Shared BGM、Shared World State | Serverが決定した事実の表示 |

## 未決事項

- Anomaly TransformationとPlayer Anomalyの関係、および変化後にRunを継続できる条件。
- 各終了条件における資産・Quest・Discoveryの持ち帰り扱い。
- 4スキル枠の確定、スキル取得・強化・失効の詳細。
- Anomaly Systemの計算式、Critical Anomalyの判断基準、マップごとの互換性・制約。
- Transitionの過半数判定、30秒カウントダウン、残留プレイヤーの扱い。
- Return Portalの有効化条件と、マップごとのTerminationとの優先関係。

## 関連資料

- [ゲームループとポータル遷移](game-loop.md)
- [マップとギミック案](map-gimmick-ideas.md)
- [ゲームシステムドキュメント](README.md)
