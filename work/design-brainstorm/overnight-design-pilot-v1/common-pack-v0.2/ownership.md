# 書き込み境界と配布

**Status: Draft（実行前に権限設定を確認する運用契約）**

3セッションは別worktreeを推奨する。共有rootの場合も、下記の自分の担当フォルダだけに書く。参照MDは共通パックのsnapshotを使う。

| 担当 | 自分のworktree rootからの許可出力先 |
| --- | --- |
| A | `work/design-brainstorm/overnight-design-pilot-v1/A/` |
| B | `work/design-brainstorm/overnight-design-pilot-v1/B/` |
| C | `work/design-brainstorm/overnight-design-pilot-v1/C/` |

許可操作は候補HTML/JSON、一覧、manifest、CSS、進捗、ログ、handoff、表示確認画像の作成・修正だけ。テンプレートのCSSは自分の出力先へコピーして使う。

禁止対象は共通パック、正本 `docs/`、`src/`、`tools/`、AGENTS.md、README.md、Studio、他担当の出力、以前のwork、accepted状態。Git commit / push / reset / checkout / clean、worktreeの作成・削除、他セッションの起動・停止も夜間担当の仕事に含めない。

他担当の完成済みJSON・manifestは、管理側が任意に `peer-snapshots/` として共通パックの外へ読み取り専用配布する。自分のworktreeにない相手ファイルを探すため、別セッションの作業rootへ勝手にアクセスしない。peer配布がなければ予約IDとunresolved_refsだけで進める。

未完成の相手案へ要求を出しても、予約先の本文は自分で作らない。相手へ要求を伝える方法は管理側が決める。今回のパックは自動通信しない。

指示と別worktreeだけでは書き込み禁止を技術的に保証できない。実行管理側が配布先をread-onlyにできるか、担当rootだけへ書き込みを許せるか確認する。確認不能なら、その制約を記録して開始前後の差分を点検する。今回のパック作成では既存フォルダの権限を変更していない。

パックは作成後にpack-integrity.jsonで固定する。管理側が更新する必要がある場合は全セッション停止中に版を上げ、配布とハッシュを更新する。生成担当はハッシュ不一致を独自に修正せず停止してhandoffへ記録する。
