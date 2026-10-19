# Shade：50スタッド高速移動と経路判定の試作

**Status: Prototype: Implemented（2026-10-18、Studio Edit反映・Play Solo検証済み）**

ユーザー指定は、スロット3のShade発動時に約50スタッドを高速移動し、当たり判定をワイヤーフレームで見えるようにすること。確認により0.3秒の移動と暫定25ダメージ＋0.5秒Stunで試作した。正式バランス・恒久System ID・取得／強化の確定ではない。

## 挙動と設定

`Shared/Config/ShadeConfig.luau`を正本とする。

| 項目 | 暫定設定 |
| --- | --- |
| 発動 | スロット3／キー3、Server既存検査の通過後 |
| 距離・時間 | 50スタッド／0.3秒（約166.667スタッド/秒） |
| 方向 | 発動時のキャラクター正面の水平直線。途中の方向変更なし |
| 経路判定 | 幅5・高さ5・奥行3の箱を、各物理ステップの通過区間まで伸長 |
| 命中 | 経路上の複数Humanoidへ各1回、25ダメージ＋0.5秒Stun |
| アニメーション | Shade_R15_v002、3.5倍、約0.452秒、非ループ |
| 既存効果 | ステルス5秒・移動速度30・Cooldown10秒を維持 |
| デバッグ | Studio限定で既定ON、終了後0.4秒で消去 |

## 移動と命中の実装

`Services/ShadeService.luau`をSkillServiceのスロット3から呼び出す。0.3秒だけRootをAnchoredにしてServerがステップごとに位置を進める。移動中は高さを固定し、重力方向の軌道や地形追従は行わない。壁にはキャラクターRoot寸法のBlockcastを行い、0.15スタッドの余白を残して停止する。キャラクターは壁扱いから除外して通過する。64体を超えて壁の判別を続ける必要がある場合は安全側で停止する。

各ステップで前位置と次位置の間を覆うBoxをGetPartBoundsInBoxで検索する。高速移動中の飛び越しを防ぎ、Humanoid単位の記録で複数部位や複数ステップの重複Hitを排除する。最近傍経路点から対象RootへのRaycastで壁遮蔽も検査する。CombatDamage経由で無敵・Parry・通常PvPのHP80%下限を適用し、実ダメージが入った相手へStunを与える。

移動中はShadeDashing属性で追加スキルとShift瞬間加速を受け付けない。Roll無敵中のShade開始も拒否する。死亡・Character変更・Stun・リザルト・InDungeon／RoomIdの変化では中断し、Rootの固定・回転制御を戻す。終了時は水平慣性を残さず、物理のNetworkOwnershipを自動へ戻す。元からRootがAnchoredの場合は移動開始しない。ステルスの既存効果とダッシュの0.3秒は別管理である。

## フレーム表示

`Workspace.ShadeDebug.ShadeHitbox`は透明Part＋SelectionBox。橙色は直近区間の実判定、命中後は緑色になる。CFrameとSizeは当該サーバー検索と同一。紫色の`ShadePath`は通過済み区間全体の範囲を示す。PartはいずれもCanCollide／CanTouch／CanQuery=falseで、表示自体は判定へ干渉しない。Server生成なのでClientから見える。

Workspace属性`ShadeDebugHitboxes=false`でOFF、nilでConfigに従う。公開ゲームで表示する場合はConfig.DebugStudioOnlyを明示的にfalseへ変更する。表示をOFFにしても命中処理は継続する。通常終了／壁停止は0.4秒後に消去し、中断時は即消去する。

## 検証

実キー3だけで水平50スタッド、観測約0.295秒（最初の観測サンプル後から終了まで）で完走し、RootのAnchored解除を確認。経路の12／40スタッド位置の2体はHP100→75、Stun発生と解除。余分な部位を持つ対象にも25だけ入り、横10スタッド・距離60スタッドの対象はHP100を維持した。

25スタッド先の厚さ2の壁では23.35スタッドで停止し、手前の対象だけに命中、壁奥はHP100。デバッグOFFでも50スタッド移動とダメージを確認。Stun中断は13.889スタッドで停止し、固定解除とデバッグPart即消去を確認した。Client側で両SelectionBox・非衝突設定・3.5倍再生を確認し、表示枠と実QueryのCFrame一致、通常終了後の掃除、新規ゲームエラーなしを確認した。[QA記録](../../work/animations/motions/shade/studio/dash-hitbox-qa-20261018.json)。

複数Client間の相互観察、段差・傾斜・高所での実歩行、高遅延・低FPS、正式PvP調整は未検証。公開アニメーションIDは未発行。ゲーム本体の保存／公開は行っていない。

[リターゲットと入力版](../../work/animations/motions/shade/README.md)、[移動アニメーション接続](movement-animation-integration.md)。
