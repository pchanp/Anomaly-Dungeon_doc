# Happier / OpenCode：再開後の権限適用に関する修正案と再現手順

**Status: Draft（調査・修正提案。修正済みではない）**

作成日: 2026-10-04 JST。対象: ローカル Happier CLI 0.2.12 / 管理下 OpenCode 1.18.32 / `opencode/space-bunny-free`。

この資料は未送信。Happierのインストール済みCLI、アカウント設定、daemon、ゲームの正本MDは変更していない。設計候補の生成数は0件。元の終了期限は2026-10-04 12:00 JSTであり、この資料は再起動・期限延長の許可ではない。

## 報告用の要約

Happierで起動したOpenCodeセッションを `safe-yolo` で実行すると、初回のネイティブRead/Writeは許可待ちなしで成功した。同セッションを停止し `happier resume <ID>` で再開すると、同じOpenCodeセッションと会話履歴は維持されたが、ネイティブWriteが許可待ちになった。送信時のpermission overrideと `session set-permission-mode ... safe-yolo` を指定しても、今回の既存pendingは解消しなかった。

標準resumeからrunnerへ権限を継承する経路と、Happierの現在モードをOpenCodeのsession permissionへ同期する経路に問題がある可能性が高い。実行時の権限・timestampの内部値は未計測のため、原因の断定と修正完了の判断は避ける。

別問題として、呼び出し元の `HAPPIER_DAEMON_PENDING_FIRST_INPUT` が不正なJSONだと、標準resumeは `Pending first input handoff is malformed` で失敗する。子プロセスの環境からこの変数を除くと今回の再開エラーは解消した。権限問題と分けて扱う。

## 実測結果

| 確認 | 結果 |
| --- | --- |
| 初回ネイティブRead/Write | 成功。`output/probe.txt`にfixtureの値を書いた |
| 停止 | stop応答成功 |
| handoff環境変数対策後の標準resume | 成功。同じHappier ID / OpenCode ID |
| 再開後の会話記憶 | fixtureを再読せず値を記憶していた |
| 再開後のネイティブWrite | tool callは出たがpendingRequestsCount=1。ファイル未作成 |
| send override / set-permission-mode | 今回の既存pendingは未解消 |
| existing-session / resumeを手動で組み立てた起動 | missing session attach secret。運用案として採用しない |
| 最終状態 | active=false。テストの監視プロセスも終了 |

証拠: [result.json](result.json)、[permission-static-audit.json](permission-static-audit.json)、[調査記録](permission-resume-investigation.md)、[テスト概要](README.md)。テストファイルは [probe.txt](root/output/probe.txt)。`resumed.txt`は作成されていない。

## 再現手順

以下は手順例であり、この資料作成時には実行していない。再試験する際は新しい終了期限を決め、外側の停止監視を先に用意する。専用ディレクトリを使い、既存プロジェクト・セッションには触れない。

### 1. 最小fixtureを用意する

```sh
repro_root=$(mktemp -d /tmp/happier-opencode-permission-repro.XXXXXX)
mkdir "$repro_root/output"
printf '%s\n' 'READ_CHECK=violet-742' > "$repro_root/fixture.txt"
chmod 444 "$repro_root/fixture.txt"
printf '%s\n' '候補生成なし。Bash/task/MCP/外部directoryは禁止。ネイティブRead/Write/Editだけ使い、書き込みはoutput/のみ。' > "$repro_root/AGENTS.md"
```

fixtureのchmodと指示はOSの隔離を保証しない。技術的な書き込み隔離の試験は別項目。

### 2. 初回を明示モードで起動する

```sh
env -u HAPPIER_DAEMON_PENDING_FIRST_INPUT happier session create \
  --path "$repro_root" \
  --backend opencode \
  --model opencode/space-bunny-free \
  --auth default \
  --permission-mode safe-yolo \
  --transcript-storage persisted \
  --title 'OpenCode permission resume repro' \
  --prompt '候補生成なし。Bash/task/MCP/外部directoryは禁止。ネイティブReadでfixture.txtを読み、ネイティブWriteでoutput/probe.txtへその値を書いて終了してください。' \
  --json
```

応答の `data.session.id` を `repro_session_id` に保存する。完全なIDを使う。応答の取りこぼし時に無条件でcreateを再実行しない。

`probe.txt`が正しいこと、tool resultとtask_complete、pendingRequestsCount=0を確認する。active=trueはrunnerの稼働であり、生成中を意味するとは限らない。

```sh
happier session status "$repro_session_id" --live --json
happier session history "$repro_session_id" --limit 30 --format raw --include-meta --include-structured-payload --json
```

### 3. 停止して標準resumeする

```sh
happier session stop "$repro_session_id" --json
happier session status "$repro_session_id" --live --json
env -u HAPPIER_DAEMON_PENDING_FIRST_INPUT happier resume "$repro_session_id"
```

stop後のactive=false、resume後のactive=trueを確認。resumeはrunnerとして継続するため、次のsendは別ターミナルから実行する。元プロセスの環境やdaemon環境を変更しない。新規spawn時にdaemonが作る有効な初回入力handoffを削除しない。

### 4. 履歴を使うWriteを依頼する

```sh
happier session send "$repro_session_id" \
  'fixture.txtとprobe.txtを読み直さず、前の会話で読み取ったREAD_CHECKの値をoutput/resumed.txtへネイティブWriteで書いて終了してください。覚えていなければUNKNOWN。Bash/task/MCPは禁止。' \
  --permission-mode safe-yolo \
  --model opencode/space-bunny-free --json
happier session status "$repro_session_id" --live --json
```

今回の実測:値を記憶したWrite callは出たがpending=1、resumed.txtは未作成。単にモデルが応答しないケース、情報を忘れたケース、provider/API障害とは区別する。

