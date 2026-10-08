# アノマリードキュメント

可能な場合は、1体のアノマリーにつき1つのMarkdownファイルを使用します。ファイル名は `miw.md` や `dev-null.md` のように、安定していて読みやすいものにしてください。

資料には必要に応じて、System ID、Game Name、コンセプト、Type、Behavior、Affinity、Visibility、構成要素、Trigger、Runtime Behavior、プレイヤーとのInteraction、Anomaly Exposureとの関係、関連するPlayer Anomaly、Prototype status、未確定事項、実装上の注意、関連資料などを記載できます。個々のアノマリーを説明するために役立つ項目だけを使用してください。

システムIDとゲーム内名称は別のものです。ゲーム内名称は必須ではありません。テンプレートを埋めるためだけに名称を作らず、既存の名称と大文字・小文字表記を維持してください。

## Anomaly Entity

- [MiW](miw.md) - 棺に収まり、観察・接触にリスクとRun情報を伴う猫型アノマリー。
- [/dev/null](dev-null.md) - 入力・命令・結果の対応関係をnull化するアノマリー。
- [Mad Stomper](mad-stomper.md) - 撃破ではなく鎮静化・通過を扱う巨大環境アノマリー。
- [Memory Swapper](memory-swapper.md) - 記憶と認識に応じてItemStackを移動させるInnocentなアノマリー。
- [whisper](whisper.md) - 音響・認知へ干渉し、指定対象へ付き従うInvisibleなアノマリー。博士の元同僚Questと専用スキル`anxiety`へ接続するDraft。

- [smudge](smudge.md) - 会話で言葉・InteractionをRun中侵食し、音楽によって逆に侵食され得るAnomaly EntityのIdea。

- [stray](stray.md) - 帯電可能な物体間を光のパルスで渡り、縦の危険帯と経路循環を持つ、モデル不要のAnomaly Entity案（Idea）。

## Player Anomaly

Player AnomalyはAnomaly Entityと区別して[`player-anomalies/`](player-anomalies/)に置く。

- [Visible / Invisible Inversion](player-anomalies/visible-invisible-inversion.md) - 可視性と認識を反転させるRun単位のPlayer Anomaly。

## 横断的な設計資料

- [認知アノマリー](cognitive-anomalies.md) - 観察・認識・認識差をアノマリー相互作用として扱うためのDraft。個別Anomaly EntityやPlayer Anomalyではない。
