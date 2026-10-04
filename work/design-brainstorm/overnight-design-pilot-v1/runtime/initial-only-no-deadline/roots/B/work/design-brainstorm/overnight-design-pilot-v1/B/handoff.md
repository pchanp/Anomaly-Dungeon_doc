# ROLE=B handoff — overnight-design-pilot-v1（試走3件）

**状態: awaiting_pilot_review（PILOT_ONLY）。本番12件へ進んでいない。**

このファイルは交接用の記録であり、採用判断・実装・コミット・正本の更新は一切行っていない。

## 1. 件数と分類

| candidate_id | 主対象マップ | 分類 | title | design_status | item_kind | requires_code | prototype_cost | conflicts | unresolved_refs |
| --- | --- | --- | --- | --- | --- | --- | --- | ---: | ---: |
| ROLE-B-001 | 8/31 | マップ固有 | 預け札（帰還面脇のRun枠外置き場）— 作業用見出し | Idea | 通常探索品 | true | 中 | 1 | 2 |
| ROLE-B-004 | 廃TSUTAYA | マップ固有 | 未整理ケースの1本（個人試聴か共有BGMか）— 作業用見出し | Draft | 未確定 | true | 中 | 0 | 2 |
| ROLE-B-013 | 全マップ共通 | 全マップ共通 | 入出庫札（安全を1段買うたび異常性に近づく）— 作業用見出し | Draft | スロットレアルート品 | true | 中 | 1 | 3 |

- 完成した候補は **HTML＋JSONの組で3件**。予約枠15件のうち3件。
- 未作成12件：ROLE-B-002 / 003 / 005 / 006 / 007 / 008 / 009 / 010 / 011 / 012 / 014 / 015。index.html ではリンクではなく文字として示した。
- 候補件数に数えない補助物：index.html / manifest.json / board.css / progress.json / events.jsonl / handoff.md。

3件はそれぞれ別の判断と代償を持つようにした（Time／共有 irreversibility／安全と異常性の価格付け）。名称・倍率・マップだけを変えた複製ではない。

## 2. 表示確認

- `progress.visual_check.status = unavailable`。
- 理由：このセッションはブラウザを使用できないため、実ブラウザでのHTMLおよびSVGの目視確認をしていない。SVGには `viewBox` / `role="img"` / `aria-label` を付けているが、これは記述として確認しただけで目視確認ではない。共通パックの `validation-report.md` も目視確認は Unconfirmed と記録しており、同じ限界を共有する。
- 機械検証（`common-pack/scripts/validate.py`）も未実行。今回の指示でPython検証と実表示確認は管理側の担当としたため、終了コードも出力も参照していない。**機械検証を通過했다고主張しない。**
- 3つのSVGはいずれも候補固有の作用図（001=時間帯と置き場、004=個人提示と共有書き換えの分岐、013=枠と例外操作と対価）。同一个の汎用「入力→結果」図に名前を入れ替えたものではない。

## 3. 参照（他担当・正本）

予約IDを参照したのは ROLE-A-002（001）と ROLE-A-005（004）の2件のみ。いずれも `kind: optional_connection` / `resolution: reserved_unresolved` とし、同じ target_id を `unresolved_refs` にも記載した。**peer-snapshots が配布されていないため、A-002 と A-005 の本文および provides_traits は一切読んでおらず、予約枠の存在だけを根拠に解決扱いにしていない。** 相手のNPC・ギミック・スキルは作っていない。ROLE-B-013 は refs が空配列で、ID未指定の接続要求のみを unresolved_refs に置いた。

参照の代替（fallback）:

- 001: 帰還面の開閉は既存の `August31Service` の DAY→EVENING→NIGHT→AUG_32 進行と `ExitUnlocked` で判定できる。A-002 が成立しなくても 001 は成立する。
- 004: 試聴・CRT・共有BGMの枠組みと個人試聴の分離は実装済み。Effect 1 と Effect 3 は接続先なしで成立する。Effect 2 だけが入口権限を欠く。
- 013: A/Cのどの予約IDにも依存しない。既存 InventoryService の枠境界と ExposureService の個人Attributeだけで成立する。

## 4. 重複検査（意味的な重複）

3件は「Run中の第三の置き場」「個人提示と共有状態の分岐」「安全を対価で買う例外操作」で別々。ただし**参照の観点では重複の懸念がある**。001 と 013 はどちらも Secure Slot 周辺古今 に属し、SecureSlot 経路とRun中の枠の扱いを共有するため、003 / 015 の設計時に 001 と 013 のどちらかの派生にしないことを推奨する。同じことは HTML 本文の SecureSlot 行でも明示した。

## 5. 世界観の留保（確定しなかったもの）

- 3件とも「ルールは明確、意味は曖昧」の境界守住ため、起源・正体・博士の真意・媒体や道具の由来を断定していない。
- INV-01〜11 の全IDを各候補の `worldview.invariants_checked` に記載した。これは自己確認であり、検証器が内容の整合性を証明するものではない。
- 意図的なデペイズマン: 001＝「安全は永続成長で積む」ではなく「生還して回収できたこと」を条件にする案。004＝試聴可能な音ではなく「公開の不可逆さ」を中心にした媒体。013＝効果を数値の上がり幅ではなく異常性との距離として提示。
- 既存作品・実在TSUTAYA・現実の日本の固定・具体的な地名や固有名の転写は使っていない（004の媒体名は「名前と選択結果」のみ、001は地名を出さない）。
- 004 は `map-gimmick-ideas.md` の既存案（「Back Roomなどで再生すると共有BGMが変わる」）の上乗せであることを本文で明示し、正本の書き換えを避けている。

