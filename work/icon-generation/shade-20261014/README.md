# SHADE アイコン試作（5枚）

**Status: Draft（5枚生成済み・図柄は要調整）**
**依頼日: 2026-10-14**

## 依頼と根拠

ユーザー指定は **SHADEを5枚**。OpenCodeの無料モデルを3担当で動かして生成依頼を準備し、Draw Things（SDXL）へ共通ワーカーで1枚ずつ投入する。

SHADEは [`docs/systems/skill-build.md`](../../../docs/systems/skill-build.md) の探索系・ランク2の設計案。ステルス状態で直線上を瞬間移動し、経路上の相手へ攻撃する。不可視の継続時間と、すべてのAnomaly Entityに検知されないかは未確定。安定したSystem IDも未定のため、この試作ではIDを新設しない。

[`skill-icon-review.yaml`](../../../tools/ui-layout-editor/samples/skill-icon-review.yaml) のSHADE欄も参考にするが、既存SVGの意匠を確定デザインとして扱わない。

## 担当

| 担当 | 枚数 | 比較する構図 |
| --- | --- | --- |
| A | 2 | 直線瞬間移動・残像の読みやすさ。 |
| B | 2 | 移動経路の相手に攻撃することの読みやすさ。 |
| C | 1 | 消えかける人型によるステルスと直線移動の統合。 |

正方形、暗い背景、匿名の人型シルエットを大きく置く2D表現を共通の視覚仮案とする。色・残像・衝撃の表現は制作上の仮案であり、世界設定や攻撃方式を決定しない。武器・衣装・数値・怪物の正体を追加しない。文字、ロゴ、枠、流血表現を入れない。

既存のSVGレビュー仮案には、探索系の黄色 `#e8b13a` と透過背景の指定がある。今回のSDXL構図比較は暗背景・アイボリー・寒色を使う別の仮案であり、この差を正式な意匠変更として解消しない。既存のSVG・レビューYAMLは変更しない。

## 接続確認

- Draw ThingsのHTTP APIを `127.0.0.1:7860` で接続確認済み。導入済みモデルは `sd_xl_base_1.0_q6p_q8p.ckpt`。
- 携帯用ギャラリーの外部接続と認証は確認済み。
- OpenCodeの初回3担当は失敗。Happierの指定欄は `opencode/longcat-2.5-preview-free` だったが、実際の応答レコードは `ollama/llama3:latest` になり、接続拒否で停止した。
- ユーザーは、Codexが代わりにプロンプトを作る方法を選ばず、OpenCodeの復旧を優先した。
- 無料モデル名の表示だけで成功と扱わず、実際の応答レコードのprovider/modelと生成画像の保存を確認する。

## OpenCode復旧結果（2026-10-14）

- ユーザーがHappierのOpenCodeバックエンドを **ACP（レガシー）** へ変更した。CLIソースは管理インストールを優先し、OpenCode `1.18.32` を使用した。
- ACPの `read_only` では無料枠の `FreeTierError` が返り、`default` の接続確認は成功した。`default` の3担当もすべて完了。これは当日の実行比較の結果であり、すべての環境・無料モデルに共通する保証ではない。
- 3担当の実際の応答レコードは、provider `opencode` / model `longcat-2.5-preview-free`。応答時に非ゼロのtoken数を確認し、診断はGit対象外の `.runtime/shade-model-audit.json` に保存した。
- プロンプト本文は [`prompts-A.json`](prompts-A.json)、[`prompts-B.json`](prompts-B.json)、[`prompts-C.json`](prompts-C.json)。プロンプトはOpenCodeが作成し、Codexが件数・仕様境界を確認して依頼JSONへ転記した。
- 実行ID、Seed、依頼ファイル、出力ファイルは [`batch.json`](batch.json) に記録する。LLMの3並走と、Draw Thingsの1枚ずつの処理は別々に確認する。
- 調査用に一時追加したリポジトリ直下の `opencode.json` は、明示モデル指定がACPで反映することを確認後に除去した。プロジェクト全体の既定モデルはこの試作で固定しない。

## 保存先

担当ごとの `../A/requests/`、`../B/requests/`、`../C/requests/` に実際の生成依頼を保存し、完成画像は各担当の `images/` に保存する。実画像と生成条件はレビュー候補であり、ゲーム仕様や正式アセット採用の正本ではない。

## 初回の生成・閲覧結果

2026-10-14に **A: 2枚 / B: 2枚 / C: 1枚** を実際のDraw Thingsで生成した。全ジョブは `done`、1024×1024のPNGは5枚。各PNG内部のDraw Thingsメタデータを手動確認し、モデル・Seed・Steps・CFG・Sampler・正負のプロンプトが依頼と一致することを確認した。CLIP Skipはアプリから継承した2、Seed ModeはScale Alikeだった。

外部HTTPS URLで、認証後の一覧が5枚になり、5枚すべての元画像がローカルファイルと同じSHA256で取得できることを確認した。未認証の画像取得は401。Safariで一覧・担当別絞り込み・拡大・32/48/64px表示と狭いウィンドウでの表示を確認した。実機iPhoneや携帯回線からの確認は未実施。

詳細は [`generation-verification.json`](generation-verification.json) と [`quality-observations.json`](quality-observations.json)。生成経路の動作成功と、アイコンとしての意匠の成功は区別する。

| 案 | 目視した構図のずれ |
| --- | --- |
| A1 | 人型が多数に増え、枠・区切り線が出現。2地点と1本の経路になっていない。 |
| A2 | 人型の増殖、分岐・湾曲した軌跡と枠が出現。単一の主役と直線残像が不明瞭。 |
| B1 | 囲い・奥行き線と人物に付随する不明な形状が出現。経路と衝撃記号が不明瞭。 |
| B2 | 全身人型と斜めの経路が、頭部の横顔と大きな円形・枠へ変化。 |
| C1 | 頭部を覆う形状・衣装・台座が出現。消える輪郭と直線トレースがない。 |

5枚とも正式アセット採用には至っていない。見た目を改善する場合は、この結果をOpenCodeへ返してプロンプトや生成条件を調整する。再生成は初回5枚とは別の試作として記録する。
