# 03 ／ Memory Swapper — 視覚仮説

**Status: Visual hypothesis（視覚仮説） ／ OpenCode 担当分 ／ 2026-10-03**

可視ファイル: [`03-memory-swapper.html`](03-memory-swapper.html) ／ レンダリング済み画像: [`preview/03-memory-swapper.png`](preview/03-memory-swapper.png)

本ファイルは仕様書ではない。`docs/` の Draft 文書を根拠に、Memory Swapper の2Dイメージの候補を探った記録である。
`memory-swapper.md` は「**外見は固定しない**」と定めているため、**本体は描かず**、物の位置と記憶のずれ、候補表現3案、不可視性の分岐のみを並べている。

## (a) 根拠文書

| 文書 | Status | 本図で使った要素 |
| --- | --- | --- |
| [`docs/anomalies/memory-swapper.md`](../../../docs/anomalies/memory-swapper.md) | Draft / Prototype: Not Implemented | Friendliness: Innocent／Behavior: Wandering／Primary Effect: Item relocation／Combat Intent: なし。通常のプレイヤーには見えない。Inversion系のプレイヤーには見え、認識すると逃げる。外見は固定しない。ItemStack（Items＋LastRecognizedPlayer）間を移動し、対象に関連付けられたアイテムを追尾。追尾不成立・退出時は最寄りのItemStackへ戻る。盗みではない。 |
| [`docs/anomalies/player-anomalies/visible-invisible-inversion.md`](../../../docs/anomalies/player-anomalies/visible-invisible-inversion.md) | Draft / Prototype: Not Implemented | **Player Anomaly**。可視性対応が反転する。見えた対象の意味を誤認し得る。→本図では参照関係としてのみ注記し、対象化していない。 |
| [`docs/anomalies/cognitive-anomalies.md`](../../../docs/anomalies/cognitive-anomalies.md) | Draft | Recognition は「対象が異常である」ことを把握する段階。情報の不一致をトレードオフとして扱う。 |

## (b) 描画上の仮説

1. **本体を描かない。** 3つの候補表現（軌跡のみ／棚の並びのずれ／視線の有利な位置にだけ残る）を並べるが、どれも**存在の輪郭を持たない**。
2. **主角は「物」と「記憶マーカ」。** 同じアイテムが2箇所に同時に見えた状態と、LastRecognizedPlayer の三点（棚・人・線）を主役に据える。
3. **認識差は線で描く。** 誰の記憶で動いているかを分岐線だけで示す。これは Player Anomaly 側の性質であり、Memory Swapper 自身の外見の確定には使っていない。
4. **Innocentの描き方。** 追尾線に「追いかけ」「囲む」の要素を入れない。認識されたら元の位置へ戻る矢印のみ入れる。
5. **窃盗に見せない。** 鍵・袋・覆いなど「持ち去る」記号は使わない。移動は「そこに在ったはず」の線として描く。

### 図の内容

- **図1 ／ 位置のずれ**: 通常プレイヤーの視界／ずれの構造（本体不在）／可視性の分岐。
- **図2 ／ 外見の候補3案**: 案1 軌跡のみ／案2 棚の並びのずれ／案3 視線の有利な位置にだけ残る。3案とも「小型の実体」を前提にしていない。

## (c) 未確定要素

| 要素 | 本ボードでの扱い | 確定に必要な判断 |
| --- | --- | --- |
| 外見 | 候補3案を併記。輪郭を持たない | 実体の有無、可視化の方式 |
| 移動演出 | 軌跡・空白・視線の3種を仮置き | クライアントへの見せ方 |
| 2〜3スロットの選択方式 | 描かない | 選定規則 |
| 追尾対象の優先順位 | 単一対象の線のみ | 複数候補がいる場合の規則 |
| 他プレイヤーへの見え方の演出 | 分岐線のみ（要素のみ） | 可視性差の演出仕様 |
| 攻撃を受けた場合の反応 | 追尾線のみ（追いかけ要素なし） | 被弾時の挙動 |
| ItemStack状態モデル | 未実装（概念図のみ） | `memory-swapper.md` の実装前提 |

## 混同しないこと

本ファイルは **Anomaly Entity** の視覚仮説である。
「通常プレイヤーには見えない／Inversion 発生中のプレイヤーには見える」は **Player Anomaly** 側の性質として参照したが、
Player Anomaly自体をMemory Swapperの外形や都合で確定させてはいない。
