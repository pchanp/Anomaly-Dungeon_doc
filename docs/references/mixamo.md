# Mixamo

## 位置付け

通常のモーション制作で、編集元となる既存モーションを取得する。特殊な動きはDeepMotion等を代替手段とする。

## 利用と互換性

- Adobe IDが必要。Adobe公式FAQでは無料で利用でき、ゲームを含む商用・非商用プロジェクトでモーションを利用できると説明されている。
- ライブラリと自動リギングは二足歩行の人型を対象とする。
- MixamoのSkeletonとRobloxの対象Rigがそのまま一致するとは限らない。Rest Pose、Bone Mapping、Scale、Rotation、接地、Rootの移動を確認する。
- 対象BlenderバージョンおよびRoblox RigでのImport・Retarget・Export・再生の互換性は未確認。最初のモーションで検証する。
- 元モーション名、取得元、編集内容、出力物を記録する。

## 関連資料

- [Adobe公式FAQ](https://helpx.adobe.com/jp/creative-cloud/faq/mixamo-faq.html)
- [制作パイプライン](../production/animation-pipeline.md)
- [採用判断023](../decisions/023-animation-source-priority.md)
