# ROLE=C handoff — CONTINUE_TO_15（11件保存時点で停止）

Status: Draft（実行側の記録。ゲーム仕様の採用記録ではない）

RUN_ID: `overnight-design-pilot-v1` ／ 担当: C（スキル）／ モード: `CONTINUE_TO_15`
出力先: `runtime/initial-only-no-deadline/roots/C/work/design-brainstorm/overnight-design-pilot-v1/C/`

## 1. 完了件数

15件には到達していない。11件を保存した。

| 候補ID | マップ | 分類 | 系統 | rank | 設計の核 |
| --- | --- | --- | --- | --- | --- |
| ROLE-C-001 巻き戻し地点 | 8/31 | マップ固有 | アクション | 1 | フェーズ切替の窓で前相の位置へ1回だけ戻り、戻ったフェーズは発動不能 |
| ROLE-C-002 刻みを読む | 8/31 | マップ固有 | 補助 | null | 残りの秒数とExposure倍率を本人に1度だけ読む。8/32では読めない |
| ROLE-C-003 水面の道 | 8/31 | マップ固有 | 探索 | null | 湖面を直進で渡る。渡行中は戦えず、足取りが記録される |
| ROLE-C-004 試聴の記録 | 廃TSUTAYA | マップ固有 | 探索 | null | 試聴を自分で止め、未閲覧1件だけ個人記録に残す |
| ROLE-C-005 一打の無音 | 廃TSUTAYA | マップ固有 | 攻撃 | null | 1打だけ店内の音と衝撃を送らない。命中も距離も通常どおり |
| ROLE-C-006 停波の隙間 | 廃TSUTAYA | マップ固有 | アクション | 2 | 停波ノイズのあいだだけ本人の観察の進みを止める |
| ROLE-C-007 弱みの印 | SEKIGAHARA | マップ固有 | 探索 | null | 戦闘中のうち弱い個体だけに本人へ印を出す |
| ROLE-C-008 一度だけ受け流す | SEKIGAHARA | マップ固有 | アクション | null | 被打の硬直を1回だけ殺す。無敵ではなく体が減る |
| ROLE-C-009 地形に紛れる | SEKIGAHARA | マップ固有 | 補助 | null | 地形に接して静止すると本人への提示だけが見えなくなる |
| ROLE-C-010 手を置いたまま | 研究所 | マップ固有 | 探索 | 1 | 器材に触れているあいだだけ個人状態が入り、離れると切れて戻っても再開しない |
| ROLE-C-013 息を揃える窓 | 全マップ共通 | 全マップ共通 | 補助 | null | 仲間との短期な連携窓。開始と終了が音として記録される |

未作成4件: 011、012、014、015。8/31、廃TSUTAYA、SEKIGAHARA は3件ずつ完成。研究所は010のみ、全マップ共通は013のみ。

HTML11件はすべて candidate-format v0.2 の簡潔形式（タイトル、候補ID、マップ、Idea、一文の案、2〜3箇条の仕組み、選択と代償、固有SVG1つ、図注、同IDのJSONへのリンク）。必須sectionは hypothesis と diagram の2つ。説明本文は図内文字を除いて250〜450字を目安にしている。JSONの項目をHTMLへ転記していない。

## 2. 表示確認

未実施。progress.json の visual_check.status は unavailable、checked_ids は空。

理由: 担当指示でブラウザを使用禁止とされているため、実ブラウザでの確認ができない。各HTMLは外部スクリプト、フォント、CDN、iframeを使っておらず、board.css は共通パックの templates を自分の出力先へコピーしたものだけを参照している。目視確認は管理側に依頼する。

## 3. 検証の状態

Python検証は管理側の担当。ROLE=Cでは実行していない。

- pack-only も stage progress も未実行。
- scripts/validate.py を読み根部まで確認し、必須sectionが hypothesis と diagram のみであること、manifestとファイル集合の一致、progressのcompleted_idsとstate、events.jsonlの各行、SVGのviewBoxとroleとaria-labelの要件を把握した上で記載を合わせた。機械検証の通過は保証していない。
- 003と008は書き出しの過程でJSONの括弧と末尾が壊れたため、ファイル全体の書き直しで解消した。003のlevelsと008の末尾は読み返して確認した。残り9件は全文を読み返していないため、管理側の検証が必要。

## 4. 参照

他担当への参照はすべて reserved_unresolved である。

| 参照先 | 種類 | 候補 |
| --- | --- | --- |
| ROLE-A-002 | optional_connection | 001、002 |
| ROLE-A-001 | optional_connection | 003 |
| ROLE-A-004 | optional_connection | 004、005、006 |
| ROLE-B-004 | optional_connection | 004 |
| ROLE-A-007 | optional_connection | 007 |
| ROLE-A-008 | optional_connection | 009 |
| ROLE-A-011 | optional_connection | 010 |
| ROLE-A-013 | optional_connection | 013 |
| ROLE-C-001 | optional_connection（draft_available） | 013 |
| ROLE-C-004 | optional_connection（draft_available） | 013 |

同一セッション内の C-001 と C-004 は draft_available とし、required_traits はそれぞれの provides_traits に一致させている。それ以外は予約枠のままで本文を読んでおらず、実現を仮定していない。peer-snapshots は配布されていない。ID未指定の接続要求は 001、002、003、005、006、007、008、010 が各1件、013 が2件。data_dependency の参照は行っていない。adoption_blocker はすべて false。

## 5. 世界観の留保

各候補で意図的に確定させなかった意味。

