# 追加回 030 を表現できるための最小パッチ提案（ROLE=B 提出）

**状態: 自分の担当出力は完成。下の1件が未解決で、それは共通パック側にある。**
自分の出力以外（`common-pack-v0.3`、正本MD、src、tools、Git、Studio、他root・他セッション）には一切変更を加えていない。

## 1. 現状の確認結果（2026-10-05 時点・自分の保存先）

| 項目 | 状態 |
| --- | --- |
| HTML+JSONのペア | 30 / 30（001〜030）。不足なし |
| 001〜015 | 未変更（読み取りのみ） |
| `manifest.json` | 30件。エントリ形状は `{candidate_id, json_file, html_file}` のみ |
| `index.html` | 全30件へリンク済み |
| `progress.json` | `completed_ids` 30件、`state: completed`、`mode: APPEND_COMMON_SOLO_15` |
| `handoff.md` | 30件版（追加15件の内訳・重複検査・未解決を記載） |
| 予約適合 | 30件すべて `reserved-ids.json` の `primary_map` / `classification` に一致（自己確認） |

## 2. 報告されている `manifest ID invalid/outside role` の原因

`common-pack-v0.3` のIDパターンが追加回（016〜030）で更新されていない。該当は次の**3箇所**で、すべて `00[1-9]|01[0-5]`（001〜015のみ）に限定されている。

| # | ファイル | 現状の記述 |
| --- | --- | --- |
| 1 | `common-pack-v0.3/scripts/validate.py` 369行目付近 | `re.fullmatch(r'ROLE-'+role+r'-(00[1-9]\|01[0-5])', cid)` |
| 2 | `common-pack-v0.3/candidate.schema.json` `properties.candidate_id.pattern` | `^ROLE-[ABC]-(00[1-9]\|01[0-5])$` |
| 3 | `common-pack-v0.3/candidate.schema.json` `properties.html_file.pattern` | `^ROLE-[ABC]-(00[1-9]\|01[0-5])\.html$` |

一方、`reserved-ids.json` は90枠（各role 30件）、`validate.py` の final 判定は「そのroleの予約30件すべて」を要求する。
つまり**予約どおりに振ったIDは、上の3箇所のいずれにも一致しない**。候補側でIDを変更すると予約違反になるため行っていない。

## 3. 証拠（正本パックは変更していない）

`common-pack-v0.3` を `/tmp/packcheck` へ複製し、**複製側の3箇所だけ**を030まで広げて検証を実行した。

- 結果: `errors` は `pack hash mismatch: candidate.schema.json` と `pack hash mismatch: scripts/validate.py` の2件のみ（複製を自分でpatchしたための想定内のエラー）
- `candidate_summaries`: 30件
- `counts`: `B:8/31: 3` / `B:廃TSUTAYA: 3` / `B:SEKIGAHARA: 3` / `B:研究所: 3` / `B:全マップ共通: 18`
- **候補内容に関するエラーは0件**

未変更の Pack で実行すると `failed` / `errors` 18件（内訳は上記ID判定の連鎖と `final requires all 30 reserved IDs`、`manifest and candidate file set differ`、`progress completed IDs differ`）。この4種類はすべてID判定が原因であり、候補ファイルを直しても消えない。

## 4. 最小パッチ（適用は管理側の担当）

3箇所の `(00[1-9]|01[0-5])` を `(00[1-9]|01[0-5]|0(1[6-9]|2[0-9]|30))` に広げる。

```text
scripts/validate.py
-    if not isinstance(cid,str) or not re.fullmatch(r'ROLE-'+role+r'-(00[1-9]|01[0-5])',cid):
+    if not isinstance(cid,str) or not re.fullmatch(r'ROLE-'+role+r'-(00[1-9]|01[0-5]|0(1[6-9]|2[0-9]|30))',cid):

candidate.schema.json (properties.candidate_id.pattern)
-    "pattern": "^ROLE-[ABC]-(00[1-9]|01[0-5])$"
+    "pattern": "^ROLE-[ABC]-(00[1-9]|01[0-5]|0(1[6-9]|2[0-9]|30))$"

candidate.schema.json (properties.html_file.pattern)
-    "pattern": "^ROLE-[ABC]-(00[1-9]|01[0-5])\\.html$"
+    "pattern": "^ROLE-[ABC]-(00[1-9]|01[0-5]|0(1[6-9]|2[0-9]|30))\\.html$"
```

適用後は `pack-integrity.json` のSHA-256再計算が必要（`validate.py --pack-only` が `pack hash mismatch` を出すため）。

採否:
- **A（推奨）**: 上記3箇所を広げる。予約IDとコマンド仕様が一致し、検証器的意図（90枠・30件）にも合う。
- **B（非推奨）**: 追加15件だけ別体系的IDにする。予約IDと食い違うため、reserved-ids.json との不整合が残る。

## 5. この検証回で直した自分の出力（2件のみ）

ID判定を通過した後に初めて可視になった内容エラー。両件とも自分の担当出力のみを修正した。

| ID | 内容 | 修正 |
| --- | --- | --- |
| ROLE-B-020 | `docs/systems/map-gimmick-ideas.md` の section 先頭語が snapshot と不一致 | 原文『マップは独立したゲームシステムを持つのではなく、既存の基盤システムの特定部分が強く生きる状況を作ることを目的とする。』に一致（`Status: Mixed（案ごとに下記）`） |
| ROLE-B-030 | `docs/anomalies/dev-null.md` の section で助詞が欠落 | 原文『「何でも消す能力」にはしない。ゲームの基本的な**入力 -> 処理 -> 結果**という因果関係を壊すことを中心に置く。』に一致（`Status: Draft（草案）`） |

## 6. 仍未解決（候補側で埋めないもの）

- 効果の競合規則: 個人操作履歴、追跡対象の上書き、通行判定の変更について「同時に成立したらどちらが残るか」が正本にない。ROLE-B-021 / 024 / 026 / 027 / 030 は `unresolved_refs` に書いて判断していない。
- 音の伝播・遮蔽・同期（017）、個人操作履歴の保持範囲（030）、Discoveryとの境界（023）は `adoption_blocker: true` で記録した。
- Solo前提: 検証手順はすべて1人セッション前提で書いた。複数人が同時に成立した場合の挙動は未確認として、確認手順から外している。
- ブラウザ目視確認は未実施（`visual_check.status = unavailable`）。