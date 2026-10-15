# 制作ワークショップ

**Status: Draft（初期運用の文書基盤。各制作工程の成立は個別検証）**
**更新日: 2026-10-15**

制作領域をW01〜W06として識別し、担当が仕様を読み、固定した入力から制作・検証し、次の担当へ結果を渡すための入口。2026-10-14に初期基盤の整備が承認された。ゲーム仕様、画風、未検証ツールの標準採用を決定するものではない。

## 作業部屋と既存資産

| 部屋 | 責務 | 現在の入口・状態 |
| --- | --- | --- |
| W01 アイコン | 意味を視覚表現へ翻訳し、生成・比較 | [既存作業場](../../../work/icon-generation/README.md)。生成・レビューPrototypeあり、正式意匠は未採用 |
| W02 2D→3D研究 | 意匠・厚み・裏面・修正工数・価値を検証 | 独立作業場は未整備。開始時に `work/icon-to-3d/` を追加。全アイコンを3D化しない |
| W03 環境アセット | 形状、表面素材、UV、最適化、静的導入 | [既存材質試作](../../references/material-preview.md)。制作・編集担当はCodex専用。通常Import・実ゲーム検証は未完了 |
| W04 モデル・Rig | 複雑な静的モデル／変形可能モデルを制作 | [キャラクター工程](../character-pipeline.md)。開始時に `work/characters/` を追加。生成・Rigの互換性は個別検証 |
| W05 アニメーション | 対象RigへRetarget・Bake・導入検証 | [既存作業場](../../../work/animations/README.md)。R15骨格試作あり、独自Rigは別検証 |
| W06 UI試作 | レイアウト・操作・状態を検証しRoblox実装仕様へ渡す | [既存UI Layout Editor](../../../tools/ui-layout-editor/README.md)。試作出力は開始時に `work/ui-prototypes/`。Roblox生成機能は未着手 |

部屋は専門領域であり、常時稼働する6エージェントではない。既存W01レーン、W05 `motions/`、材質試作を移動・複製しない。新しい部屋は具体的なタスク開始時に作る。

## 文書と進捗の正本

- [ROADMAP](ROADMAP.md)：導入順序と通過条件。[最小Runロードマップ](../minimum-run-development-roadmap.md)の手動試走→半自動化方針を継承する。
- [棚卸し](inventory-2026-10-14.md)：確認範囲、更新差、共有上の未確認事項。
- [受け渡し](shared/handoff.md)、[視覚設計](shared/art-direction.md)、[検証](shared/validation.md)：部屋をまたぐ共通契約。
- [TASKテンプレート](templates/TASK.md)、[RESULTテンプレート](templates/RESULT.md)：作業指示と試行記録。
- [Workboard](../../workboard.md)：進捗・優先順位・次の人間判断。別Workboardは作らない。
- [制作共通規約](../../../work/AGENTS.md)：実行担当の境界。専門工程は既存 `docs/production/`、ツール操作は `docs/references/` を参照する。

各部屋の `TASKS.md` は初期には作らない。必要になった場合もリンク索引とし、状態の手動二重管理を避ける。Skills化・新しい実行基盤は反復検証後に判断する。

## 次の入口

文書基盤と[W01-01の評価](../../../work/icon-generation/tasks/W01-01/runs/review-20261015/RESULT.md)は完了し、20候補は見送り。次は[指定された3構図](../../../work/icon-generation/tasks/W01-01/composition-directions.en.md)の指示具体化（W01-02）と [W03-01 通常導入の検証準備](tasks/W03-01.md)。これらの作成は生成・Studio変更の実行許可ではない。Workboardの判断条件を満たしてから実行する。
