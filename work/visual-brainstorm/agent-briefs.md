# 並走制作指示（再利用用）

**Status: Visual brainstorm（非正典）**

## 共通指示

`AGENTS.md`、`README.md` と関連する `docs/` を読んでから、現行Studio実装ではなくMDを根拠に2D設定資料を作成する。MDにある要素と、画を成立させるための視覚仮説を分けて記録する。未決定の外見、地形、時代、因果、名称を確定設定にしない。各案には見られる画像またはHTML/SVG、参照MD、仮説、未確定事項を添える。ソース・Studio・既存仕様は変更せず、コミット・プッシュもしない。

## Kiloへの依頼：マップ

8月31日、TSUTAYA、SEKIGAHARA、KOROHKAN、Observation / Open Liminal Mapの5案を、各マップ別の2D環境設定画として描く。各マップの `docs/systems/map-gimmick-ideas.md` と関連するDecision Logを優先する。8月31日は夏の日常的なランドスケープ、TSUTAYAは閉店直後の密度を重視する。TSUTAYAは内部Map IDであり、商標入りの店名は描かない。実在の地理・戦史・中世ファンタジーの外観を無批判に固定しない。まず全対象に簡潔な可視案を揃え、細部は後で調整する。

## OpenCodeへの依頼：アノマリーとNPC

MiW、`/dev/null`、Memory Swapper、Mad Stomper、whisperの5種のAnomaly Entityと、博士・元同僚を個別の2D設定ボードとして描く。各 `docs/anomalies/` と世界観・情報提示方針を読む。姿が本質ではないアノマリーは、無理に怪物の正面図にせず、周囲の痕跡、認知差、相互作用を画にする。博士と元同僚の年齢・性別・顔・衣装は未確定なので、姿勢・環境・複数のシルエット案で対比する。Player AnomalyとAnomaly Entityを混同せず、謎の答えやQuestの結末を描き切らない。

## Codexの参加範囲

架空都市の世界観ボード、5マップ、5種のAnomaly Entityの接触シート、Player Anomalyの知覚差、博士と元同僚の対比を、組み込み画像生成で試作。画像と根拠・仮説・未決事項は [Codex案](codex/README.md) に記録する。
