# 023: 通常モーションはMixamo、特殊モーションはDeepMotionを使う

**Status: Accepted（採用）**
**Date: 2026-10-12**

## 背景

DeepMotionの出力には手足の震えがあり、Blenderでの補正を通常の制作工程として繰り返すには工数のハードルが高い。

## 決定

- 通常のモーションはMixamoの無料の既存モーションを元に適宜編集する。
- DeepMotionから取得してBlenderで調整する工程は、特殊なモーションに限定する。
- 対象Rigへのリターゲット、Bake、Robloxでの再生検証は引き続き必要に応じて行う。
- 判断記録002の「特定リターゲットプラグインを必須にしない」方針は維持する。

## 理由と影響

通常モーションのノイズ補正にかかる工数を抑え、独自性が必要な動きへ調整作業を集中する。MixamoからRobloxへの互換性が検証済みになったことを意味しない。採用するモーション、対象Rig、出力結果は個別に確認する。

## 関連資料

- [アニメーション制作パイプライン](../production/animation-pipeline.md)
- [Mixamo](../references/mixamo.md)
- [判断記録002](002-animation-retarget-tool.md)