### 5. モード変更と終了

```sh
happier session set-permission-mode "$repro_session_id" safe-yolo --json
happier session status "$repro_session_id" --live --json
happier session stop "$repro_session_id" --json
happier session status "$repro_session_id" --live --json
```

今回の実測ではモード変更後も既存pendingは残った。これは「次のturnも必ず失敗する」ことまで証明しない。待機のタイムアウトは停止確認にしない。既存pendingを全面許可で解消して再現を隠さない。最後は専用セッションの停止を確認する。

## 実装を確認する場所

配布物の識別子・行番号は0.2.12固有。元ソースのパスはこの環境では確認できていないため、リポジトリ上では以下の関数名を検索する。

| 関数・処理 | 配布物と確認点 |
| --- | --- |
| `handleResumeCommand` | `resume-BjVHk5Me.mjs:2031`。既存metadataは読むがhandler context argsに権限とtimestampを渡していない |
| `resolvePermissionModeSeedForAgentStart` | `applyRunnerMcpSessionContext-RoA_AsSg.mjs:4470`。explicit → inferred → account default → default |
| `runStandardAcpProvider`の起動seed | `runStandardAcpProvider-m6mPbv8R.mjs:954`。この呼び出しにはinferredPermissionModeを渡していない |
| `initializePermissionModeStateSync` | 同ファイル:393付近。既存metadataの後続同期は存在する。初期値とtimestampの比較を計測する必要がある |
| `resolveSessionPermissionRuleset` / `startOrLoad` | `api-C99s_10r.mjs:99317 / 102254`。resume時にOpenCode sessionUpdateでpermissionを適用 |
| `sendPromptWithMeta` | 同ファイル:102319。現在モードをprovider permissionへ同期するsessionUpdateがない |
| `ProviderEnforcedPermissionHandler` | `readOnlyFooterLines-ES56_drP.mjs:87`付近。safe-yoloだけでprovider由来のWrite askを承認しない |

「resumeの引数欠落」が単独で必ずdefaultを引き起こすとは未確定。既存metadataの復元、アカウントdefault、時刻比較が介在する。下記の計測で境界ごとの実値を確認する。

## 修正案

### A. 再開時の権限復元

標準resumeが作るattach情報・認証経路を維持する。既存metadataのpermission intentと更新時刻を既存の正規化関数で解釈し、runnerへ継承する。欠けた情報や不正値は現在のdefaultへ安全に戻す。

再開は以前の設定の復元であり、新しい権限変更として扱わない。古い設定にDate.now()を付けて後から入った制限を上書きしない。より新しい設定や明示された制限を尊重する。元がdefault/read-only/planならsafe-yoloへ自動昇格しない。

標準resumeのCLIは追加引数をhandlerへ転送していないため、`happier resume ID --permission-mode ...`を回避策として案内しない。既存の`--existing-session`だけを組み立てる回避策もattach secretを欠く。

### B. OpenCode側への権限同期

次のpromptをdispatchする前に、確定した現在のpermission rulesetをOpenCode sessionUpdateへ適用し、成功をawaitする。直前のモード変更を反映し、同じ設定はrevision/hashで不要な同期を省ける。

適用失敗時は新しいpromptを送らず、同期失敗として記録する。設定変更とdispatchを直列化し、古い更新の遅延完了で新しい設定を上書きしない。モードを許可側にも制限側にも同期する。

実行中の権限変更・既存pendingの扱いは別契約として決める。最小修正は次turnからの適用でもよいが、現在のpendingが残るならUI/CLIに明示する。制限へ変更した際に既存pendingを自動承認しない。無条件のyolo化やhost側Write自動承認でproviderポリシーを迂回しない。

### C. 初回handoff環境変数（独立した問題）

管理側の独立したresume subprocessではenvのコピーからHAPPIER_DAEMON_PENDING_FIRST_INPUTを除く。既存の管理スクリプトにはこの対策を入れた。Happier側を修正する場合はterminal resumeとdaemonの正規初回配送を区別し、不正なhandoffを全経路で黙って捨てない。初回指示の喪失・二重配送を防ぐテストを設ける。

## 追加する計測

秘密・本文・トークンを含めず、session ID、permission intent、設定の出所、revision/updatedAt、provider適用の成功失敗を記録する。

1. resumeが取得した元metadataのintent/timestamp。
2. runnerのinitial seed、起動同期前後のqueue intent/timestamp。
3. OpenCode startOrLoadに渡したpermission rulesetのrevision/hash。
4. mode変更を受けた時点と、次prompt前のprovider適用結果。
5. pendingの発生理由がprovider permissionかhost側の別承認か。

## 修正後の合格条件

| テスト | 期待結果 |
| --- | --- |
| safe-yoloで新規Read/Write | 成功、pendingなし |
| 停止→標準resume→同じ値をWrite | 同一セッション・履歴維持・Write成功 |
| default/read-only/planのresume | 元より権限を広げない |
| safe-yolo→read-only→次turnのWrite | provider側で禁止。書き込まない |
| default→safe-yolo→次turnのWrite | provider側へ適用後に成功 |
| 更新順序逆転・古いmetadata | 新しいrevisionの設定が勝つ |
| sessionUpdate失敗 | prompt未送信、同期失敗を明示 |
| 変更中に既存pendingあり | 定めた契約通り。無条件承認しない |
| handoff未設定 / 正規JSON / 不正JSON | 正規初回配送を壊さず、resume対策の対象を限定 |
| 最後のstop | active=false確認、専用runnerの終了確認 |

Bashがaskのままである点は別の運用条件。今回の設計候補ではネイティブRead/Write/Editを使い、Python検証は管理側が実行する構成を優先する。OSの書き込み隔離はこの修正で達成したと扱わない。
