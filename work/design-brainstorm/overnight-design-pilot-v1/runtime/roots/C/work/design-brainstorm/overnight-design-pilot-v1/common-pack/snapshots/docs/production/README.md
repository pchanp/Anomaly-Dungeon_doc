# 制作ワークフロー

ゲームの仕様ではなく、アセットを作成しRobloxへ導入するまでの反復可能な工程を管理します。

## 文書一覧

- [アセット制作パイプライン](asset-pipeline.md)
- [キャラクター制作パイプライン](character-pipeline.md)
- [アニメーション制作パイプライン](animation-pipeline.md)
- [Blender作業](blender-workflow.md)
- [Robloxへの導入](roblox-import.md)
- [Studio検証チェックリスト](studio-verification-checklist.md)
- [制作トラブルシューティング](troubleshooting.md)

## 管理方針

- `production/` にはプロジェクトとして「何を、どの順序で行うか」を記載します。
- 外部ツール固有の操作や互換性情報は [`../references/`](../references/) に分離します。
- ゲーム内の挙動やルールは `systems/` または `anomalies/` に記載します。
- 未検証の手順は標準として扱わず、状態を明記します。
- 標準工程の採否に関わる変更は `decisions/` に判断理由を残します。
