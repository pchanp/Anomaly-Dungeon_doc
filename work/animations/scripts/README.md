# Mixamo → 標準R15 固定手順

**Status: 採用（2026-10-17ユーザー指定）。Blender 5.2.1 LTSで再実行確認。独自Rigは対象外。**

Retargetの正本は `retarget_mixamo_r15.py`、Robloxへの姿勢座標変換は `export_r15_pose_samples.py`（anatomical v2）、導入は `import_r15_pose_samples.luau`（schema v2）。対話Consoleへの長文貼付は必須にしない。Hook Punchのv002試行をストアド化し、v003で別プロセスの再実行・FBX出力を検証した。

## 入力条件

- Object Mode、通常のMixamo Armatureと公式R15 Armature（LowerTorso等の17ボーン）。SourceとTargetを明示する。
- SourceにActive Actionがある。Sourceボーン名のnamespaceは自動検出し、短名重複は停止する。
- 正の一様スケールのみ。Objectの親・制約・アニメーション、Active NLA、Driver、非標準継承、Targetボーン制約は未対応として停止。
- 原本blendを保持。出力Action名・出力ファイルには新しい版を指定する。既存ファイルや同名Actionの上書きは拒否する。

## Blender内から

Python Consoleでファイルを読み込み、関数を実行する。パスは実環境へ置き換える。

```python
import runpy
workflow = runpy.run_path('/absolute/path/work/animations/scripts/retarget_mixamo_r15.py')
workflow['run'](source='Armature.001', target='Armature',
    action_name='HookPunch_R15_v004', root_mode='KEEP',
    blend_path='/absolute/path/hook-punch-retarget-v004.blend',
    fbx_path='/absolute/path/hook-punch-r15-v004.fbx',
    report_path='/absolute/path/hook-punch-r15-v004.json')
```

`blend_path`・`fbx_path`・`report_path`を省略すると、指定した出力だけを省略する。Targetへ新Actionを割り当てる。以前のActionは改名せずFake Userで保持し、Sourceと骨格Restデータは保持する。自動ロールバックは行わないため、失敗時は原本からやり直す。

## CLIから

リポジトリのルートで実行する。`<blender>`はBlender実行ファイル。

```sh
<blender> --background <input.blend> --python-exit-code 1 \
  --python work/animations/scripts/retarget_mixamo_r15.py -- \
  --source Armature.001 --target Armature --action-name HookPunch_R15_v004 \
  --root-mode KEEP --blend-path <new-output.blend> \
  --fbx-path <new-output.fbx> --report-path <new-report.json>
```

## 固定する処理と通過条件

1. Source/Target、15ボーン対応、Action範囲、制約・座標条件を検査。
2. `tail_local - head_local`でArmature空間の基準方向を取得する。`Bone.vector`は親相対のため基準方向に使わない。
3. A/T姿勢の基準方向とObject回転差を補正し、Source姿勢を階層ローカルQuaternionへ変換。
4. 腰位置をSource/Targetのローカル脚長比で変換（腰の原点距離を身長として扱わない）。`KEEP`はXYZ、`IN_PLACE`はワールドZの上下のみ、`NONE`は転送しない。ゲームの移動は別処理。
5. 全フレームへ15ボーンの回転と腰位置をBake、Quaternion符号を連続化、Linear補間。
6. 全フレームで有限値・Source方向差・焼き込み姿勢差・骨長を検査。角差0.001rad／長さ差0.0001以上で停止。結果をTextとJSONへ保存。
7. 指定時のみTarget単体をFBX出力（葉ボーンなし、全Action/NLA出力なし、キー削減なし）。別blendへ保存し、開き直してTarget Action・フレーム・キー数を確認。

Hook Punch v003: 1〜65F、30fps、15ボーン、63カーブ、4,095キー。方向差の測定最大0度、骨長差約1.58e-6。数値一致は見た目・接地・接触・Studio再生の合格を意味しない。

## Studioへの導入

通常FBXインポートの原本を保持する。今回の公式テンプレートFBXはImportに成功したが、`RootNode/Armature/Root/HumanoidRootNode`と骨軸が残った。これをそのまま標準R15の実行用にしない。

`export_r15_pose_samples.py`でBake済みTargetをRobloxパーツ座標のPoseへ変換する。

```sh
<blender> --background <baked.blend> --python-exit-code 1 \
  --python work/animations/scripts/export_r15_pose_samples.py -- \
  Armature <new-poses.json>
```

頭の軸・左右の肩・足先から解剖学的な右／上／前を決め、Robloxの右+X・上+Y・前−Zへ変換する。Rest回転除去・親子相対回転・余分なルート除外も行う。上方向だけを合わせる旧v1は前後逆の原因となったため使用禁止。Studio側で `import_r15_pose_samples.luau` の関数へJSONDecodeしたデータと保存先を渡す。標準R15のJoint Attachment回転がidentityであることが前提。独自Rigや別Attachment軸へ無条件流用しない。

