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
