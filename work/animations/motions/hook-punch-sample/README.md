# Hook Punch リターゲット検証

**Status: Draft（保存済み検査とスクリプト実行記録を分離。導入未検証）**
**更新日: 2026-10-15（資料照合のみ）**

- 元FBX: `source/Hook Punch.fbx`。配布元は未確認。ファイル名・Action名だけでMixamoからの取得を確定しない。
- 対象Rig: Roblox公式R15 Rig and Attachments。
- 作業ファイル: `blender/hook-punch-retarget-v001.blend`。今回Blenderで再読込・再実行していない。

## 保存済み検査が示す範囲

[2026-10-13の検査JSON](blender/rig-inspection-20261013-075800-776233.json)は上記blendのパスを記録している。検査時のBlenderは5.2.1 LTS。

| Armature | Bone数 | Action | 範囲 |
| --- | --- | --- | --- |
| Armature（Target側） | 17 | なし | なし |
| Armature.001（Source側） | 65 | mixamo.com | 1〜65フレーム |

したがって、旧READMEの「Source Import未実施」という一括表記を訂正する。検査時点でSource Armature・Actionは存在する一方、Target Actionはない。JSONに検査時のblendハッシュは含まれないため、この結果を現在のblendの内容保証にはしない。

## 後続の骨格試作との区別

[スクリプトREADME](../../scripts/README.md)と[参照資料](../../../../docs/references/retarget.md)に、Hook Punchの1〜65フレームを骨格へ転送した実行・数値確認の記録がある。スクリプトはTarget複製とActionを作るが、自動保存・FBX出力はしない。実行成功の記録と、結果がこのblendへ保存済みであることは別。

- 骨格スクリプトの実行記録：あり（今回は再実行していない）。
- その出力が現在のblendへ保存済みか：Unconfirmed（未確認）。
- Mesh・接地・見た目、FBX出力、Roblox再生：Unconfirmed（未確認）。
- 次回：元FBXの出典と、blend内の出力Rig・Action・保存版を確認する。新たなRetargetや上書き保存より先に確認する。

照合時のファイルSHA256は[資料整合の記録](../../../../docs/production/workshop/runs/DOCS-20261015/RESULT.md)に残す。現在ファイルの識別であり、10月13日時点の保存内容を証明するものではない。

## 2026-10-17：再試行・固定処理・Studio導入

v001を開いた実データでTarget Actionなしを確認。v002へ15ボーン・1〜65FをBakeし保存再読込を確認。その処理を[固定スクリプト](../../scripts/README.md)へ整理し、Blenderの別プロセスでv003、腰移動倍率を脚長比で算出するv004を作成した。

現在版: `blender/hook-punch-retarget-v004.blend`、`export/hook-punch-r15-v004.fbx`、`export/hook-punch-r15-poses-v004.json`。v004は65F・63カーブ・4,095キー、方向／姿勢の測定角差0度、骨長差約1.58e-6。保存版の再読込からPose JSONを生成した。

FBXのStudio Importに成功したがルート・軸の変換が必要だったため、保存済みPose導入アダプタを適用。Studio実行用は `ReplicatedStorage.AnomalyDungeon.Animations.HookPunch_R15_v004`。纏絲勁の試作に割り当て、実R15のAnimator/AnimationTrackによるソロ再生と部位変化を確認。

[Studio検証記録](studio/RESULT-20261017.md)。正式美術採用、元FBXの取得出典、公開Animation ID・複数Client検証は未完了。以前の「保存未確認」は当時の記録として保持する。

## 公開IDの反映（ユーザー登録完了後）

ユーザー提供ID `95405144949752` をローカルsrcとStudio EditのTensikeiConfigへ反映。Play再起動後、纏絲勁から `rbxassetid://95405144949752` のAction TrackがLength約2.133秒・IsPlaying=trueで再生することを確認した。以前の公開ID未取得・一時IDのみという記録は初回時点の状態。公開ゲーム・複数Client検証とゲーム本体の公開は未実施。

## 前後逆の原因確定と修正v005

旧公開ID95405144949752は前後逆と判明。上方向だけの変換を、解剖学的前−Z／右+X／上+Yの明示基底へ修正。元blendはv004を保持し、修正版Poseはexport/hook-punch-r15-poses-v005.json、StudioはHookPunch_R15_v005を使用する。旧形式はImporterが拒否し、旧公開IDはlegacy profileで採用を停止。[原因・再現・測定結果](studio/ORIENTATION-FIX-20261017.md)。修正版の公開は未実施。

## 2026-10-18：Roblox側の再生速度・判定可視化

元Bake／Poseのフレーム内容を維持し、纏絲勁の再生側を前半3倍・後半2倍へ変更。主判定開始約0.167秒、全体約0.889秒。前方Boxの実判定と一致するワイヤーフレームをStudioに追加。[実装仕様](../../../../docs/systems/tensikei-prototype.md#2026-10-18高速化当たり判定のワイヤーフレーム)、[検証JSON](studio/fast-hitbox-qa-20261018.json)。修正版assetの公開ID更新は別残件。
