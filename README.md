# Anomaly Dungeon

Anomaly Dungeonは開発中のRobloxゲームです。このリポジトリは、WindowsやmacOSから編集する人、GitHub、Codexが、長期にわたって同じ情報を参照するための設計・実装上の共通記憶です。

現在はドキュメント管理の基本構造を整えた段階です。詳細なゲーム設定は、確定するまで意図的に記載しません。ソースや設定を明示的にGit管理へ移すまでは、Roblox Studio上の実プレースとこのリポジトリを別のものとして扱います。

## ディレクトリ構成

| パス | 役割 |
| --- | --- |
| [`AGENTS.md`](AGENTS.md) | ドキュメントや実装を変更する前に、Codexと開発参加者が従うルール。 |
| [`docs/world/`](docs/world/) | 世界観、ロア、用語、プレイヤーが知り得る情報、意図的な謎。 |
| [`docs/systems/`](docs/systems/) | ゲームの挙動、ルール、ループ、状態、ネットワーク、UI、データ構造。 |
| [`docs/anomalies/`](docs/anomalies/) | 個別アノマリーの設計資料。原則として1体につき1ファイル。 |
| [`docs/production/`](docs/production/) | アセット、キャラクター、アニメーション等の制作ワークフロー。 |
| [`docs/decisions/`](docs/decisions/) | 重要な設計判断と、その判断に至った理由。 |
| [`docs/references/`](docs/references/) | BlenderやDeepMotionなど、外部ツール別の補助情報。 |
| [`src/`](src/) | 将来Gitで管理するRoblox関連ソース、設定、共有データ。 |

## ドキュメントの追加先

- 世界に関する事実は `docs/world/`、ゲームルールや実装上の挙動は `docs/systems/` に置きます。
- 個別アノマリーのコンセプトや挙動は `docs/anomalies/` に置きます。システムルールを重複して書かず、関連資料へリンクしてください。
- ゲームを制作するための標準工程は `docs/production/`、個々の外部ツールに依存する操作情報は `docs/references/` に置きます。
- 将来も理由を参照する必要がある重要な判断は、`docs/decisions/` に番号付きのファイルとして記録します。
- 未確定の内容には `Draft（草案）`、`Idea（アイデア）`、`Unconfirmed（未確認）` などの状態を明記します。実装済み・採用済みの仕様として扱わないでください。
- 作者だけが知る情報と、プレイヤーがゲーム内で知り得る情報を区別してください。

## Codexで使用する際の方針

Codexは変更前に [`AGENTS.md`](AGENTS.md) と関連資料を確認します。不足している設定の創作、矛盾の暗黙的な解消、アイデアを実装済み機能として扱うことは禁止します。実装作業では文書化された設計との整合性を確認し、Roblox Studio上の実プロジェクトとの差異があれば明示的に報告します。
