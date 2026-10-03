# KOROHKAN — 2D 設定画（Visual Brainstorm）

**Status: Visual brainstorm（非正典・制作途中）**

虎牢関などを抽象化した複数勢力が攻め続け・守り続ける巨大要塞の 2D 設定画。Studio 実装の外観は無視。

## 根拠（MD）

- [マップとギミック案](../../../../docs/systems/map-gimmick-ideas.md) — KOROHKAN: 歴史的虎牢関などを抽象化した複数勢力が攻め続け守り続ける巨大要塞。外郭・門・内郭・複数ルート・高所・裏道。
- プレイヤーの選択：Combat（正面突破）、Mobility（戦闘回避・別ルート侵入）、Exploration（隠し通路・物資）、Hybrid（戦況変化の隙に突破）。
- SEKIGAHARA より戦場と探索の比重を高く。

## 描画物

- `korohkan-view.svg` — 外郭の門、砦の石垣、高所の塔、門前広場、攻める兵団（前景）を斜め上面視点で。
- `korohkan-view.html` — 同上を Canvas 描画でブラウザ表示可能に。
- `draw_korohkan.py` — SVG 描画スクリプト。

## 未確定事項（仮案）

- 門・石垣・塔の詳細形状、配色は仮案。
- NPC 勢力の所属・服装は未決定。
- 門の大きさ・城内の配置は仮案。
- 複数のルート・裏道の位置は仮案。
- 地形の高低・城壁の高さは未決定。
