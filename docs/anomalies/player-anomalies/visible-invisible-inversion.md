# Visible / Invisible Inversion

**Status: Draft（草案）**
**Type: Player Anomaly**

## 概要

Visible / Invisible Inversionは、プレイヤー自身に発生するアノマリー。単純に隠れているものを発見する能力ではなく、**世界における可視性そのものが反転する**。

## 発生条件と基本規則

Anomaly Exposureが一定段階に到達した場合に発生する案とし、通常の探索能力やDetect系スキルとは区別する。

通常はVisible Componentが見え、Invisible Componentが見えない。Visible / Invisible Inversionでは、この対応関係が反転する。

可視性の反転は単なる情報取得能力ではない。Visible ComponentとInvisible Componentの双方が実体、Runtime、ゲームプレイ上の作用を持つため、プレイヤーが何を見ているか自体が世界との相互作用に影響する。

## 認識と情報の信頼性

発生後は、外見だけではオブジェクトの正体を判断できなくなる場合がある。通常なら意味のある外見を持つオブジェクトが、無意味なものとして見える可能性がある。

内部ComponentをInteractで参照して情報を取得できるが、ダミー情報が混在する案とする。

```text
見える
    -> Interact
    -> Component情報取得
    -> 正しい情報 / ダミー情報
```

完全攻略を保証しない。

## マルチプレイ

同じ世界・同じオブジェクトでも、Player AにはVisible、Player BにはInvisibleという認識差が成立し得る。これはClientごとに世界の事実が別々になることを意味しない。Serverが共有世界状態を保持し、各プレイヤーの可視性・認識だけを変える。

## ゲームプレイ上の役割

- Exploration。
- Information収集。
- Anomaly識別。
- [Memory Swapper](../memory-swapper.md)との相互作用。
- 他プレイヤーとの情報共有。
- 情報の信頼性。

## 設計原則

「見えないものが見える」便利能力にはしない。本質は、何が存在しているかではなく、何を存在として認識できるかが変化することにある。

## Run Scope

Player AnomalyはRun単位で発生し、Run終了後は通常状態へ戻る。Player Anomalyの全体方針は[ゲームループとポータル遷移](../../systems/game-loop.md)を参照する。

## 未決事項

- Exposureの具体的閾値。
- Visible / Invisible Componentの具体的分類。
- ダミー情報の生成規則。
- UI上での情報表現。
- 他プレイヤーへの可視性差の具体的演出。

## 関連資料

- [Memory Swapper](../memory-swapper.md)
- [ゲームループとポータル遷移](../../systems/game-loop.md)
