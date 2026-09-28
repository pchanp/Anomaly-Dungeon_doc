# アニメーション制作パイプライン

**Status: Draft（草案）**

## 目的

DeepMotion等から得たSource MotionをBlenderで対象モデルへリターゲットし、Robloxで利用可能なAnimationとして導入します。

## Current Standard

```text
DeepMotion等でSource Motionを取得
  -> Animation FBX
  -> BlenderへImport
  -> Source / Target Armatureを確認
  -> Bone Mappingを設定
  -> Target ArmatureへRetarget
  -> AnimationをBake
  -> Roblox向けAnimation FBXをExport
  -> Roblox StudioのAnimation EditorへImport
  -> Publish
  -> 実ゲーム相当のRigで検証
```

リターゲット工程は特定の外部プラグインを必須としません。採用ツールは対象Blenderバージョンで検証し、操作方法は [`../references/retarget.md`](../references/retarget.md) に記録します。

## Blenderでの確認

- Source ArmatureとTarget Armatureを取り違えていない。
- Rest Pose、Scale、Rotation、Bone Mappingが適切である。
- Target側のActionへ必要なKeyframeがBakeされている。
- Source Armatureを非表示または削除してもTarget側だけで再生できる。
- ExportするActionとフレーム範囲が意図どおりである。

## Robloxでの検証

- 対象SkeletonへImportできる。
- Animation Editorで全フレームを再生できる。
- Publish後のAnimation IDを記録している。
- Animator / AnimationTrack経由で対象Rigに再生できる。
- 再生速度、ループ、接地、Root Motion相当の挙動を実ゲーム環境で確認している。

## Optional

- Rigify: Rig構成や編集の複雑さが必要な場合の補助。

## 必須依存ではないもの

- Rokoko Blender Plugin: 互換性問題が確認されているため、現時点では標準工程の必須依存にしない。
