# Sprinting Forward Roll.fbx → R15

Status: Prototype: Implemented（2026-10-18、Studio反映・Play Solo検証済み）。公開ID発行と人間の見た目レビューは未完了。

用途: 既存スロット2のローリング（無敵属性に同期）。

原本は `motions/_template/source/Sprinting Forward Roll.fbx` に保持し、同一SHA-256のコピーを `source/` に保存した。[入力記録](source-manifest-v001.json)。出典URL・取得設定は未確認。

## 固定した工程

[W05固定スクリプト](../../scripts/README.md)と `prepare_movement_retargets.py` を利用。Blender 5.2.1 LTS、公式R15配布原本の `Armature` をTarget、FBX Import後の `Armature.001` をSourceとし、15ボーンを1〜30F・30fpsでBakeした。水平移動は既存ゲーム処理が担当するためRoot Modeは `IN_PLACE`。腰の上下・回転を保持する。

- 編集原本: `blender/sprinting-forward-roll-r15-v001.blend`
- FBX: `export/sprinting-forward-roll-r15-v001.fbx`
- 標準R15用Pose: `export/sprinting-forward-roll-poses-v001.json`
- 数値検証: [retarget-validation-v001.json](export/retarget-validation-v001.json)
- 実行用: `ReplicatedStorage.AnomalyDungeon.Animations.SprintingForwardRoll_R15_v001`

anatomical v2で前−Z／右+X／上+Yに変換し、旧v1をImporterで拒否する。保存blendを別プロセスで再読込し、全Poseが保存済みJSONと一致、水平Root移動なしを確認した。[再読込結果](../movement-reopen-qa-20261018.json)。実R15でYaw0°／90°の前傾方向を検査し、Rollは中盤で上下が反転することも確認した。Hook Punch用の拳の位置検査はこのモーションに流用していない。

## Studio導入と残件

[適用先・実行時設定・検証](../../../../docs/systems/movement-animation-integration.md)を参照。公開用クリップは `ServerStorage.RBX_ANIMSAVES.W05_Roll_R15_Preview` にある。

公開IDは未発行。現在はStudio限定の一時IDで再生する。UI操作用ツールは `Sky Computer Use native pipe startup failed` で起動せず、Publish画面を操作できなかった。Studio MCPによる導入・Play・キー入力は成功している。オンラインではID設定まで既存のMovementAnimationsを維持する。ゲーム本体の保存・公開は今回実施していない。