- 実行用階層は `HumanoidRootPart → LowerTorso → UpperTorso/脚`。
- Action優先度、Loop=false、全フレームを確認する。
- Animation Editorでレビューし、体験所有者に合うAnimationとしてPublish。取得IDを設定に記録。
- Studio一時IDと公開Animation IDを区別し、実ゲーム・複数Clientで検証する。

[W05作業部屋](../README.md)、[標準工程](../../../docs/production/animation-pipeline.md)、[Hook Punch記録](../motions/hook-punch-sample/README.md)を参照。

## 前後逆を防ぐ必須ゲート（anatomical v2）

公式テンプレートはArmatureローカルの左+X、上+Y、前+Z。Robloxは左−X、上+Y、前−Z。旧式の `RotX(-90°) @ matrix_world.rotation` はこのモデルでほぼidentityとなり、前を+Zへ出していた。修正はルートを180度回す操作ではなく、全ボーンの回転・腰移動に対する座標基底の変換。

- 足先が解剖学的前と矛盾したらExport停止。出力orientationにforward=(0,0,-1)、right=(1,0,0)、up=(0,1,0)を保存する。
- Importはschema v2と `r15-anatomical-v2` manifestを必須とし、旧v1・前+Zのデータを拒否する。
- シーンのObject回転に左右されない。Rigローカルの解剖学的軸から変換する。
- [Blender回帰検査](tests/check_r15_orientation.py)：旧v004の前後逆を負例として再現し、新形式の向き、左右、65F、腰位置を含む180度基底変換、Object回転への独立性を確認。
- [Studio回帰検査](tests/verify_hook_punch_facing.luau)：Hook Punch開始時の両拳が肩より前にあるというSourceの意味を検査。旧clipは失敗、修正clipは成功。キャラクターYaw0度／90度でも同じ結果。別モーションでは別の意味的な確認区間を決める。

```sh
<blender> --background <baked-v004.blend> --python-exit-code 1 \
  --python work/animations/scripts/tests/check_r15_orientation.py -- \
  work/animations/motions/hook-punch-sample/export/hook-punch-r15-poses-v004.json
```

現在の修正版Poseは `hook-punch-r15-poses-v005.json`、Studio Sequenceは `HookPunch_R15_v005`。焼き込みblendはv004を維持する（今回の障害点はExportの座標変換であり、Retargetをやり直したものではない）。

公開済みID `95405144949752` は旧v1の姿勢であり、再利用しない。TensikeiConfigのAnimationIdOrientationはlegacy-v1として履歴を保持し、Studioでは修正Sequenceを使用、Studio外では未検証向きのIDを拒否する。修正版を公開し、公開asset自体でも方向検査を通してからIDとprofileを更新する。公開済み旧assetをコード修正だけで直った扱いにしない。

## Roll／Runへの適用記録（2026-10-18）

`prepare_movement_retargets.py` は `_template/source/Sprinting Forward Roll.fbx` と `Standard Run.fbx` を公式R15原本へ順番にImportし、既存retarget/exporterを呼び出す保存済み実行スクリプト。`motions/sprinting-forward-roll`／`standard-run` へ原本コピー・v001 blend／FBX／Poseを保存する。既存出力は上書きせず停止するため、再試行は出力と記録を確認し、版を明示して変更する。

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background --python-exit-code 1 --python work/animations/scripts/prepare_movement_retargets.py
/Applications/Blender.app/Contents/MacOS/Blender --background --python-exit-code 1 --python work/animations/scripts/tests/check_movement_reopen.py
```

両方とも `IN_PLACE`。Hook Punchの拳位置テストは流用せず、`tests/verify_movement_facing.luau` で前傾と前転の意味的方向を実R15・Yaw0°／90°で確認する。Studio導入時はSource変更前のrequireキャッシュを避け、ImporterをCloneしてrequireし、終了後にCloneを破棄する。公開用クリップ・実装設定・残件は[適用記録](../../../docs/systems/movement-animation-integration.md)を参照。

## shade.fbxの互換補正と適用（2026-10-18）

`prepare_shade_retarget.py`は当該Comfy exporter入力専用の互換補正を先行し、共通のRetarget／Pose exporterを呼ぶ。単位Transformかつ非アニメーションのMesh親から骨格RootをSceneへ外し、骨格の解剖学的軸をTargetに整列してからBakeする。非単位Transform・想定外の接続数・非軸整列の入力は停止する。他FBXへ無条件適用しない。現行出力はv002、`tests/check_shade_reopen.py`で保存後の全Pose一致・水平移動除去・Source／Targetの前方向を検査する。[入力・原因・成果物とStudio記録](../motions/shade/README.md)。
