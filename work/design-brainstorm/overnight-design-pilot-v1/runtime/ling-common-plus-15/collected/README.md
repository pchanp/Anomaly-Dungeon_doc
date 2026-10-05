# Ling回 ABC追加45案 — Codex補正・補完

Status: Idea（候補・未採用）。RUN_ID=overnight-design-pilot-v1。

[全45案のHTML一覧](index.html)。全マップ共通、各ROLE031〜045。001〜030には変更なし。

## 完了

- A: 保存済み15件を補正。架空の参照見出し、JSON型、管理ファイル、局所状態とRuleOverrideの分類を修正。
- B: 保存済み15件を補正しmanifest等を作成。死亡・Run終了の喪失とSecure Slotを上書きせず、通常探索品の生存中の操作へ限定。
- C: 保存済み9件を補正し040〜045をCodexが作成。系統固定枠という表現、根拠Status、作用の分類を修正。
- 全45件のHTMLを簡潔な仕組み・選択・代償中心に整形。図は作用の流れであり地形案ではない。
- 各15件のmanifest/index/progress/events/handoffを保存。

OpenCodeの元出力はローカルのroots/に維持。本collectedが今回の補正済み正規成果物。元39件ペアのハッシュはopen-code-source-hashes.json。元ファイルは別案として数えない。
入力は読み取り専用common-packのスナップショット。正本docs/、src/、Studio、acceptedは変更なし。common-packの配布済み内容も変更なし。

## 検証

- スキーマ・予約ID・実在見出し・Status・参照・SVG/XML・ローカルリンク・個数・重複を確認。
- 共通検証器final: エラー0、A15/B15/C15。詳細はvalidation-final.json。
- Chrome390px幅で全45HTMLを描画。SVG文字は枠内、横溢れなし、JS例外なし。検索45→1件を確認。
- browser-check.jsonとpreview/の45PNGを保存。contact-sheet.pngは代表6件。
- 機械検証は面白さ・バランス・世界観の採用判断を保証しない。JSONのcomponent_implementation_reviewとuncertaintyは採用前の確認項目。

## 採用時の論点

- Aの通常モブは局所イベント・少数発生の仮説。上限・補充・非戦闘退場の時間を決める。Entityの発生枠とは別。
- 案内NPC031/045、交換品B035/038、収納品B032/034は用途が近い。発動条件と失うものを比較し、両方を採用する必要はない。
- 一方向ゲートA042は局所作用に限り、唯一の出口やPortalへの経路を塞がない。
- Bの用途変換・交換・餌は対応品を限定する。Quest品・固有交換品・レアルート品・Secure Slot内容物は対象外。合成対応表と品の具体的効果は未確定。
- Cの対応物、低い隙間、掴み、飛来攻撃、音・影の判定は未実装または未確認。汎用Entity対策にしない。
- C040は着地硬直、既存C014は残存移動の減速。C044は反響測定、既存C015は足音囮。目的と作用を分ける。
- 全45案requires_code=true。分類カタログへの接続可能性と実装済みは区別。実装許可ではない。

## 今後の運用

ユーザー方針により単一実行。並走が障害原因であるとの断定はしない。自動再指示の旧監視処理は停止済み。
次回はSINGLE-RUN-OPERATIONS.mdの追加指示を共通パックと併せて配布する。保存場所、実在見出し、boolean表記を明示。
無料提供側の429・Endpoint is unavailableによる中断と手動再試行があるため、今回の経過時間を純粋な生成所要時間の目安にはしない。
