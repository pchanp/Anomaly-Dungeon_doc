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
