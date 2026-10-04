# Kilo 担当 — 5マップ 2D 設定画（Visual Brainstorm）

**Status: Visual brainstorm（非正典・5マップの可視案作成済み）**

Kilo が担当する 5 マップの 2D 設定画。各マップごとに HTML（描画可能）＋ SVG を生成し、MD で根拠・仮案・未確定事項を記録。

| マップ | 描画 | 根拠（MD） |
| --- | --- | --- |
| 8月31日 | [HTML](august-31/august-31-view.html)、[SVG](august-31/august-31-view.svg)、[PNG](august-31/august-31-view.png) | [マップ案](../../../docs/systems/map-gimmick-ideas.md)、[景観構成](../../../docs/decisions/008-august-31-landscape-composition.md) |
| Abandoned TSUTAYA | [HTML](tsutaya/tsutaya-view.html)、[SVG](tsutaya/tsutaya-view.svg)、[PNG](tsutaya/tsutaya-view.png) | [マップ案](../../../docs/systems/map-gimmick-ideas.md)、[閉店直後のアーカイブ](../../../docs/decisions/009-tsutaya-closing-time-archive.md) |
| SEKIGAHARA | [HTML](sekigahara/sekigahara-view.html)、[SVG](sekigahara/sekigahara-view.svg)、[PNG](sekigahara/sekigahara-view.png) | [マップ案](../../../docs/systems/map-gimmick-ideas.md) |
| KOROHKAN | [HTML](korohkan/korohkan-view.html)、[SVG](korohkan/korohkan-view.svg)、[PNG](korohkan/korohkan-view.png) | [マップ案](../../../docs/systems/map-gimmick-ideas.md) |
| Observation / Open Liminal Map | [HTML](open-liminal/open-liminal-view.html)、[SVG](open-liminal/open-liminal-view.svg)、[PNG](open-liminal/open-liminal-view.png) | [マップ案](../../../docs/systems/map-gimmick-ideas.md) |

共通の描画方針（前の Kilo セッションの README に準ずる）:

- 各対象を実際に見られる 2D 画像または HTML/SVG として残す。根拠・仮案・未確定要素を併記。
- 実在の都市、国家、商標、既存作品の固有意匠をそのまま再現しない。特に TSUTAYA は現在の Map ID であり、プレイヤー向けの店名を確定したものではない。
- 仕様を勝手に確定しない。
- 前景/中景/遠景、光、素材の案が見えるようにする（単なる地図・文章ではない）。

各図の下部には代替の配色・光方向を示す小帯（ALT-○○）を 1 つ添えている。主案と代替案は同じ図の別案であり、いずれも仕様ではない。

生成手段: 純粋 Python (pypng)、svgwrite、Canvas API（HTML）。
PNG は HTML をヘッドレス Chrome で 1600x1200 で撮影したもの。コミット・プッシュは行わない。
