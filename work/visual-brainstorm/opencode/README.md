# visual-brainstorm / OpenCode 担当分

**Status: Visual hypothesis（視覚仮説） ／ 2026-10-03 ／ 仕様確定ではない**

このディレクトリは、Anomaly Dungeon のアノマリーと登場NPCについて、**2Dイメージの視覚仮説を探った**記録である。
Roblox Studio 上の現行外観を参照していない。根拠は `docs/` の Draft 文書のみである。

## このディレクトリの位置づけ

- 仕様書・実装指示・設定資料 **ではない**。
- 外見は **候補の列挙** であり、どれか1つを選んだものではない。
- 外見未定の対象（博士・元同僚・`whisper`・Memory Swapper・`/dev/null`）は、**確定した姿として描かず**、
  複数のシルエットや現象の痕跡を並べている。
- 世界の謎の答え、アノマリーの正体、人物の年齢や経歴は描いていない。
- 具体的な顔・衣装・人体構造・意匠の細部を描き切ったものは、すべて **仮案** として各MDに明記した。
- 既存作品・実在人物・商標の模倣をしていない。

## ファイル

| ファイル | 対象 | Type | 内容 |
| --- | --- | --- | --- |
| [`index.html`](index.html) | 全体 | — | 7件の全体ボードと一覧。最初に開けばよい。 |
| [`01-miw.html`](01-miw.html) ／ [`01-miw.md`](01-miw.md) | MiW | Anomaly Entity | 棺に収まる猫型。発見の距離3段階と意匠3案。 |
| [`02-dev-null.html`](02-dev-null.html) ／ [`02-dev-null.md`](02-dev-null.md) | /dev/null | Anomaly Entity | 入力と結果の断絶。UI欠損。ゴミ箱表現は採用しない。 |
| [`03-memory-swapper.html`](03-memory-swapper.html) ／ [`03-memory-swapper.md`](03-memory-swapper.md) | Memory Swapper | Anomaly Entity | 物の位置と記憶のずれ。外見候補3案。Innocent。 |
| [`04-mad-stomper.html`](04-mad-stomper.html) ／ [`04-mad-stomper.md`](04-mad-stomper.md) | Mad Stomper（`GIANT`） | Anomaly Entity | 青緑色の身体、多数の眼、巨大な足、左足の花の胞子。歩行と鎮静。 |
| [`05-whisper.html`](05-whisper.html) ／ [`05-whisper.md`](05-whisper.md) | whisper | Anomaly Entity | Invisible／実体あり。音響・Signal UI・選択UI・追従。 |
| [`06-professor.html`](06-professor.html) ／ [`06-professor.md`](06-professor.md) | 博士 | NPC | 確信が強いが外見は未定。3案のシルエット＋居室の痕跡。 |
| [`07-former-colleague.html`](07-former-colleague.html) ／ [`07-former-colleague.md`](07-former-colleague.md) | 元同僚 | NPC | 対立と不在の痕跡。顔・年齢は描かない。 |
| [`vis.css`](vis.css) | — | — | 共通スタイル（全HTMLが参照）。 |
| [`preview/`](preview/) | — | — | 各HTMLをヘッドレスChromeでレンダリングした検証用PNG。 |

## 閲覧方法

各HTMLをブラウザで開くとそのまま読める（外部依存なし、同一ディレクトリの `vis.css` のみ参照）。
`preview/*.png` は同じ内容を画像化したもので、レイアウトの確認用である。

## Player Anomaly について

本ボードが作図した対象は **Anomaly Entity 5体と NPC 2名** である。
`Visible / Invisible Inversion` は **Player Anomaly** であり、本ボードの対象外である。
Memory Swapper の「通常プレイヤーには見えない／Inversion 発生中のプレイヤーには見える」は
Player Anomaly 側の性質として参照したが、Memory Swapper 自身の外見の確定には使っていない。

## 関連資料（正本）

- [`AGENTS.md`](../../../AGENTS.md)
- [`docs/anomalies/README.md`](../../../docs/anomalies/README.md)
- [`docs/anomalies/miw.md`](../../../docs/anomalies/miw.md)
- [`docs/anomalies/dev-null.md`](../../../docs/anomalies/dev-null.md)
- [`docs/anomalies/memory-swapper.md`](../../../docs/anomalies/memory-swapper.md)
- [`docs/anomalies/mad-stomper.md`](../../../docs/anomalies/mad-stomper.md)
- [`docs/anomalies/whisper.md`](../../../docs/anomalies/whisper.md)
- [`docs/anomalies/player-anomalies/visible-invisible-inversion.md`](../../../docs/anomalies/player-anomalies/visible-invisible-inversion.md)
- [`docs/anomalies/cognitive-anomalies.md`](../../../docs/anomalies/cognitive-anomalies.md)
- [`docs/world/setting.md`](../../../docs/world/setting.md)
- [`docs/world/information-design.md`](../../../docs/world/information-design.md)

本ディレクトリの内容は `docs/` の仕様を置き換えず、変更もしない。仕様変更が必要な場合は `docs/` 側の判断として記録する。
