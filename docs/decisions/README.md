# 設計判断記録

重要な設計判断と、その判断に至った理由をここに保存します。`001-anomaly-exposure.md` のように、原則として1つの判断につき1つの番号付きファイルを作成してください。

設計判断記録には通常、以下を記載します。

- 状態と日付
- 背景
- 決定内容
- 判断理由
- 影響
- 関連資料または関連する実装領域

判断が変更された場合は、以前の判断を置き換える新しい記録を追加してください。過去の判断理由を削除しないでください。

## 記録

- [001: ゲームループとポータル遷移の設計方針](001-game-loop-and-portal-transitions.md) - ランの循環、Player Anomaly、状態依存のポータル遷移に関する草案。
- [002: アニメーションのリターゲット工程を特定プラグインへ依存させない](002-animation-retarget-tool.md) - 制作工程とツール固有情報を分離する判断。
- [003: 8月31日の時間進行と8月32日の状態遷移](003-august-31-time-and-phase-design.md) - マップ固有の時計、夕方の帰還、8/32の帰還閉鎖と環境の所有権に関する判断。
- [004: 都市入口と情報提示の設計方針](004-city-entry-and-information-design.md) - 2D都市入口、施設内3D、世界情報の提示方針に関する草案。
- [005: 都市ロビーから開始する最小Runの範囲](005-minimum-lobby-run-scope.md) - 2マップを対象にした、都市ロビーから単一マップへ入る最小Runの草案。
- [006: 最小Runの実装で確定したサーバー境界](006-minimum-run-server-boundaries.md) - 最小Runをコードに落とした際のRun状態、終了の集約、ロビーの実体、入口の認可、デバッグ経路の境界。
- [007: 8月31日マップの地形・湖・時計の再設計](007-august-31-terrain-lake-and-clocktime.md) - フェーズごとの`ClockTime`、高さ関数としての地形、ゾーンの平坦化、湖の絶対高と円形水面、地形に沿うTrail。003の`ClockTime`判断を置き換える。
- [008: 8月31日の景観構成を、ブロックアウトから夏の谷へ寄せる](008-august-31-landscape-composition.md) - 視線、植生、水辺、生活の痕跡を用いた景観再構成。ソース反映済みで、Studio確認待ち。
- [009: TSUTAYAを「閉店直後のアーカイブ」として再構成する](009-tsutaya-closing-time-archive.md) - 棚の密度、店頭、返却作業、照明を優先し、荒廃テクスチャは後から重ねる判断。
- [010: レアルート品によるSecure Slot成長](010-real-route-secure-slot-progression.md) - 都市ロビーの研究室で、レアルート品を用いてSecure ConversionとCapacity Expansionを行う判断。課金経路は未採用。
- [011: レアルート品の分類と取得経路](011-real-route-acquisition.md) - 汎用スキル用とスロット用のレアルート品、アノマリー固有の交換品、Quest・チュートリアルへの接続を定める判断。
- [012: アノマリー相互作用による固有スキル取得](012-anomaly-linked-skill-acquisition.md) - アノマリー固有の交換品、博士の調査Quest、研究対象外のレアアノマリー、Party全員への固有品配分を定める判断。
- [013: Mad StomperとGIANTプロトタイプの同一性](013-mad-stomper-giant-identity.md) - `GIANT`、`Giant Anomaly`、`Mad Stomper`を同一Anomaly Entityとして統合する判断。
