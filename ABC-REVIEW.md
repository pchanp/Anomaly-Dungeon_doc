# ABC 設計候補 — 一時レビュー入口

Status: Draft（収集記録）。採用・実装・統合は未実施。2026-10-05 時点の作業者出力を保存。

## 状況

依頼数は各15件、合計45件。HTMLは A:15 / B:15 / C:12、計42件。CにはHTMLのない012のJSONもあり、件数には含めない。Cのhandoffは11件時点の記録で、現物と一致しない。

| 担当 | 一覧 | 作業者の報告MD | 最終機械検証 |
| --- | --- | --- | --- |
| A | [HTML一覧](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/index.html) | [handoff.md](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/handoff.md) | 要確認（2項目） |
| B | [HTML一覧](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/index.html) | [handoff.md](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/handoff.md) | PASS |
| C | [HTML一覧](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/index.html) | [handoff.md](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/handoff.md) | 要確認（8項目） |

## 残る確認事項

A: ROLE-A-002のHTMLとJSONでタイトル・Statusが一致しない。

B: 機械検証PASS。世界観の意味、プレイ体験、ブラウザでの全件表示は別レビュー。

C: 003の代償項目不足、004の未解決参照記録不足、009のJSON構文不良、010の参照見出し不一致、manifest・進捗・実ファイルの不一致。014・015は未作成、012はJSONのみ。011はhandoffの完了一覧外にあるため完了扱いは未確認。

原文を保持し、設計内容や完了宣言を管理側で補正していない。最終検証の詳細は以下。

- [A検証JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/validation-A.json)
- [B検証JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/validation-B.json)
- [C検証JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/validation-C.json)

## 個別HTML

リンク先は収集スナップショット。正式な仕様ではなくIdea / Draft候補。

### ROLE A

| 候補 | HTML | 詳細JSON |
| --- | --- | --- |
| ROLE-A-001 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-001.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-001.json) |
| ROLE-A-002 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-002.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-002.json) |
| ROLE-A-003 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-003.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-003.json) |
| ROLE-A-004 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-004.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-004.json) |
| ROLE-A-005 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-005.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-005.json) |
| ROLE-A-006 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-006.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-006.json) |
| ROLE-A-007 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-007.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-007.json) |
| ROLE-A-008 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-008.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-008.json) |
| ROLE-A-009 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-009.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-009.json) |
| ROLE-A-010 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-010.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-010.json) |
| ROLE-A-011 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-011.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-011.json) |
| ROLE-A-012 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-012.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-012.json) |
| ROLE-A-013 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-013.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-013.json) |
| ROLE-A-014 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-014.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-014.json) |
| ROLE-A-015 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-015.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/A/ROLE-A-015.json) |

### ROLE B

| 候補 | HTML | 詳細JSON |
| --- | --- | --- |
| ROLE-B-001 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-001.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-001.json) |
| ROLE-B-002 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-002.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-002.json) |
| ROLE-B-003 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-003.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-003.json) |
| ROLE-B-004 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-004.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-004.json) |
| ROLE-B-005 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-005.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-005.json) |
| ROLE-B-006 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-006.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-006.json) |
| ROLE-B-007 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-007.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-007.json) |
| ROLE-B-008 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-008.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-008.json) |
| ROLE-B-009 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-009.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-009.json) |
| ROLE-B-010 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-010.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-010.json) |
| ROLE-B-011 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-011.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-011.json) |
| ROLE-B-012 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-012.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-012.json) |
| ROLE-B-013 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-013.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-013.json) |
| ROLE-B-014 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-014.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-014.json) |
| ROLE-B-015 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-015.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/B/ROLE-B-015.json) |

### ROLE C

| 候補 | HTML | 詳細JSON |
| --- | --- | --- |
| ROLE-C-001 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-001.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-001.json) |
| ROLE-C-002 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-002.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-002.json) |
| ROLE-C-003 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-003.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-003.json) |
| ROLE-C-004 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-004.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-004.json) |
| ROLE-C-005 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-005.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-005.json) |
| ROLE-C-006 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-006.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-006.json) |
| ROLE-C-007 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-007.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-007.json) |
| ROLE-C-008 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-008.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-008.json) |
| ROLE-C-009 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-009.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-009.json) |
| ROLE-C-010 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-010.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-010.json) |
| ROLE-C-011 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-011.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-011.json) |
| ROLE-C-013 | [開く](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-013.html) | [JSON](work/design-brainstorm/overnight-design-pilot-v1/runtime/continue-to-15/collected/C/ROLE-C-013.json) |

## 実行条件・資料

OpenCode / space-bunny-free、アカウントは既存設定、権限YOLO、期限なし。各担当は4マップ各3件＋共通3件。HTMLは案・仕組み・選択を簡潔に示し、整合性の詳細はJSONへ分離。

- [共通パック v0.2](work/design-brainstorm/overnight-design-pilot-v1/common-pack-v0.2/README.md)

このMDは一時的なリポジトリ直下の入口で、不要になったら削除できる。
