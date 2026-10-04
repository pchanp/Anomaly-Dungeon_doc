# 002: アニメーションのリターゲット工程を特定プラグインへ依存させない

**Status: Accepted（採用）**
**Date: 2026-09-28**

## 背景

DeepMotionから取得したモーションをBlenderで対象キャラクターへ移し、Robloxへ導入する工程を繰り返し利用する。Rokoko Blender Pluginは候補の一つだが、Blenderとアドオンのバージョンの組み合わせによって、Retargeting UIが利用できない事例があった。

## 決定

- プロジェクトの標準工程は、特定のリターゲット用プラグインだけに依存させない。
- 標準工程には「Source ArmatureからTarget Armatureへリターゲットし、結果をBakeする」という目的と検証条件を記載する。
- 実際に使用するツールと操作手順は `docs/references/` で管理する。
- Rigifyは必要に応じて利用できる補助選択肢とする。
- Rokoko Blender Pluginは現時点の必須依存にしない。再採用する場合は、対象バージョンで検証してから標準へ反映する。

## 影響

- ツールを交換しても、制作工程全体の定義を維持できる。
- 新しいツールを標準採用する前に、互換性とRoblox上の再生結果を確認する必要がある。
- ツール固有の問題は制作工程ではなく、参照資料とトラブルシューティングへ記録する。

## 関連資料

- [アニメーション制作パイプライン](../production/animation-pipeline.md)
- [Blenderリターゲット参照](../references/retarget.md)
- [制作トラブルシューティング](../production/troubleshooting.md)
