# キャラクター制作パイプライン

**Status: Draft（草案）**

## 目的

生成または制作した3Dキャラクターを調整し、Rig、アニメーション、Roblox上の動作確認まで一貫して扱います。

## 標準工程

1. Model Generation / Modeling
2. Model Cleanup
3. Topology / Mesh Check
4. Material / Texture Check
5. Rigging
6. Skin Weight Check
7. Animation / Retarget
8. Animation Cleanup / Bake
9. Roblox Import
10. In-game Validation

## ツールの位置付け

- Blender: モデル、Armature、Weight、アニメーションの確認と出力。
- DeepMotion: Source Motionを取得する選択肢。
- Tripo: モデル生成の選択肢。
- AccuRIG: Riggingの選択肢。
- Rigify: Blender内のRig補助として必要に応じて使用する選択肢。
- Retargetツール: Source ArmatureからTarget Armatureへ動きを移すために使用する。特定製品を必須としない。

上記のうち、実際に採用するツールは対象アセットごとに確認します。候補であることだけを理由にCurrent Standardとして扱いません。

## 検証

- MeshがArmatureに正しく追従する。
- 極端なPoseで目立つ破綻がない。
- 必要なAnimationがTarget ArmatureへBakeされている。
- Roblox上で向き、スケール、再生速度、接地を確認できる。
