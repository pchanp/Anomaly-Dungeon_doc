# 2026-10-14 制作環境の棚卸し

**Status: Implemented（ローカル資料の棚卸し）／稼働環境・共有状態はUnconfirmed（未確認）**

## 確認範囲と基準版

BASE-01としてルート規約・README、Workboard、既存制作工程、判断002・023・024、W01・材質・アニメーション・UI試作の資料を確認した。ファイルの存在と文書の記録を確認し、GPU・Blender・Studio・ギャラリーの現在の稼働／見た目を再検証したものではない。外部サービスの仕様はこの棚卸しで再調査していない。

調査開始時のHEAD: `788a3bc2c4eddac833365f17a71cba882bd86c7d`。作業ツリーに既存の変更・未追跡資産があり、このコミット単独はローカル環境の完全な再現点ではない。以下は今回の入口リンク・Workboard更新前に取得した入力ハッシュ。全文をGitへ追加したという意味ではない。

| 入力パス | SHA256 | 共有上の注意 |
| --- | --- | --- |
| `AGENTS.md` | `d75edd62c3959ecea2cad4b66cc11f9b1347cf04df21acf41543e8ee7aa66153` | Git追跡あり（未コミット差分は別） |
| `README.md` | `c5980a96fdbc3ab7743e1af6216f615e148e970f3d01047a4307e460dabe1041` | Git追跡あり（未コミット差分は別） |
| `docs/workboard.md` | `feb98b69a6b8a2d884d33e030f65a207458e4e064a2f26b18900a004bf343d42` | Git追跡あり（未コミット差分は別） |
| `docs/production/minimum-run-development-roadmap.md` | `6dbe117992992fa72a19a2362096803be67b04dde2af1a0126ced8f8d4459a5d` | Git追跡あり（未コミット差分は別） |
| `docs/production/asset-pipeline.md` | `730861b5eefabd6a53867328bba9f17bbaaa658705ef3ca5d85da6c9edb114c1` | Git追跡あり（未コミット差分は別） |
| `docs/production/animation-pipeline.md` | `942e98a5bb56c2684c25c7b0af82a325364f8bb21ae5fc729ef919998a62dd0c` | Git追跡あり（未コミット差分は別） |
| `docs/decisions/002-animation-retarget-tool.md` | `26e6946f73077fe5e897badbc10dab6f1824af5d3b36f90d27a3310a394cfd1b` | Git追跡あり（未コミット差分は別） |
| `docs/decisions/023-animation-source-priority.md` | `b88b452bee14df1f9372641c6bf11fd32ea24feed95b5107777475adc58f0188` | 未追跡・ローカル入力 |
| `docs/decisions/024-editable-august-map-authoring.md` | `de392503f1ccb119ea4b67321504a8e66af2ae68a793a33ff2e2cbe77164eab3` | 未追跡・ローカル入力 |
| `docs/references/material-preview.md` | `bc1e72aee230b34f1e658c9e4f03a1607c976d05d99200c8df0934598103a405` | 未追跡・ローカル入力 |
| `docs/references/august31-asset-candidates.md` | `20aad784a63c8f54f7ad3618bc596ab9d94872dfc9f31ce20f1f0fecb3a3c261` | 未追跡・ローカル入力 |
| `docs/references/retarget.md` | `a483c61af2ebf29345db54de625e3f4d74e370bdd2d38320f9f36fe33ad9159f` | Git追跡あり（未コミット差分は別） |
| `work/icon-generation/AGENTS.md` | `673b68c36bab6bd346e310ce51c7f910e39eb1b4956795205f5596be00b13c8b` | 未追跡・ローカル入力 |
| `work/icon-generation/shade-20261014-fox20/README.md` | `f1adc33a2a9d2a7a402b04b0abdcf3b7cb01d318e466e7a4688d25f3989a8c83` | 未追跡・ローカル入力 |
| `work/animations/motions/hook-punch-sample/README.md` | `8fb2c7198ac53bf6461f170f44ecd2e7508c4284bc6ffab5cf5145f5cc863d00` | 未追跡・ローカル入力 |
| `work/animations/scripts/README.md` | `5dd4536614fe683b03d8da131d6b7e397ff583669fa865998452d822677cfe2e` | 未追跡・ローカル入力 |
| `tools/ui-layout-editor/README.md` | `6499baded1bc03247c04bafb6d18a1490ac91cf5235f289b8c8aee99ae5a06a4` | Git追跡あり（未コミット差分は別） |

