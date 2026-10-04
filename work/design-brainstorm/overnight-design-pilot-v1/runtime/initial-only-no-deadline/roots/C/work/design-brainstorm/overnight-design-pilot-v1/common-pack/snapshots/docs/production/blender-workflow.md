# Blender作業

**Status: Draft（草案）**

## 対象

制作パイプライン内で繰り返し発生するBlender作業の確認項目を管理します。バージョンやアドオン固有の詳細は [`../references/blender.md`](../references/blender.md) に記録します。

## Import

- 使用したBlenderバージョンとFBXの出所を記録する。
- Unit、Scale、Axis、Armature、AnimationのImport結果を確認する。
- SourceとTargetのArmatureおよびActionを識別する。

## Rig / Pose

- Object ModeとPose Modeの状態を確認する。
- Rest PoseとAnimation Poseを混同しない。
- Bone hierarchy、Bone orientation、Scaleを確認する。
- MeshのParent、Armature Modifier、Weightを確認する。

## Retarget / Bake

- Source / TargetとBone Mappingを明示する。
- Retarget後はTarget側Actionへ必要なKeyframeをBakeする。
- NLA、Action、現在のフレーム範囲を確認する。
- Target単体でAnimationを再生して検証する。

## Export

- 対象Mesh、Armature、必要なAnimationだけを出力対象にする。
- Export前にTransform、Action、フレーム範囲を再確認する。
- Roblox StudioでImportした結果を最終判定とする。
