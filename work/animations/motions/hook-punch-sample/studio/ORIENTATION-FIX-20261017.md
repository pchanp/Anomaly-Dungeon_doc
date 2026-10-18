# 前後逆の再現・原因・固定手順修正

**Status: 原因確定・ローカル／Studio修正・回帰検査Pass。修正assetの再公開は未完了。**

## 原因

`export_r15_pose_samples.py` v1は `RotX(-90°) @ rig.matrix_world.rotation` で上だけを合わせた。このテンプレートのArmature世界回転はX+90°なので合成はほぼidentity。テンプレートローカルの左+X／前+Zが、そのままRobloxの右+X／後+Zとして扱われた。必要なのは右・上・前の意味を対応させる基底変換だった。

実テンプレート: 左肩head X=+0.469644、右肩head X=-0.469644、頭の軸+Y、両足先+Z。実Roblox R15の左肩はRoot基準X=-1.472、前方はRoot.CFrame.LookVector（ローカル−Z）。

Sourceの開始姿勢では、肩から拳への前方+Z成分が左24.387／右33.803（Sourceローカル単位）。両拳が前にあるべきという、座標変換の実装から独立した確認区間を得た。

公開ID95405144949752の回転はローカル旧v004と最大角差約0.00129rad。公開版のLowerTorso位置は0（ローカルv004と最大約0.677stud差）だったが、前後逆は肩から手への相対投影でも再現し、腰位置の差に依存しなかった。ユーザーの登録操作の成否が原因ではない。

前回のSource/Target方向一致はBlender内での検査であり、その後のRoblox出力の前方向は保証しなかった。AnimationTrackの読み込み成功・時間進行・手のCFrame変化だけを確認した検証も、この意味的な逆向きを検出できなかった。以前の別件について同じ原因と断定できる記録は未発見。

## 修正

- Head軸を上、RightUpperArm−LeftUpperArmを右、上×右を前としてArmatureローカルの正規直交基底を作る。左右の足先と前の整合も検査。
- 全ボーンの回転と腰移動を、右+X／上+Y／前−ZのRobloxモデル空間へ変換。今回のデータでは旧Poseに対するモデルY軸180°の基底変換に相当する。Rootやキャラクター本体を180°回す処理ではない。
- schema v2／orientation profileを保存。Importerは旧v1、前+Z、不正な向きのmanifestを拒否。
- 修正版Pose `export/hook-punch-r15-poses-v005.json`、Studio実行用 `ReplicatedStorage.AnomalyDungeon.Animations.HookPunch_R15_v005`。元blendはv004を保持し、再Bake不要。
- 旧Sequence v003／v004は保持してDeprecated・SupersededByを付与。公開ID95405144949752はConfigのAnimationIdOrientation=legacy-v1として保管し、実行用に採用しない。
- TensikeiServiceはStudioではprofile検証済みのv005から一時IDで再生。Studio外では向きを未検証の公開IDを拒否する。修正版を同ID更新または別IDで公開し、公開asset自体を方向検証してからID/profileを更新する。

## 再現・回帰検査

`tests/check_r15_orientation.py`を実際のv004.blendで実行してPass。旧変換の前+Zを負例として検出。修正basisの前−Z／右+X／上+Y、左右肩、65F、位置と回転、Object回転への独立性を検査。独立したY180°基底変換との最大差約4.19e-7。

`tests/verify_hook_punch_facing.luau`を実R15の一時Cloneで実行。前方成分はRoot.LookVectorへ「手−上腕位置」を投影（stud）。

| Clip | Yaw | 左拳 | 右拳 | 判定 |
| --- | --- | --- | --- | --- |
| 旧v004 | 0° | -0.22646 | -0.79047 | Fail（再現） |
| 修正v005 | 0° | +0.22645 | +0.79046 | Pass |
| 旧v004 | 90° | -0.22644 | -0.79053 | Fail（再現） |
| 修正v005 | 90° | +0.22656 | +0.79053 | Pass |

実公開旧IDでも開始時は同じ負方向になった。修正manifestのv005を纏絲勁から再生し、約2.133秒のAction Trackが有効で、旧公開IDを使用していないことも確認。テスト用Cloneは破棄し、Playは停止、Editに修正版を残した。

測定JSON: orientation-regression-20261017.json。既存攻撃のダメージ・判定向き・キャラクターの向きは変更していない。

## 残件

修正済みclipはPreviewのAnimSavesとReplicatedStorageに配置・選択済み。native UIは `Sky Computer Use native pipe startup failed` のままで、修正版のPublish操作は行えていない。旧公開assetを更新済みとは扱わない。見た目の最終レビュー・修正版の公開ID再検証・実2Client／公開ゲームの検証は残る。プレース保存とゲーム本体の公開は行っていない。
