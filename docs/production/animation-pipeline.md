# アニメーション制作パイプライン

**Status: Draft（草案）**

## 目的

通常のモーションはMixamoの既存モーションを元に適宜編集し、Robloxで利用可能なAnimationとして導入します。DeepMotionから取得してBlenderで調整する工程は、既存モーションでは表現しにくい特殊なモーションに限定します。

## Current Standard

- 通常のモーション: Mixamoの既存モーションを選び、必要な区間・姿勢を適宜編集する。
- 特殊なモーション: DeepMotion等でSource Motionを取得し、Blenderで調整する。
- Mixamoでも対象Rigへのリターゲットが必要になる場合がある。編集工数の削減と、Rig互換性の確認は分けて扱う。対象Blenderバージョン・Roblox Rigでの互換性は個別検証する。
- 採用方針は[判断記録023](../decisions/023-animation-source-priority.md)、ツール固有情報は[Mixamo参照](../references/mixamo.md)を参照する。

共通の導入工程:

```text
Mixamoの既存モーションを取得（特殊なモーションはDeepMotion等）
  -> Animation FBX
  -> BlenderへImport
  -> Source / Target Armatureを確認
  -> Bone Mappingを設定
  -> Target ArmatureへRetarget
  -> 必要な区間・姿勢を編集（特殊なモーションはノイズ補正も検討）
  -> AnimationをBake
  -> Roblox向けAnimation FBXをExport
  -> Roblox StudioのAnimation EditorへImport
  -> Publish
  -> 実ゲーム相当のRigで検証
```

リターゲット工程は特定の外部プラグインを必須としません。採用ツールは対象Blenderバージョンで検証し、操作方法は [`../references/retarget.md`](../references/retarget.md) に記録します。

## Blenderでの確認

- Source ArmatureとTarget Armatureを取り違えていない。
- Rest Pose、Scale、Rotation、Bone Mappingが適切である。
- Target側のActionへ必要なKeyframeがBakeされている。
- Source Armatureを非表示または削除してもTarget側だけで再生できる。
- ExportするActionとフレーム範囲が意図どおりである。

## Robloxでの検証

- 対象SkeletonへImportできる。
- Animation Editorで全フレームを再生できる。
- Publish後のAnimation IDを記録している。
- Animator / AnimationTrack経由で対象Rigに再生できる。
- 再生速度、ループ、接地、Root Motion相当の挙動を実ゲーム環境で確認している。

## Optional

- Rigify: Rig構成や編集の複雑さが必要な場合の補助。

## 必須依存ではないもの

- Rokoko Blender Plugin: 互換性問題が確認されているため、現時点では標準工程の必須依存にしない。

## 作業ファイルの配置

ローカル制作データは[`work/animations/`](../../work/animations/README.md)へ置く。共通Rigと再利用するリターゲット用Blenderファイルはそれぞれ`rigs/`、`templates/`に分け、個別モーションは`motions/<作業名>/`内で元FBX・編集.blend・出力FBX・プレビューを管理する。元データを残し、編集と出力には版を付ける。

FBX、Blenderファイル、動画は同フォルダの`.gitignore`でGit対象外とする。出所、編集内容、対象Rig、フレーム範囲、Robloxでの検証結果は個別の作業記録へ残す。

## Mixamo → 公式R15の固定実行（2026-10-17）

ユーザー指定により、W05の[保存済み手順](../../work/animations/scripts/README.md)を当該Rigの固定手順にする。入力確認→基準方向・座標補正→Bake→全フレーム検査→版付き保存→再読込確認を通す。通常FBXと標準R15用Pose変換アダプタを保存し、Studioの骨格階層・軸を別検証する。ツール固有操作はリンク先に置く。

Hook Punchでの再実行確認は他モーション・独自Rigの見た目／互換性を保証しない。Publishと実ゲーム再生の通過条件は維持する。

## モデル空間の前方向検査（2026-10-17追加）

Bake一致やAnimationTrack再生は前方向一致の証拠にならない。Mixamo／公式R15テンプレートの解剖学的前・上・右をRobloxの前−Z・上+Y・右+Xへ変換し、意味的な姿勢区間を実R15で検査する。旧v1の前後逆は再現・原因確定済み。[W05のv2ゲートと回帰検査](../../work/animations/scripts/README.md#前後逆を防ぐ必須ゲートanatomical-v2)を通してから公開IDを採用する。既存の公開IDにも方向を再検証し、逆向きassetを再生できただけで合格にしない。
