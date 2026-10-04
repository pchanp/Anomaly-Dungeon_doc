# 参照文書の記述差と留保

**Status: Unconfirmed（パック作成時に確認した記述差。正本は変更していない）**

## SRC-01 Inventory / Secure Slot

`current-implementation.md` の実装済み基盤・最小Run節はInventoryServiceの20枠／Secure Slot 4枠と獲得・喪失分類を記す。一方、同文書「未実装」と `game-rules.md` 等には正式Inventory／ItemStack未実装の記述がある。

境界データ・デバッグ付与は実装済み、正式取得源・ItemStackは未実装という粒度差を含む。全Inventory経路が動くと断定しない。必要機能を小分けにし、未確認部分は `requires_code: unknown` または理由付きtrueで記録する。Studio確認は今回行わない。

## SRC-02 マップ読み込みとTransition

`map-gimmick-ideas.md` には8/31読み込み未確認という記述が残り、`current-implementation.md` にはPlay Solo確認済みとある。TSUTAYAの直接読み込みと正式Run抽選についても時点・節で記述差がある。

正式RunはTSUTAYA/AUGUST_31の抽選、Transition Portalは範囲外という明示的な境界を候補の前提にする。古い未確認記述を消したり、Transitionが実装済みと読んだりしない。

## SRC-03 ClockTimeの後続判断

判断003の「ClockTimeは変更しない」は判断007によって置き換えられている。これは後続判断が明示する置換であり、生成側が独自に矛盾を解消する例ではない。フェーズ別ClockTimeを参照するときは007も引用する。

## SRC-04 Player AnomalyのRuntime満了

判断019は満了時を通常Returnと同じ帰還処理とするが、current-implementation.mdには暫定の失敗処理が残る。採用済み設計と実装差を分け、資産・Quest・報酬の未決部分を創作しない。

## SRC-05 8/31の着想元

map-gimmick-ideas.mdには実在作品と日本の夏休みの記号への言及がある。今回のユーザー指示とworld/setting.mdは、現実の日本や既存作品そのものの再現を許していない。時間・季節の終端を異化する文脈を用い、作品の固有設定や演出を流用しない。

新しい文書不一致を見つけたら、この共通ファイルは変更せず自分の `handoff.md` と候補の `conflicts` / `uncertainties` へ記録する。推定だけで正本を決めない。
