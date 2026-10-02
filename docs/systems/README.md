# ゲームシステムドキュメント

ゲームがどのように動作するかをここに保存します。対象には、コアゲームループ、ラン、探索、Anomaly Exposure、Player Anomaly、Anomaly Entityとの相互作用、戦闘、アイテム、スキル、セキュアスロット、死亡、脱出、報酬、マルチプレイヤー、サーバー／クライアント責務、UI、状態遷移、データ構造などが含まれます。

システムルールと世界設定を混在させないでください。特定のアノマリーに依存するルールは、そのアノマリーの資料へリンクしてください。

採用済みでない設計には、`Draft（草案）`、`Idea（アイデア）`、`Unconfirmed（未確認）` などの状態を明記してください。

## 現在の開発資料

- [現在の実装状況](current-implementation.md)
- [Robloxプロジェクト構成](project-structure.md)
- [未実装機能の優先順位](implementation-priorities.md)
- [ゲームループとポータル遷移](game-loop.md)
- [ゲームルール](game-rules.md)
- [マップとギミック案](map-gimmick-ideas.md)
- [ロビー／ワールドマップ](lobby-world-map.md)
- [編集テンプレートとRuntimeマップ](editor-templates-and-runtime-maps.md)
- [クエスト](quests.md)
- [経済と成長](economy-and-progression.md)
- [アノマリー相互作用](anomaly-interaction.md)
- [観察・認識システム](observation-and-recognition.md)

## 資料

- [ゲームループとポータル遷移](game-loop.md) - ランの循環、Secure Slot、Player Anomaly、ポータル遷移、Party Stateの現時点の草案。
- [ゲームルール](game-rules.md) - Run、終了条件、ビルド、戦闘、Return、Transition、Server / Client責務の草案。
- [マップとギミック案](map-gimmick-ideas.md) - 基盤システムを異なる文脈で活用するマップ案と設計原則。
- [ロビー／ワールドマップ](lobby-world-map.md) - 2D都市マップ、施設内3D、ダンジョンへの導線の草案。
- [編集テンプレートとRuntimeマップ](editor-templates-and-runtime-maps.md) - Studio編集用のマップ原本と、Run単位のRuntimeコピーを分離するための草案。
- [クエスト](quests.md) - 明確な目的と不明な対象を両立する依頼設計の草案。
- [経済と成長](economy-and-progression.md) - 換金、レアルート、コレクター、スキル強化の世界内解釈の草案。
- [アノマリー相互作用](anomaly-interaction.md) - 既存の行動・アイテム・環境イベントを個別アノマリーへ接続する共通設計の草案。
- [観察・認識システム](observation-and-recognition.md) - 視野・遮蔽・継続時間をObservation Evidenceとして扱う共通設計の草案。
