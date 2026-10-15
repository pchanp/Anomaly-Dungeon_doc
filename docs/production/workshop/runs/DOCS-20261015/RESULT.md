# 2026-10-15：資料の更新差の解消

**Status: Implemented（記述の照合・更新）／未確認の実データは下記に分離**

## 目的・根拠

ユーザーの「資料の更新差を解消する」に基づく文書更新。設計の新規採用、実装・生成・Studio変更・Blender実行・コミットは行っていない。既存の未コミット変更を保持し、原本・旧検証ログを削除していない。

## 更新した範囲

| 領域 | 更新先 | 根拠・結論 |
| --- | --- | --- |
| マップ方式 | [ETR](../../../../systems/editor-templates-and-runtime-maps.md)、[実装棚卸し](../../../../systems/current-implementation.md) | 判断024と編集手順に合わせ、8/31の実方式と旧全体案を分離。ETR-01〜08を対応付けた |
| Secure Slot | [優先順位](../../../../systems/implementation-priorities.md)、実装棚卸し | 判断010の研究室・レアルート品によるSecure Conversion／Capacity Expansionへ統一。実装と数値の未確定を区別 |
| Hook Punch | [個別記録](../../../../../work/animations/motions/hook-punch-sample/README.md)、スクリプトREADME、retarget参照 | 保存検査のSource Actionあり／Target Actionなしと、後続の骨格試行記録を分離。現在blendへの保存は未確認 |
| 現在の入口 | ワークショップREADME、岩アセット候補、Workboard | W01評価完了と次3構図、岩のEdit配置と通常Importの差、P0の人間確認を反映 |
| 履歴 | 10月14日の棚卸し | 過去の観測と入力ハッシュは維持し、本記録への追記のみ |

## Hook Punchの照合証拠

検査JSONは `blender/rig-inspection-20261013-075800-776233.json`。記録されたファイルは `hook-punch-retarget-v001.blend`、Blenderは5.2.1 LTS。Armatureは17 Bone・Actionなし、Armature.001は65 Bone・mixamo.com・1〜65フレーム。現在blendは再読込しておらず、JSONには検査時blendのハッシュがない。したがって保存後の状態や、元FBXの取得元は断定しない。

以下は今回照合時のローカルファイル識別値。過去時点の内容保証ではない。

| パス | SHA256 |
| --- | --- |
| `work/animations/motions/hook-punch-sample/source/Hook Punch.fbx` | `636b6f2d3003ba5c8314cdc14f6ce523933cecb98956cd36bc6eb003c45235ea` |
| `work/animations/motions/hook-punch-sample/blender/hook-punch-retarget-v001.blend` | `1e431a35327c658ccfd7bd07f463a6ebf9ba92ec00b8f14d8f484c97e2a5d3f3` |
| `work/animations/motions/hook-punch-sample/blender/rig-inspection-20261013-075800-776233.json` | `f36e1478620ce49e1fcf47a3ea6a3f7887a3e6e7d341166dce10f3c8f39e3b6c` |

## 未確認として残すもの

- 現在のblendに出力Rig・Actionが保存されているか、FBXの取得元、見た目・接地・出力・Roblox互換性。
- 全マップ・ロビーへの編集原本方式の展開、将来の汎用座標・Binder、新アセットによる再制作の具体的範囲。
- バイナリの保管・別端末共有・未コミット成果の共有範囲。文書修正だけで共有済みにしない。
- P0はユーザー確認でDoneを維持する。追加の項目別測定値や新しいコードの実装を推定しない。

## 検証

11文書の相対リンクに欠落なし、`git diff --check`成功。Secure Slotの旧表現を文書検索し、元FBX・blend・検査JSONのSHA256不変を確認した。実コードの変更はなく、ゲーム・制作ツールの動作テストは対象外。新しい判断記録は追加していない（判断010・024の整合反映であり、採用内容を変えていない）。
