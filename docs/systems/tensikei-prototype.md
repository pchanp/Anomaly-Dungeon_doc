# 纏絲勁 試作実装

**Status: Implemented（Studioソロ試作。正式バランス・取得／装備システムは未確定。方向修正v005はStudio検証済み。修正版の公開IDは未反映）**
**実施日: 2026-10-17／更新: 2026-10-18（高速化・判定可視化）**

## 許可・参照

ユーザーがスロット4・暫定数値を設定へ分離する試作を承認。[通常スキルの設計](skill-build.md)の「小威力Parry、中ダメージ、0.5秒Stun、遅延小ダメージ」を実装する。表示名は纏絲勁。ファイル名・属性・試作データ名は恒久System IDの採用ではない。

## 試作の値と挙動

正本は `src/ReplicatedStorage/AnomalyDungeon/Shared/Config/TensikeiConfig.luau`。

| 項目 | 試作値 |
| --- | --- |
| 入力 | スロット4、キー4 |
| クールタイム | 4秒 |
| 主ダメージ／追加 | 25／8 |
| Stun | 0.5秒（設計値） |
| 追加ダメージの遅延 | 主Hitから0.4秒 |
| 主Hit開始／判定期間 | 約0.1667秒後／約0.04秒（元クリップ0.5〜0.62秒を再生時計へ変換） |
| Hitbox | 前方3スタッド、幅4・高さ5・奥行5 |
| Parry | 発動から約0.1833秒（元クリップ0.55秒）、前方半球、直接攻撃10ダメージ以下 |
| Animation | 元クリップ30fps・1〜65F。前半3倍・後半2倍、実動作約0.8889秒（フェード除く）、Action優先度・非Loop |

効果値は最終採用ではない。Hitは前方Box内で視線の通る最寄りHumanoidを1回だけ選ぶ。遅延Hitでは範囲を再検索せず、同じ対象へ追加する。回復、効果対象の恒久解放、取得・レベル強化は実装しない。

## ServerとClient

- Server: 入力型・スロット・生存・リザルト・Stun・Cooldownを検査。対象、Hit、Parry、Stun、遅延作用を確定。クライアントから対象やダメージを受け取らない。
- Client: 既存HUDの空き4枠目へ表示し、サーバーの受理結果でCooldownを反映。Stun中は同コントローラのスキル／Dash入力を拒否。
- 通常プレイヤー同士の各Hitは最大HPの80%下限を適用し、いずれかがPlayerAnomalyState=TRANSFORMEDなら下限なし。今回の実装経路はCombatDamageを呼ぶ纏絲勁と既存Magic Boltに限る。
- ParryはCombatDamageへの直接攻撃だけを判定する。任意ScriptのHealth書換えや全Anomaly攻撃を包括的に横取りしない。遅延衝撃はParryしない。
- 同じStunの再適用は残り秒数を更新。移動・Jump値を一時抑止し、途中で他処理が変更した値は解除時に保持する。異なる種類のEffectを万能に統合するものではない。
- 死亡、対象喪失、リザルト、キャラクター変更、InDungeon／Room変更で当該作用を中断。Stunは対象Run境界で解除。恒久的なビルド保存はしない。

## Animationと導入物

固定制作手順は[W05](../../work/animations/scripts/README.md)。Source・旧版を保持し、現在の生成物は `hook-punch-retarget-v004.blend`、FBX、Pose JSON。

- Studio接続先: 異変のダンジョン、placeId `99417611378273`。
- 元FBX ImportはServerStorage.HookPunch_R15_v003として保持。Importerが余分なルート・骨軸を保持したため、そのまま実行しない。
- 実行用: `ReplicatedStorage.AnomalyDungeon.Animations.HookPunch_R15_v005`（65 Keyframe）。Rest回転とダミールートを除去した標準R15 part-space Pose。
- `ServerStorage.W05ImportR15PoseSamples`に保存済み導入ヘルパー。ソースはW05の `import_r15_pose_samples.luau`。
- 検証リグ: `Workspace.W05_HookPunch_R15_Preview`。AnimationConstraintを持つ標準R15。AnimSaves参照を配置。
- 変更前SkillService／SkillControllerは `ServerStorage.W05_Tensikei_Before_20261017`に保持。

公開ID `95405144949752` は前後逆のv1データと判明。IDを履歴として保持するが `AnimationIdOrientation=legacy-v1` で採用を拒否する。現在Studioでは方向検証済み `HookPunch_R15_v005`（anatomical v2）から一時IDで再生。Studio外では方向未検証IDを拒否する。修正版の再公開と公開assetの方向検証が必要。ゲーム本体の公開は行っていない。

## 検証結果

Play Solo・Client1人。実ClientからSkillEventの4を送信し、Serverで測定。