## 6. requires_code

3件とも **true**。理由はそれぞれ異なる:

- 001: 物品の所在そのものが未実装（デバッグ付与のみ）。第三の所在（預け簿）の新設が必要。
- 004: 個人入力からServerの共有BGMを差し替える経路が未実装。個人試聴のみなら既存実装で成立するが、候補の中核が共有への提示のため false としない。
- 013: Run中のSecure Slot操作と新しい消費品が必要。Exposureの単位が未設計であることは、根拠が弱いのではなく未決であることを示す。

`false` にした候補はなく、`unknown` にした候補もない。proposed な新規コンポーネントは 001 の `RunDepositLedger` のみ（catalog には未掲載。実装もカタログ追加も行っていない）。

## 7. 所要時間・モデル・費用

- すべての時刻は **null**。Bash を使わず時刻取得もしない指示のため、観測できない時刻を推測で埋めていない。管理側の観測開始時刻は提示されたが、自分のセッションの実時刻として転記していない。
- 所要時間（読み込み／試走3件／待機）の実測値は **未計測**。文章量や記憶から秒数を推測していない。
- モデル・プロバイダ・セッションID: **null**。確認手段を持っていなかったため。
- トークン数・費用・通貨: **null**。管理サービスが実測値を提供していない。モデルの自己申告も使っていない。
- `prototype_cost.band` はゲーム内試作の見積もりであり、生成にかかった時間とは別の値。

## 8. 停止理由

停止要求・期限・予算・同一エラー3回・パック変更検出のいずれも起きていない。**停止理由は「PILOT_ONLYの指示により試走3件で終了」**であり、異常による中断ではない。管理側が停止を指示するまで待機する（runnerの停止も管理側の担当で、自分ではプロセスを触らない）。

## 9. 採用判断が必要な論点（自分は判断しない）

1. **001 / current-implementation.md との衝突**: 預け簿の品物を成功時の獲得物に含めるか。8/32遷移で取り出せなかった品も「成功扱いの獲得物」として表示してよいか。conflicts に記録済み。
2. **004 / map-gimmick-ideas.md の既存案との差分**: 媒体の個体化と公開不可の消費を既存案へ足すか、それとも媒体をRoomの固定设施として扱うか。前者なら判断010の入出庫未決との相互作用が生じ、後者なら SecureSlot 経路の判断が成立しなくなる。
3. **013 / 判断011 の3系統**: 本件をスロット系の別系統として追記するか、新しい系統を立てるか。配布経路と消費内容の記述が変わる。conflicts に記録済み。
4. **正本側の規則欠落（adoption blocker）**: Run内に個人インベントリともSecure Slotとも異なる所在を規定する資料が無い（001）。個人入力からServerの共有BGMを差し替える権限規定が無い（004）。アイテム操作と結果傍受系（/dev/null）の評価順、以及Anomaly Exposure の単位と上限の定義が無い（013）。いずれも候補側で埋めず、未決として残した。
5. **判断019 と current-implementation.md の差（SRC-04）**: Player Anomaly Runtime 満了時が実装と設計で食い違っている。013 の副次効果（異常性へ近づく）を数値で説明しきれない部分はこの差に由来する。
6. **peer-snapshots 未配布**: ROLE-A-002 / ROLE-A-005 の provides_traits 未確認。配布後に required_traits の語彙を合わせ直す必要がある。
7. **Robux経路**: 判断010・判断011・経済と成長はいずれもIdea（未採用）。3件ともこれを前提に採用していない。

## 10. 再開手順（RESUME_AFTER_PILOT の場合）

1. このフォルダの `progress.json` と `manifest.json` を読む。`state` は `awaiting_pilot_review`、`completed_ids` は 3件。
2. 管理側の `--stage pilot` 検証結果を確認し、指摘があれば3件だけ修正する。`ROLE-B-001 / 004 / 013` は作り直さない。
3. `next_ids` の先頭から3件ずつ、ROLE-B-002 / 003 / 005 を次の batch とする。6件で検証。
4. 以降 009 完了で9件、012 完了で12件、残り2件で15件。15件で `--stage final` 検証。
5. 各 batch ごとに `events.jsonl` へ `batch_start` / `batch_end` を追記し、`manifest.json` の `completed` は保存後に更新する。書きかけは `.tmp` にしてから置換する。
6. SEKIGAHARA（007〜009）と研究所（010〜012）は `Idea` と判断018 相当の資料を土台に、勢力・地形・戦況・建物構造を確定せずに書く。**研究所のQuest装置（whisperの元同僚Questで残る装置）は既存資産であり、別アイテムへ置き換えない。**
7. 全マップ共通（014 / 015）は 013 とも001ともSecure Slot経路で重複しない領域を選ぶこと。
8. 最後に全リンクとHTML/SVGの実表示、未解決参照、コストを点検し、ブラウザ確認不能なら unavailable と理由を明記する。表示確認済みの 상태で checked にはしない。
9. 最終集計は管理側が行う（本セッションは時刻・モデル・費用が未計測）。

## 11. 出力物の一覧

```
work/design-brainstorm/overnight-design-pilot-v1/B/
  ROLE-B-001.html / ROLE-B-001.json
  ROLE-B-004.html / ROLE-B-004.json
  ROLE-B-013.html / ROLE-B-013.json
  index.html / manifest.json / board.css
  progress.json / events.jsonl / handoff.md
```

共通パック・正本MD・src・tools・他担当の出力・以前のworkは変更していない。コミット／プッシュ／accepted化／実装は行っていない。