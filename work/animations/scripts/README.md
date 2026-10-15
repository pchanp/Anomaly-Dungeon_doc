# Mixamo → 標準R15 リターゲット

**Status: Draft（草案）**

`retarget_mixamo_r15.py`はRokoko等の追加プラグインを使用しない、骨格プレビュー用の共通スクリプト。Blender 5.2.1でHook Punchの1〜65フレームの実行を確認。見た目、接地、FBX出力、Roblox互換性は未検証。

## Blenderで実行

1. 作業.blendを保存し、Object Modeにする。
2. SourceのMixamo Armatureと、Action・制約を持たない標準R15 Targetを用意する。
3. スクリプト先頭の`SOURCE`、`TARGET`、`OUTPUT_NAME`を確認する。初期値はHook Punchサンプル用。
4. Python Console（Shift+F4）で次を実行する。

```python
exec(compile(open('/Users/saitouyouwataru/Documents/Git/Anomaly-Dungeon_doc/work/animations/scripts/retarget_mixamo_r15.py').read(), 'retarget_mixamo_r15.py', 'exec'))
```

5. Shift+F5で3Dビューへ戻り、新しい`R15_HookPunch_Retarget`を選択して再生する。SourceをOutlinerの目アイコンで一時的に隠すと比較しやすい。
6. 結果を確認後、別名.blendへ保存する。自動保存・FBX出力はしない。

## 設定

- `FRAME_RANGE = None`: Source Actionの範囲を自動取得。必要なら`(1, 65)`等を指定。
- `ROOT_MODE = 'IN_PLACE'`: ワールドZ方向の腰の上下動を残し、水平移動を除く。移動をゲームコードで管理する場合の初期設定。
- `ROOT_MODE = 'KEEP'`: Rest Pose基準で腰のXYZ移動を残す。キャラクターのゲーム上の移動処理を実装するものではない。
- `ROOT_MODE = 'NONE'`: 腰の位置変化を転送しない。
- `TRANSLATION_SCALE = None`: 脚長の比から移動量倍率を推定。必要なら数値を指定する。

## 処理と制限

- SourceのRest Poseからのワールド回転差分をTargetのRest Poseへ適用し、親子関係に合わせてローカル回転へ変換する。
- UpperTorsoはSpine2、HeadはHeadの階層込みの回転を使う。肩や首の中間ボーンによる回転を含むが、位置変化・関節位置は再現しない。
- 指・つま先の追加ボーンは転送しない。RootとHumanoidRootNodeは固定する。
- Targetの骨格を複製して、新しいActionへ毎フレームのQuaternion回転と腰位置を記録する。ノイズ除去やキー削減は行わない。
- 元のSource、Target、Actionを変更しない。再実行すると別の複製を作る。シーンの再生範囲は出力範囲に合わせる。
- Mesh・Attachmentは複製しない。骨格のみを比較する段階。
- IK・接地固定は行わない。A/Tポーズの差や体格差による腕の開き、足滑り、接触位置の違いは目視で検証する。
- オブジェクト自体の移動・回転アニメーション、特殊な親子関係・非一様スケールは検証対象外。通常のMixamo骨格と公式R15テンプレートを前提にする。

標準工程は[制作パイプライン](../../../docs/production/animation-pipeline.md)、ツールの位置付けは[リターゲット参照](../../../docs/references/retarget.md)を参照。


## 保存結果との対応（2026-10-15）

上記は骨格試作の実行記録。現在のblendへの出力保存は未確認であり、保存済み検査JSONではTargetにActionがない時点が記録されている。Source Import・試行実行・保存結果を区別する。詳細は[Hook Punchの個別記録](../motions/hook-punch-sample/README.md)を参照。
