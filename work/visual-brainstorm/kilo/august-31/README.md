# 8月31日 — 2D 設定画（Visual Brainstorm）

**Status: Visual brainstorm（非正典・制作途中）**

8月31日マップの 2D 設定画。Studio 実装の外観は無視。MD の設計から視覚仮案を描いた。

## 根拠（MD）

- [マップとギミック案](../../../../docs/systems/map-gimmick-ideas.md) — 8月31日: 夏休みの終端、ゾーン構成（LOBBY, ROAD, VILLAGE, SHRINE, RICE, RIVER, APARTMENT, TUNNEL, FOREST, DAM）、昼→夕方→夜の時間進行、帰還と 8月32 日。
- [008: 8月31日の景観構成](../../../../docs/decisions/008-august-31-landscape-composition.md) — 視線の順序（バス停→道と送電線→集落・田・河原→水面と稜線→丘上の団地）、植生は球状 Canopy の量塊、湖畔は葦と石、送電柱の低密度電線、団地は遠景マーカー。
- [舞台設定](../../../../docs/world/setting.md) — 架空世界、平成的な都市文化の記憶、古い技術と新しい技術の混在、実在の地理・商標の回避。

## 描画物

- `august-31-view.html` — 前景（バス停）/中景（道・集落・田・河原）/遠景（湖・稜線・団地）の 3 層構成を描画。ブラウザで開ける。
- `august-31-view.png` — 同上を純粋 Python (pypng) で生成。
- `august-31-view.svg` — 同上を svgwrite で生成（多数の図形で構成）。
- `draw_august31.py` / `draw_august31_svg.py` — 描画スクリプト。

## 未確定事項（仮案）

- 空の色・雲の密度、湖の面積は未決定。
- 団地の手前広場の規模と植栽は未決定。
- 集落の建物数と配色は仮案。
- 送電線の数と張力は仮案。
- 田の水路の形状・水量は仮案。
