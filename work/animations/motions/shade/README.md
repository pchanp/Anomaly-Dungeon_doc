# shade.fbx → Shade（スロット3）

Status: Prototype: Implemented（2026-10-18、標準R15へ変換・Studio反映・Play Solo確認済み）。公開ID発行と人間の見た目レビューは未完了。

ユーザー確認により、スロット3のStealthを表示名Shadeへ変更し、このFBXを発動モーションとして適用した。既存のステルス効果5秒・移動速度30・Cooldown10秒を維持する。モーションは1.583333秒を1倍・非ループで一度再生し、終了後も既存効果を継続する。資料のSHADE案にある瞬間移動・経路ダメージ・Stun・NPC検知変更はこのアニメーション適用では実装していない。

## 入力と固定手順

- 原本: `../_template/source/shade.fbx`。同一内容を `source/shade.fbx` へ保持。[入力記録](source-manifest-v002.json)。配布URLは未確認。
- Creator: `@comfyorg/fbx-exporter-three - 1.0.0`、Source Action `Sword_Dash_RM`。通常Mixamoダウンロードと同じ書式ではない。
- 再現スクリプト: [prepare_shade_retarget.py](../../scripts/prepare_shade_retarget.py)。公式R15原本へImportし、既存retarget/exporterを呼ぶ。既存blend／FBX／Poseの出力は上書きしない。
- 元FBXのMeshが、同じMeshをSkinで動かす骨格の親になっていた。Blenderのcollect_armature_meshesで循環ができ、成功応答でもObjectsが0件になることを再現した。MeshのTransformが単位・アニメーションなしであることを検査し、Import時だけ骨格Rootの親接続をSceneへ付け替える。原本・キー値は変更しない。[接続補正記録](export/import-compatibility-v002.json)。
- `mixamorigHips`等を`mixamorig:Hips`等へ名前正規化し、対応を一意にする。
- 原骨格の解剖学的上がシーンの上と一致しないため、頭／腰・左右の肩・足先から得たSource軸をTarget軸へ合わせる。[軸補正記録](export/source-axis-alignment-v002.json)。初回v001はこの意味的軸検査で不合格となり、保持したうえでv002へ置換した。
- 15ボーン、1〜39F、24fps、Root Mode `IN_PLACE`。水平Root移動は除去し、上下・身体回転を保持。anatomical v2でRobloxの前−Z／上+Y／右+Xへ出力。

## 成果物と検証

- `blender/shade-r15-v002.blend`／`export/shade-r15-v002.fbx`。
- [Pose samples](export/shade-poses-v002.json)、[Bake検証](export/retarget-validation-v002.json)、[保存後再読込検証](export/reopen-qa-v002.json)。骨長最大誤差約0.00000608、回転・方向誤差0度、保存後の全Pose完全一致。Source／Targetの解剖学的前方向dot約0.99625。
- 実R15・Yaw0°／90°で、初期上方向Y=0.98737、ダッシュ区間の前方傾き0.76553を確認。両Yaw同値。[Studio QA](studio/qa-20261018.json)。
- 実キー3で表示名Shade・新Track・速度1・非ループを確認。2.2秒時点でTrack終了／ステルス継続、5.6秒時点で効果解除・通常速度20へ復帰。再入力による再発動なし。

## Studio配置

実行用: `ReplicatedStorage.AnomalyDungeon.Animations.Shade_R15_v002`。旧v001はDeprecated／SupersededBy属性付きで保持する。

公開準備: `Workspace.W05_Shade_R15_Preview` のAnimSavesが `ServerStorage.RBX_ANIMSAVES.W05_Shade_R15_Preview` を参照する。公開する版はv002。

設定: `MovementAnimationConfig.Shade`。公開IDは空欄のためStudioは保存済みSequenceの一時IDを利用する。公開IDの発行・方向検証・設定差し替えは未完了。ゲーム本体の保存／公開は今回行っていない。

[実装の全体記録](../../../../docs/systems/movement-animation-integration.md#shadeをスロット3へ適用2026-10-18追記)。

## 後続更新：50スタッドの高速移動・経路判定

ユーザー指定・暫定数値確認により、50スタッド／0.3秒の移動、各対象25ダメージ＋0.5秒Stun、ワイヤーフレームを追加した。上記の1倍再生・移動／判定なしは初回導入時の記録で、現在は同じv002を3.5倍で再生する。入力FBX／Bakeの再生成は行わない。[現在の仕様・QA・制限](../../../../docs/systems/shade-prototype.md)、[実測](studio/dash-hitbox-qa-20261018.json)。
