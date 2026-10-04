# 制作トラブルシューティング

制作工程で再発し得る問題を蓄積します。各項目には `Symptom`、`Cause`、`Resolution`、`Status` を記載してください。原因が未確認の場合は推測で確定せず、`Unconfirmed（未確認）` とします。

## Rokoko Retargeting UIが表示されない

### Symptom

Rokoko Blender Pluginは有効だが、Retargeting UIを正常に利用できない。

### Cause

BlenderバージョンとRokoko Blender Pluginバージョンの互換性問題が疑われる。対象環境における厳密な組み合わせは未確定。

### Resolution

Current PipelineではRokoko Blender Pluginを必須依存としない。対象Blenderバージョンで動作確認できるリターゲット手段を使用し、Target ArmatureへのBakeとRoblox上の再生を検証する。

### Status

Known issue / Workaround available

### Related

- [判断記録002](../decisions/002-animation-retarget-tool.md)
- [Blenderリターゲット参照](../references/retarget.md)

## Studio MCPがツール0件で接続されない

### Symptom

`Roblox_Studio` MCP名前空間のツールが1件も公開されず、Roblox Studioを操作できない。`opencode.log` には `mcp connected server=Roblox_Studio tools=0` が記録され、`get_console_output` / `start_stop_play` / `script_read` / `list_roblox_studios` を呼び出せない。

### Cause

`Unconfirmed（未確認）`。2026-10-02の観測では、Studio本体は起動中（PID 54590）であり、`StudioMCP` バイナリも存在する。`StudioMCP` を単独起動してMCP stdioハンドシェイク（`Content-Length` フレーミング、`initialize` → `notifications/initialized` → `tools/list`、protocolVersion 2024-11-05 / 2025-06-18）を送っても30秒間 stdout / stderr ともに1バイトも出力されない。Studio側ログにもMCP関連の行が無い。2026-09-30 07:16〜13:22Zには同一設定で `tools=28` の接続が確立していたため、Studio側のブリッジ状態またはプロセス残留が原因である可能性はあるが、確証はない。

### Resolution

未確定。作業面の対応として、Studio操作が必要な検証は `Blocked` とし、推測で `Pass` にしない。接続状態、試行した手順、公開ツール数、`Output` の取得可否を [Studio検証チェックリスト](studio-verification-checklist.md) の「検証環境の記録」へ必ず残す。

2026-10-02に、Studio本体と残存`StudioMCP`プロセスの再起動が人間側で一度試行されたが、**復旧せず `tools=0` のまま**であった。同じ障害へ到達した場合は再起動を繰り返さないこと。opencode本体の再起動（セッションの作り直し）を先に試す。

Studio本体の再起動は未保存の編集を失う可能性があり、`Roblox_Studio` MCP設定の変更は接続障害の回避に不可欠である。いずれも権限外かつ破壊的な操作として、エージェントが勝手に試行せず人間へ委ねる。

### Status

Known issue / Workaround available（2026-10-03時点で解消済み。`Roblox_Studio` MCPはツール公開済みで接続していた。本記録は消さない。）

### Related

- [Studio検証チェックリスト](studio-verification-checklist.md)
- [開発ワークボード](../workboard.md)

## Studio MCPのstart_stop_playでClient数を指定できない

### Symptom

`start_stop_play` でPlayを開始しても1人（Play Solo）しか起動せず、「複数Client／Party Run」の検証を実施できない。複数Clientを要求する検証項目を `Blocked` にせざるを得ない。

### Cause

`start_stop_play` が `is_start` と `studio_id` のみを受け付ける設計である。**Client数やサーバーモード（Solo / Server / Server and Players）の指定引数が存在しない。** 実行時はStudio側の現在のテスト設定がそのまま適用される。Studioのテスト参加者人数はStudioのPlayボタン横のUIにのみ存在し、MCPからは変更できない。`roblox_studio` MCPはResources / ResourceTemplatesも公開していない。Roblox APIにサーバー側で `Player` インスタンスを生成する方法が無いため、1人セッションから2人目を湧らせることもできない。

### Resolution

複数Clientを要する検証は、StudioのPlayテスト設定を「Start Server and Players / 2人以上」に変更したうえで人がPlayを開始する手順が必要である。エージェント側では人数を変更できないため、チェックリストの該当項目を `Blocked` として記録し、検証できなかった項目を明示する。推測で `Pass` にしない。

人数に依存しない項目（受付開始、受付表示、30秒締切、マップ抽選、受付からの離脱、マップ破棄と次の受付）は1Clientでも検証できるため、Blockedにせず実施する。

なお2026-10-03の観測では、`HoldDuration=0.35` のProximityPromptでも `keyDown` / `wait` / `keyUp` の合成入力で実際に発火した。したがって、人数だけが障害であれば残りの項目は入力で検証できる。入力が届かない場合は [Studio MCPの合成入力と画面取得がセッション途中に途絶する](#studio-mcpの合成入力と画面取得がセッション途中に途絶する) を参照。

### Status

Known limitation / Human action required

### Related

- [Studio検証チェックリスト](studio-verification-checklist.md)
- [開発ワークボード](../workboard.md)

## Studio MCPの合成入力と画面取得がセッション途中に途絶する

### Symptom

Play開始直後は `user_keyboard_input` がProximityPromptを発火させるが、一定時間が経つと `E` や `LeftShift` が一切効かなくなる。同時に `screen_capture` が `MCP error -32001: Request timed out` を返し、Playを停止・再起動しても回復しない。`user_mouse_input` も同じくタイムアウトする。

### Cause

`Unconfirmed（未確認）`。2026-10-03の観測では、`execute_luau`（Server / Client / Edit）、`character_navigation`、`get_console_output`、`get_studio_state` は終始応答したため、MCP接続自体やStudioのPlayセッションは生きている。失われているのは入力フォーカスとビューポート画像取得の経路だけである。ProximityPromptの発火を画面表示側からも確認できなかった。Studioウィンドウが入力フォーカスを失った状態、および `screen_capture` がビューポート読取に依存することが待機終了の原因である可能性はあるが、未確認である。Roblox側・OS側のどちらの問題かは特定できていない。

### Resolution

- 入力が途絶えた場合は、残り時間内で **画面確認を要さない検証**（サーバー側の属性・`BillboardGui` の `TextLabel`・生成ワールドの `descendants` 数）を優先して実施する。ProximityPromptの操作が必要で画面確認も要る項目は、その時点で `Blocked` とする。
- クライアント側の通知は `AnomalyNotice` の `FireClient` のみでサーバーに記録されない（`RunService.tell`）。そのため通知文の観測には画面またはクライアント側リスナが要る。クライアント側から `execute_luau` でイベントを購読しても、作成したインスタンスは数コマンドで削除される場合があり（2026-10-03に観測）、恒久的な計測装置としては使えない。
- 画面確認を要する項目は、入力と `screen_capture` が生きている初めにまとめて取得する。
- Playの停止・再起動で回復しないことを観測した場合は、以降は再起動を繰り返さず、残作業を `Blocked` として記録する。Studio本体の再起動は破壊的なため、権限外として人間へ委ねる。

### Status

Known issue / Workaround available（一部項目のみ回避可）

### Related

- [Studio検証チェックリスト](studio-verification-checklist.md)
- [開発ワークボード](../workboard.md)
