# ローリング・Shift走行のアニメーション適用

**Status: Prototype: Implemented（2026-10-18、Studio Edit反映・Play Solo確認済み）。新assetの公開IDは未発行。**

## 適用内容

| 入力 | 適用先 | クリップ | 再生 |
| --- | --- | --- | --- |
| Sprinting Forward Roll.fbx | 既存スロット2のローリング | SprintingForwardRoll_R15_v001 | 元0.966667秒を約1.611倍で0.6秒に合わせる。非ループ・Action優先度 |
| Standard Run.fbx | 通常Shift長押しの走行 | StandardRun_R15_v001 | 元0.533333秒、既存倍率1.05・ループ・Movement優先度 |

ローリングは後続の20スタッド調整により、単発の水平速度50から0.6秒間の約33.333スタッド/秒へ変更した（下記追記）。上向き速度12・Cooldown4秒・無敵0.6秒、Shift走行のWalkSpeed24を維持する。左Shift押下時にはSkillControllerの既存の瞬間加速（55、Cooldown1.5秒）も発生する。この処理と長押し走行の併存は変更していない。纏絲勁用の前半3倍／後半2倍設定は、これらのモーションには適用しない。

## 実装

`MovementController` の関節Transformを直接操作する簡易Rollを削除し、既存のIsInvincible／IsRolling／Rolling属性の立ち上がりでRoll Trackを一度再生する。Sprint・SneakはRoll中に停止し、終了後はShiftと移動・接地状態で再開する。Stun／リザルト中はTrackを停止し、Stun中にWalkSpeedを書き換えない。死亡・Character変更でTrackと接続を掃除する。AnimatorはServer生成のものを待ち、Clientで新規生成しない。

- `src/StarterPlayer/StarterPlayerScripts/AnomalyDungeonClient/Controllers/MovementController.client.luau`
- 同ディレクトリ `MovementAnimationTracks.luau`: ID解決と読み込み。Studioでは検証済みSequenceを一度だけRegisterKeyframeSequenceする。
- `src/ReplicatedStorage/AnomalyDungeon/Shared/Config/MovementAnimationConfig.luau`: 公開ID、Sequence名、時間、倍率、Fade。

水平Root移動を除いたため、FBXの移動とゲーム側の速度が二重に加算されない。体の上下動・前転はPoseに保持する。前後反転を防ぐanatomical v2のImportゲートを通した。

## 検証

Play Solo・実際のW＋左Shift／2入力で、走行速度24、StandardRunのループ、Rollへの切替、Roll終了後の走行復帰、Shift解除後の速度20への復帰と停止を確認。Roll Trackは1.611111倍・非ループ、Sprint Trackは1.05倍・Movement優先度。Server AnimatorにもClient開始のSprint Trackが複製されることを確認した。Stun属性設定中のShift入力では新Trackが再生されない。

実R15をYaw0°と90°にして検査した前方投影はRoll 0.91958、Run 0.33228で同値。Roll中盤の体の上方向は−0.61401で前転を確認した。全フレームのBake検証と、保存後再読込のPose完全一致もPass。[Studio記録](../../work/animations/motions/movement-studio-qa-20261018.json)、[再読込記録](../../work/animations/motions/movement-reopen-qa-20261018.json)。複数Clientの相互観察・人間の見た目／接地レビューは未実施。Outputは既存のFoundationProvider警告のみで、新規ゲームエラーはなかった。

## 公開の残件

StudioのWorkspaceには `W05_Roll_R15_Preview` と `W05_Run_R15_Preview` を配置し、各AnimSavesは同名の `ServerStorage.RBX_ANIMSAVES` フォルダを参照する。Animation Editorでそれぞれ `SprintingForwardRoll_R15_v001`／`StandardRun_R15_v001` を開き、プレース所有者と整合する所有者でPublishする。発行IDの方向と長さを検査したうえでConfigのRoll.AnimationId／Sprint.AnimationIdへ設定する。

現在のConfigはID空欄。Studio内では新クリップを再生し、オンラインでは既存 `ReplicatedStorage.MovementAnimations` を維持して一度だけ警告する。新assetのオンライン適用完了とは扱わない。UIツールは `Sky Computer Use native pipe startup failed` によりPublish画面へ接続できなかった。Studio MCPとゲーム処理の接続は正常。ゲーム本体の保存／公開は行っていない。

制作物と原本は [Roll作業記録](../../work/animations/motions/sprinting-forward-roll/README.md)／[Run作業記録](../../work/animations/motions/standard-run/README.md)を参照。

## ローリング単独で約20スタッド移動（2026-10-18追記）

**Status: Prototype: Implemented（Studio反映・Play Solo確認済み）**。ユーザー指定により、スロット2を押すだけで平坦・障害物なしの場合に約20スタッド移動する。方向は発動時の移動方向、移動入力がなければキャラクターの向き。発動後の方向は固定する。

従来の一度だけ速度を与える処理はHumanoidの制御ですぐ減速するため、`RollMovement`で水平面のLinearVelocityを0.6秒間維持する。速度は20÷0.6≒33.333スタッド/秒。上下は拘束せず、従来の上向き速度12と重力を保持する。残り距離で最終ステップを制限し、終了時は水平速度を落として滑走を防ぐ。

Serverの既存Cooldown・生存・Stun・リザルト検査を通過した`RollAccepted`通知でClient移動を開始する。Serverが拒否した入力では移動しない。移動自体は従来どおりClient所有のキャラクター物理を利用し、Serverによる移動距離の不正検出を追加したものではない。`RollConfig`にDistance20・Duration0.6・初速・壁との余白を分離し、Server無敵時間も同Durationを参照する。

各物理ステップで衝突可能な壁をBlockcastし、壁の手前で終了する。死亡・Character変更・Stun・リザルトでも拘束と接続を破棄する。傾斜・段差・障害物がある場合の20スタッドは保証しない。

実キー入力の2だけ（MoveDirection=0）で19.9712スタッド、10スタッド先に厚さ2の壁を置いた場合は7.1634スタッドで停止。Stun中断では約5.5537スタッドで拘束解除を確認。無敵終了と移動用Instanceの掃除を確認し、新規ゲームエラーなし。[検証記録](../../work/animations/motions/roll-distance-qa-20261018.json)。ゲーム本体の保存・公開は未実施。

変更: `Shared/Config/RollConfig.luau`、Clientの`RollMovement.luau`／`SkillController.client.luau`、Serverの`SkillService.server.luau`。
