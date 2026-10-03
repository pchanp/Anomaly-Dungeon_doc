# Observation / Open Liminal Map — 2D 設定画（Visual Brainstorm）

**Status: Visual brainstorm（非正典・制作途中）**

閉鎖されたループ廊下ではなく、開けた風景で観察・反復・知覚の変化を扱うマップの 2D 設定画。Studio 実装の外観は無視。

## 根拠（MD）

- [マップとギミック案](../../../../docs/systems/map-gimmick-ideas.md) — Observation / Open Liminal Map: 閉鎖されたループ廊下ではなく、開けた風景で観察、反復、知覚の変化を扱う案。遠景の物体、建物、人物などが徐々に変化する。
- フロー：遠景を観察 → 微細な異常を発見 → 観察・Interaction → Focus / Recognition が進行 → 遠景の異常が明確になる → Portal が出現。
- Focus / Recognition は UI で直接表示せず、プレイヤー自身が「さっきより見えている」と感じることを重視。
- 短い Interaction の候補：目標位置に止める、一瞬だけ出る物体を認識する、ノイズから対象を見つける、音の方向を当てる、形状を識別する、違いを発見する。
- 完全に観察しなくても帰還できる一方、深く観察すると Rare Loot、FILE、特殊情報、新しい Anomaly を得られる可能性。観察するほど危険になる設計も検討対象。

## 描画物

- `open-liminal-view.svg` — 開けた草地、道、小施設（遠景に点）、街灯、人物、遠景の変化する物体、霧・光の筋を斜め上面視点で。
- `open-liminal-view.html` — 同上を Canvas 描画でブラウザ表示可能に。
- `draw_open-liminal.py` — SVG 描画スクリプト。

## 未確定事項（仮案）

- 小施設・街灯の詳細形状、配色は仮案。
- 人物の大きさ・数、遠景の物体の正体は未決定。
- Focus / Recognition の知覚変化の具体的な描画方法は未決定。
- Portal の出現位置・外観は未決定。
- 「観察するほど危険になる」場合の視覚表現は仮案。
