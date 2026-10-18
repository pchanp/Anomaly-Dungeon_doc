# Blenderリターゲット

## 位置付け

Source ArmatureのAnimationをTarget Armatureへ移す工程です。プロジェクトは特定のプラグインだけに依存しません。

## ツール採用条件

- 使用するBlenderバージョンで動作する。
- Source / TargetのBone Mappingを確認できる。
- Target側へAnimationをBakeできる。
- 出力したFBXをRoblox StudioへImportできる。
- ツールを外した後もBake済みAnimationをTarget単体で再生できる。

## Current Status

- Blenderで利用可能なRetarget手段を検証して採用する。
- RigifyはOptional。
- Rokoko Blender Pluginは必須依存ではない。
- Blender Extensions上の候補は、対象バージョンとRoblox出力まで検証した後にCurrent Standardへ昇格する。

## 関連資料

- [アニメーション制作パイプライン](../production/animation-pipeline.md)
- [判断記録002](../decisions/002-animation-retarget-tool.md)

## ローカル検証スクリプト

[Mixamo → 標準R15スクリプト](../../work/animations/scripts/README.md)を骨格プレビュー用のDraftとして用意した。Blender 5.2.1でHook Punchの1〜65フレームを実行し、原本保持と回転変換を数値確認した。接地・見た目・FBX出力・Robloxでの再生は未検証で、標準採用済みのリターゲット手段ではない。


## 保存結果との対応（2026-10-15）

上記は骨格試作の実行記録。現在のblendへの出力保存は未確認であり、保存済み検査JSONではTargetにActionがない時点が記録されている。Source Import・試行実行・保存結果を区別する。詳細は[Hook Punchの個別記録](../../work/animations/motions/hook-punch-sample/README.md)を参照。

## 2026-10-17固定手順への更新

ユーザー指定により、Mixamo→公式R15は[保存済みスクリプト](../../work/animations/scripts/README.md)を固定手順に採用。以前の「標準未採用」「保存未確認」は当時の記録。v002の保存再読込と、固定スクリプトによるv003の再実行・検査・FBX出力を確認した。Studio Importの軸／階層変換も別スクリプトへ保存する。見た目・他Rig・公開後の互換性は別途検証する。
