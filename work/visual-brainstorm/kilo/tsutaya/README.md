# Abandoned TSUTAYA — 2D 設定画（Visual Brainstorm）

**Status: Visual brainstorm（非正典・制作途中）**

閉店直後だが誰も回収に来ないレンタル店アーカイブの 2D 設定画。Studio 実装の外観は無視。MD の設計から視覚仮案を描いた。

## 根拠（MD）

- [マップとギミック案](../../../../docs/systems/map-gimmick-ideas.md) — TSUTAYA: 7 ルーム（FRONT, VHS, DVD, CD, BROADCAST, TAPE, BACKROOM）、通路（LINKS）、棚（ArchiveShelf）5 基による Archive Selection UI、CRT 4 台、試聴機 3 台、放送室・返却作業場。
- [009: TSUTAYA を閉店直後のアーカイブとして再構成](../../../../docs/decisions/009-tsutaya-closing-time-archive.md) — 基準状態は「閉店直後だが誰も回収に来ないアーカイブ」。棚は大半残り（背表紙密度で空間）、店頭は最も明るく（レジ・会員端末・販促面）、放送室と返却作業場は暗く（作業物・未整理ケース）、落下ケースと欠番は少数。埃・剥離・漏水などは後から追加する層。
- [舞台設定](../../../../docs/world/setting.md) — 架空世界、平成的な都市文化の記憶、古い技術と新しい技術の混在、実在の地理・商標回避。ブランド表示は描かない。

## 描画物

- `tsutaya-view.html` — 室内の斜め上面視点。前景（入口・レジ）、中景（棚列・背表紙）、奥（放送室・作業場）の 3 層。
- `tsutaya-view.png` — 同上を純粋 Python (pypng) で生成。
- `tsutaya-view.svg` — 同上を svgwrite で生成。
- `draw_tsutaya.py` / `draw_tsutaya_svg.py` — 描画スクリプト。

## 未確定事項（仮案）

- 店内の配色・棚の色は仮案。
- 各ルームの面積比は未決定。
- 蛍光灯の生存率・明かりの強さは仮案。
- メディアの背表紙の色・種類は抽象化。
- 放送室の機材・返却カートの詳細は仮案。
- 店内看板の文字は架空語。
