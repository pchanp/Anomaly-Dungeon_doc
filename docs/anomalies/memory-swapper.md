# Memory Swapper

**Status: Draft（草案）**
**Type: Anomaly Entity**

## 実装状況

**Prototype: Not Implemented（Studio確認: 2026-09-26）**

必要となるInventory／ItemStack、`LastRecognizedPlayer`、可視性差の基盤を含め未実装。先にアイテム状態モデルを設計・実装する必要がある。

## 概要

Memory Swapperは、物体に対する人間の認識や記憶による補完が具現化したアノマリー。アイテムそのものを奪う悪意ある存在ではなく、プレイヤーが「そこにあったはず」と認識した物を別の場所から移動させ、記憶と現実のずれを発生させる。

## 分類と可視性

- **Friendliness:** Innocent
- **Behavior:** Wandering
- **Primary Effect:** Item relocation
- **Combat Intent:** なし

通常のプレイヤーには見えない。Visible / Invisible Inversion系のPlayer Anomalyを持つプレイヤーには見え、そのプレイヤーを認識すると逃げる。

外見は固定しない。小型の存在として行動しているように見える可能性はあるが、実体や姿を完全に確定させず、「アイテムの位置が誰かの認識に合わせて変化している」現象を中心に置く。

## Item Stack Stateと挙動

各ItemStackは、最後にその場所のアイテムを認識・操作したプレイヤーを記録する案とする。

```text
ItemStack
    ├─ Items
    └─ LastRecognizedPlayer
```

Memory SwapperはItemStack間を移動し、特定プレイヤーに関連付けられたアイテムを移動させる。対象プレイヤーが存在する場合、2～3スロット程度のアイテムを取得し、対象プレイヤーを追尾し、そのプレイヤーに関連する位置へ移動する。

追尾が成立しなくなった場合、または対象プレイヤーが退出した場合、アイテムは最寄りのItemStackへ戻る。

## プレイヤーとの相互作用

これは盗みではなく、「そのプレイヤーにとって、そこにあるはずのもの」を補完している。プレイヤーからは、アイテムが勝手についてくるように見え得る。

Memory SwapperはInnocentである。通常プレイヤーが攻撃しても、必ずしも正当な敵対行動ではなく、敵対行動はAnomaly Exposureを増大させる可能性がある。

## ゲームプレイ上の役割

- アイテム探索。
- プレイヤー間の認識差。
- Inventory / ItemStackシステム。
- Player Anomaly。
- マルチプレイヤー間の情報差。

## 設計原則

アイテムを盗む敵にはしない。プレイヤーの認識や記憶をゲーム世界が補完した結果として、アイテム位置が変化する。

## 未決事項

- 具体的な外見。
- アイテム移動時の視覚演出。
- 追尾対象の選定優先順位。
- 2～3スロットの具体的な選択方式。

## 関連資料

- [Visible / Invisible Inversion](player-anomalies/visible-invisible-inversion.md)
- [アノマリードキュメント](README.md)
- [ゲームルール](../systems/game-rules.md)