- 001: 前相の位置を参照できる理由、地図再構築後に何が残るか。
- 002: なぜ数字を読めるのか。8/32で読めない理由。
- 003: なぜ水面上を移動できるのか。水位と湖の由来。
- 004: 残った項目が店内側の記録なのか本人の記憶なのか。
- 005: 音の無い一打が何を意味するか。
- 006: なぜ停波のあいだだけ見えなくなるのか。
- 007: 印が何を意味するか。勢力の敵対関係には触れていない。
- 008: 受け流しという体づかいを誰がどうえたものかは説明しない。
- 009: なぜその場所でだけ見えなくなるのか。
- 010: 器材に触れることで何が得られるのか。博士の真意と装置の由来には触れない。

11件とも Player Anomaly の専用攻撃と固有帰還は扱っていない。Healで全Entityを鎮静、SHADEで全Entityを検知不能、cureでExposureを解除、という一般化も書いていない。007、008、009、010 は未実装マップに依存するか差し替え先の記録がないため requires_code を unknown とした。地図の配置は提案していない。

## 6. requires_code と試作コスト

- true: 001、002、003、004、005、006 の6件。
- unknown: 007、008、009、010 の4件。いずれも未実装マップに依存するか、差し替え先が記録されていないため必要性を判定できなかった。prototype_cost.band も同じ理由で 不明。

prototype_cost はゲーム内試作の見積もりであり、生成にかかった時間とは別の数値。

## 7. 所要時間

progress.json の started_at、ended_at、events.jsonl の全行の at は null。各行に理由ノートを記した。読み込み時間、生成時間、区切りごとの時間、総経過、待機時間、停止から再開の空白はすべて未計測。推測で埋めていない。usage の全項目も null。

書き出した文章に日本語として成立しない語が混入する事例が繰り返され、該当箇所の書き直しと再確認に多数回のやり直しを要した。編集操作が日本語文字列を含む場合に不定に失敗し、誤字を同じ操作で直せない場合もあった。これらは時間としては記録できていない。

## 8. 停止理由

外からの停止要求ではない。残り4件（011、012、014、015）を安全に書き出す余裕が確保できないため、破損ファイルを残さないための自主的な区切り保存を選んだ。予算、期限、同一エラー3回による停止ではない。主な原因はツールの編集操作の不安定さである。

## 9. 採用判断が必要な論点

判断はしない。論点を挙げる。

1. rank の偏り。具体値を持つのは 001 が1、006 が2、010 が1 の3件で、他8件は null。理由は各候補の rank_rationale にあるが、系統構成の整理として一括で決める方がよいかもしれない。
2. 系統の偏り。攻撃系は005のみ。移動と回避が多い。高ランクや高火力の代替は意図的に並べていない。
3. 003 と Trail の重複。003は湖面をスキルで渡る案だが、湖とAPARTMENTを結ぶTrailが未実装と記されている。造営で解くかスキルで解くかの判断が必要。候補の conflicts に記載。
4. 005 の音の受け皿。音の伝播と遮蔽、同期が未決定で、共通ディスパッチも新設しないと明記されている。差し替える場所を先に決める必要がある。
5. 006 の観察 differentials。停波ノイズの区間を他のシステムから使える形で通知できるかが未確認。共通観察システム自体も Draft である。
6. 007、009、010 の前提。SEKIGAHARAと研究所は未実装で、敵の思考と器材の実在を前提にできるか判断できていない。個人提示を先に試すか、個別実装の決定後に置くか。
7. 008 の硬直の発生箇所。ダメージと硬直の実装記録がなく、差し替え先が特定できない。
8. 010 の対象器材。判断018で定義された研究機材と同じものかどうかが決まっていない。候補の conflicts に記載。
9. 002 の数字の表示。認知アノマリーは既定HUDで答えを表示しない方針を持つ。共通HUDへ入れるか専用表示に留めるかの判断が必要。候補の conflicts に記載。
10. 未完成4件の設計。011、012、014、015 は未作成で、系統と作用の割り当ては決まっていない。SEKIGAHARAは007、008、009で探索、アクション、補助を使ったため、011と012には残りの系統がnatural。014と015は全マップ共通で地図に依存しない案がnatural。

## 10. 再開手順

1. 管理側が progress.json の state が stopped_partial、completed_ids が11件であることを確認する。
2. scripts/validate.py の pack-only、続いて role C の stage progress を実行する。
3. 003と008は再読していない。他aponの候補と合わせてJSONの括弧と末尾を重点的に見る。
4. 11件のHTMLをブラウザで実表示確認し、SVGとCSSが見えるかを確認する。visual_check を checked に更新できるなら checked_ids に11件を入れる。
5. 管理側の再開指示があった場合、残り4件（011、012、014、015）を作る。割り当ては第9節の10を参照。
6. 4件を保存したら manifest.json、index.html、progress.json を15件に更新し、stage final を実行する。
7. 時刻が取得できるようになったら events.jsonl の at を実測値で埋め、progress.json の started_at、ended_at、usage を実測値に置き換える。実測できないままなら null のまま残す。

## 11. 書き込み範囲

書いたのは指定された出力先 runtime/initial-only-no-deadline/roots/C/work/design-brainstorm/overnight-design-pilot-v1/C/ のみである。共通パック、正本 docs、src、tools、Studio、他担当の出力、以前のworkは読み取り以外で変更していない。Git操作、コミット、プッシュ、accepted化、実装の生成は行っていない。

試走時に書いた場所 work/design-brainstorm/overnight-design-pilot-v1/C/ には今回の成果物をコピーしていない。管理側がその内容を保持するかを確認する。