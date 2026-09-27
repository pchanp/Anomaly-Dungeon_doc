# ソース管理用ディレクトリ

Roblox Studioから取得した実装ソースをGitで管理するディレクトリです。構成は [`docs/systems/project-structure.md`](../docs/systems/project-structure.md) の責務分離に合わせています。

```text
src/
├── ReplicatedStorage/AnomalyDungeon/Shared
├── ServerScriptService/AnomalyDungeonServer
└── StarterPlayer/StarterPlayerScripts/AnomalyDungeonClient
```

Roblox Studio上の実プロジェクトとこのディレクトリは自動同期されません。Studioへ反映する際は、各ファイルの配置とScript種別（`.server.luau`、`.client.luau`、ModuleScript）を確認し、Remote、Asset、Workspace上の実体を維持してください。

Rollbackや作業前バックアップはGit履歴で管理し、`src/`やStudioプレース内へ追加しません。