- HUD4枠目「纏絲勁」、Main後HP75、遅延後HP67、Stun中WalkSpeed0、解除後16。
- 再発動Cooldown拒否、不正文字列・範囲外・NaNスロットにScript Errorなし。
- 5ダメージの前方直接攻撃はParry、11は通過。
- Stun中に別処理でWalkSpeedを24へ変更したケースで解除後24を保持。
- 壁越し対象はHitなし。リザルト移行前に発動した攻撃は中断・Parry／Cast属性解除。
- 実R15でAction優先度のAnimationTrack、Length約2.133秒を確認。複数時点で左右の手のCFrame変化を測定。
- 全体のゲームScript Errorは観測なし。Roblox組込みUIのFoundationProvider警告は従前から存在。

証拠: [W05実施結果](../../work/animations/motions/hook-punch-sample/studio/RESULT-20261017.md)。PvP下限の実2Client検証、公開後の所有権・複製、接地・接触・技の見た目の最終レビューは未実施。

## 残件

初回は公開画面の操作を完了できなかったが、その後ユーザーが公開を完了しID `95405144949752` を提供。ローカルsrcとStudio Edit設定へ反映し、Playを再起動して実R15のAction AnimationTrack（Length約2.133秒・IsPlaying=true）を確認した。見た目・複数Client・公開ゲームでの動作検証は残る。

## 前後逆の修正

[原因と回帰検査](../../work/animations/motions/hook-punch-sample/studio/ORIENTATION-FIX-20261017.md)。旧版ではHook Punch開始姿勢の両手が後ろ、v005では前となることを実R15で測定した。取得／再生成功の従来検査だけでなく、Sourceの意味に対する方向検査を必須にする。従来の公開ID再生確認は読み込み確認の履歴であり、方向合格ではない。

## 2026-10-18：高速化・当たり判定のワイヤーフレーム

ユーザー指定「全体2倍速、前半をさらに1.5倍速」を、元クリップの前半0〜50%は3倍、後半50〜100%は2倍として実装。BlenderのBakeや公開assetを編集せず、RobloxのAnimationTrack再生側で速度を変更する。

- `TensikeiTimeline`が元クリップ秒と実時間を相互変換する。前半終了は実時間約0.3556秒、全体約0.8889秒。切替時はTimePositionも補正し、Heartbeat遅延で前半が延び続けない。
- `Windup`・`HitWindow`・`ParryDuration`は元クリップ秒で保存し、同じ時計で判定タイミングへ変換する。主判定は実時間約0.1667〜0.2067秒、Parryは約0.1833秒まで。
- ダメージ25＋追加8、追加遅延0.4秒、Stun0.5秒、Cooldown4秒は実時間の効果として維持する。遅延ダメージはアニメーション終了時の掃除だけでは失効させず、死亡・Run境界・中断で停止する。
- 毎Heartbeatでサーバーが現在の前方Boxを検査。低FPSで短い判定区間をまたいだ場合も、その区間の交差に対して1回は検査する。同一発動は最寄り1対象に1回の主Hit。対象の複数部位で重複Hitしない。
- 判定BoxのCFrameとSizeをそのままDebug Partにも用いる。Debug Partは透明・固定・非衝突・非接触・CanQuery=false。表示用Partが命中候補や遮蔽物にならない。

### Debug表示

StudioのPlayでキー4を押すと `Workspace.TensikeiDebug.TensikeiHitbox` が発動ごとに生成される。Part本体はTransparency=1、SelectionBoxのSurfaceTransparency=1・LineThickness=0.035で線だけを表示。前方3stud、幅4・高さ5・奥行5のBox。

- 青: 準備
- 橙: 実判定中
- 緑: 接触を解決したフレーム（Parry・無敵を含む。実Damage結果はCharacter属性参照）
- 灰: 後隙／判定終了

終了後0.2秒で表示を破棄。中断時は即座に破棄。ConfigのDebugHitboxEnabled=true、DebugHitboxStudioOnly=trueが既定。Studioで `workspace:SetAttribute('TensikeiDebugHitboxes', false)` にすると次の発動から非表示。nilでConfig既定へ戻す。実判定は表示のON/OFFに依存しない。

### 検証

65個の元フレームについて時刻の往復変換を検査。Play Soloで速度3→2、最初の命中が発動から約0.1836秒、HP100→75→67、Stun解除を確認。範囲外／背後／横／壁越しはHP100のまま。範囲内に2体いても近い1体だけが67、遠い方は100。Client側にもSelectionBoxと透明Partが複製され、実判定と同じSize/CFrameであることを確認。

リザルト中断で無Damage・表示消去、表示OFFでもDamage有効、終了後のCast属性・表示消去を確認。ゲームScript Errorは観測なし（Roblox組込みUIの既存FoundationProvider警告あり）。証拠は[高速化QA](../../work/animations/motions/hook-punch-sample/studio/fast-hitbox-qa-20261018.json)。テスト後はPlayを停止してEditに戻した。