## 部屋別の到達点

| 部屋 | 記録から確認したこと | 未確認・次の境界 |
| --- | --- | --- |
| W01 | 5枚・20枚試作、条件照合、キュー・レビューPrototypeの記録あり | 正式意匠・本番表示サイズ・実機携帯確認。参照衣装・背景混入は残件 |
| W02 | 独立した作業場は未整備 | 対象・用途・3D生成手段・修正工数 |
| W03 | 80三角形・2素材のBlender比較、EditableMeshでEdit配置、Ray確認の記録あり | 通常FBX Import・視覚・歩行・Play・保存再読込。Codex専用制作・編集 |
| W04 | キャラクターパイプラインはDraft、Tripo等は選択肢 | 初回対象、形状・Rig・変形・Roblox互換性 |
| W05 | R15作業場、骨格Retargetスクリプトの実行記録あり | Mesh・接地・出力・Studio再生。独自Rigは別工程 |
| W06 | YAMLとWeb編集を分離したLayout Editor Prototype | 対象UIの状態検証、Roblox生成／実装対応 |

実作業の入口は [部屋対応表](README.md) を参照する。既存アセットを移動・大量複製しない。

## 更新差・未解決事項

1. Workboardの概要は10月8日まで。10月13〜14日の制作記録を概要とワークショップ入口へ追記するが、旧ゲーム検証を再実施済みにしない。
2. Hook Punchの個別READMEはRetarget未実施、スクリプトREADME／retarget参照は骨格実行済み。同じ入力・作業ファイルか未照合。次回はファイル版・Action・証拠を照合し、実行していない工程は未確認のまま残す。
3. 岩アセット候補一覧のStudio未確認と、material-previewのEdit配置記録は検証範囲が異なる。FBX導入成功へ読み替えず、次回はEdit配置・通常Import・Play・視覚を分ける。
4. Workboardの編集テンプレート判断待ちと、判断024の8/31 Prototype移行記録にも更新差がある。ワークショップ整備では全体の移行判断を完了扱いにしない。GitとStudioの差異・未検証は判断024を参照する。
5. 既存W01の明示されたレーン並走と、最小Runの単一実行基準は範囲が異なる。既存W01運用を維持し、部屋数を増やすだけで新規並列実行を許可しない。
6. FBX・blend・動画、画像等の除外・バックアップ・別端末配布は一律でない。記録だけ共有しても素材が取得できるとは限らない。採用素材の保管先は人間判断が必要。

これらは調査結果であり、原因や最新実構造を推測で確定していない。既存の未コミット変更は保全し、今回の文書と混ぜて一括コミットしない。

## 完了条件と残件

BASE-01の資料棚卸し・部屋対応・更新差の記録は完了。環境疎通、バイナリの入力固定、共有方法の決定、旧記録の個別照合は次タスクへ残る。BASE-02の成果は [初期整備記録](runs/BASE-20261014/RESULT.md)。


## 2026-10-15：更新差への対応

上記は棚卸し時点の記録として保持。マップ方式・Secure Slot・アニメーションの記述差は[資料整合の記録](runs/DOCS-20261015/RESULT.md)に従って整理した。アニメーション出力の保存・元FBX出典、バイナリ保管・共有は未確認のまま。P0は[ユーザー確認](../studio-verification-checklist.md#2026-10-15ユーザーによるp0確認完了の報告)で完了。
