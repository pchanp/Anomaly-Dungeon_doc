# Icon Gallery

**Status: Implemented（実装済み・Prototype）**

アイコン生成候補を携帯から確認するローカルツール。ゲーム本体や制作の標準工程とは別の試作用途です。Python 3.9以上の標準ライブラリだけで動きます。macOSではサムネイル作成に標準の `sips` を利用し、それ以外では元画像を表示します。

## 作業場所と3並走

[`work/icon-generation/`](../../work/icon-generation/) の `A/`、`B/`、`C/` をOpenCodeの各セッションに割り当てます。それぞれに `requests/` と `images/` があり、共通の指示は同フォルダの `AGENTS.md` にあります。

- OpenCodeの3セッションは、仕様確認・プロンプト作成・生成依頼を並行できます。
- Draw Thingsへは共通ワーカーが1枚ずつ送ります。各担当が直接GPUへ3同時投入する構成ではありません。
- OpenCodeのモデルは、開始時にプロバイダの表示で無料であることを確認して選択してください。無料モデル名・期間・利用上限は固定しません。有料モデルへの自動切替はありません。このツールはLLMを呼び出しません。
- 起動済みのOpenCodeセッションやモデル設定を、このツールは変更しません。

### Happier経由の接続確認（2026-10-14）

SHADEの初回では、Happier `0.2.16` のサーバー方式で指定した無料モデルが実際の応答に反映されず、別の既定モデルへの接続エラーになりました。ユーザーがACP方式へ変更し、管理インストールのOpenCode `1.18.32`、明示した `opencode/longcat-2.5-preview-free`、権限モード `default` で3担当が完了しています。実際の応答レコードのprovider/modelも確認しました。

同じモデルをACPの `read_only` で試すと、当日は `OpenCode's free tier can only be used from within OpenCode` が返りました。無料枠の同種のエラーは[OpenCode公式リポジトリの報告](https://github.com/anomalyco/opencode/issues/49756)にもあります。モデル表示だけで成功と扱わず、接続確認と実際の応答を検証してください。これは試したバージョンでの互換性記録であり、常にACPが必要という標準工程の決定ではありません。

以下のコマンドはすべてリポジトリのルートから実行します。

## ギャラリーを開く

```sh
python3 tools/icon-gallery/server.py
```

表示された `http://127.0.0.1:8765/#token=...` をMacで開きます。画像は5秒ごとに再走査されます。PNG/JPG/WebPを `A/images/`、`B/images/`、`C/images/` のいずれかへ保存するだけでも一覧に載ります。サブフォルダも対象です。保存中の画像は `.tmp` 拡張子にし、完成後にrenameしてください。

同じWi-Fiの携帯から見る場合は `--host 0.0.0.0` を付け、MacのLAN IPに同じポートとキーを指定します。外出先用の接続ではこのオプションは不要です。

画面では担当・レビュー状態・名前・プロンプトで絞り込み、拡大、32/48/64pxの縮小表示、元画像の保存ができます。「採用候補」「修正したい」「見送り」とメモはMac側のSQLiteへ保存され、携帯とMacで共有します。これらは制作候補のレビューであり、ゲームへの採用・導入を決定する操作ではありません。

URLに `?q=Fox20` のような検索語を付けると、その試作だけを開けます。アクセスキーの `#token=...` は検索語の後ろに付けます。ログイン後も検索語は残り、キーだけがアドレスから取り除かれます。

生成情報を手動追加する場合は、画像の隣に `example.png.json` のようなサイドカーを置きます。

```json
{
  "title": "確認用の名称",
  "target_id": "既存のシステムIDがある場合だけ記載",
  "prompt": "実際に使用したプロンプト",
  "negative_prompt": "",
  "model": "実際に使用したモデルファイル名",
  "seed": 12345,
  "source_docs": ["参照した既存ドキュメントのパス"]
}
```

## 外出先から開く

追加依存は **Cloudflare公式 `cloudflared`** です。目的は、Mac上のギャラリーへ一時HTTPS URLで接続することです。Draw ThingsのAPIやリポジトリ全体は転送しません。MacのCPUに合う公式バイナリを使い、PATHまたは `work/icon-generation/.runtime/bin/cloudflared` に置きます。代替は、同じWi-Fi内での直接閲覧、または既存のTailscale経由での接続です。

```sh
python3 tools/icon-gallery/share.py
```

`cloudflared` の場所を指定する場合:

```sh
python3 tools/icon-gallery/share.py --cloudflared /absolute/path/to/cloudflared
```

表示されたアクセスキー付きリンクを携帯で開きます。キーはURLの `#` 以降に置き、ログイン後にブラウザのアドレスから取り除きます。画像、プロンプト、レビュー、生成キューには認証が必要です。キーとレビューDBは `.runtime/` にあり、Git対象外です。キー付きリンクは閲覧権限を持つため、共有先に注意してください。

Macが起動していてネットワークへ接続している間だけ利用できます。Macのスリープ中は接続できません。Quick Tunnelには稼働保証がなく、再起動するとURLが変わります。Ctrl+Cでギャラリーとトンネルを一緒に停止します。固定URL・常時稼働・自動起動は未実装です。

現在のリンクは `work/icon-generation/.runtime/share.json` に保存されます。外部接続のログは同じフォルダの `tunnel.log` です。

## Draw Thingsへ生成を依頼する

Draw Thingsの「設定」→「すべて」→「APIサーバー」で、プロトコルを **HTTP** にして有効化します。表示された **IPを `127.0.0.1（ローカルホストのみ）`** にし、ポートを7860にします。gRPC用の7859番とは別です。HTTPを有効化するとIPとポートの項目が表示されます。

```sh
python3 tools/icon-gallery/jobs.py check --url http://127.0.0.1:7860
```

導入済みのSDXLモデルを指定し、[`request.example.json`](request.example.json) のプレースホルダーを実際の対象・プロンプトに置き換えて、担当の `requests/` に保存します。標準の設定は試作用であり、ゲームで使うアイコンサイズや画風を確定するものではありません。

```sh
python3 tools/icon-gallery/jobs.py enqueue --lane A --file work/icon-generation/A/requests/icon-001.json
python3 tools/icon-gallery/jobs.py work --url http://127.0.0.1:7860
```

キュー追加は複数セッションから同時に行えます。ワーカーは1個だけ起動します。二重起動はロックで防止します。キュー・結果はSQLiteに保存され、完了すると担当の `images/` にPNGと生成条件のJSONを原子的に保存します。Seedが `-1` または未指定なら、キュー投入時に乱数を確定して記録します。「ゼロ・ネガティブプロンプト」はリクエストで無効化するため、Draw Thingsの画面設定にかかわらず、依頼のnegative promptが使用されます。

依頼JSONに任意の `clip_skip`（1〜23の整数）を指定すると、その値をDraw Thingsへ送り、サイドカーにも保存します。省略した既存の依頼はアプリ設定を継承します。試作ごとに固定したい場合は明示してください。

構図の参考画像を使う場合は `mode: "img2img"`、`init_image: "試作名/references/参考画像.png"`、`denoising_strength: 0.55` を依頼JSONに追加します。初期画像は作業領域の `references/` または担当の `images/` にあるPNGとし、幅・高さを生成サイズに合わせてください。パスの脱出とシンボリックリンクは拒否します。省略時は従来どおりtxt2imgです。

待機中の依頼を修正する場合は、SeedとジョブIDを保つ `amend` を利用します。生成中・完了・結果不明のジョブは変更しません。

```sh
python3 tools/icon-gallery/jobs.py amend --id A-実際のジョブID --file work/icon-generation/A/requests/修正版.json
```

```sh
python3 tools/icon-gallery/jobs.py list
python3 tools/icon-gallery/jobs.py work --once
python3 tools/icon-gallery/jobs.py retry --id A-実際のジョブID
```

HTTP検証エラーは `failed`、タイムアウトや中断等は `uncertain` とします。結果が不明なときはワーカーを止め、残りのキューを待機状態で保持します。Draw Things側で処理が終わったかを確認してから `retry` してください。画像保存後に中断したジョブは、同じジョブIDとSeedのPNGがあれば再生成せず完了へ戻します。異常終了で `running` が残った場合は、ワーカー停止・Draw Things側の終了を確認し、DBを直接書き換えず、下記の `recover` を利用します。

```sh
python3 tools/icon-gallery/jobs.py recover --id A-実際のジョブID
```

`recover` は `running` を `uncertain` に変更するだけです。生成を再投入する操作ではありません。

## 検証と制約

```sh
python3 -m unittest discover -s tools/icon-gallery -p 'test_*.py' -v
```

- API認証・レビュー永続化・パス制限・並行キュー投入・Draw Things互換の模擬HTTP APIを使った3担当の生成経路を検証します。
- 実際のDraw Thingsによる生成、実機iPhone Safari、外出先の携帯回線での確認は、それぞれ別の確認です。模擬APIの成功をSDXL実生成の成功とは扱いません。
- 2026-10-14の[SHADE初回試作](../../work/icon-generation/shade-20261014/README.md)では、実際のSDXL生成5枚、PNG内部の生成条件との一致、外部HTTPS経由での認証・元画像5枚の同一性を確認しました。MacのSafariで一覧・拡大・担当別絞り込みを確認しています。図柄には構図のずれがあり、意匠は要調整です。実機iPhone・携帯回線の確認は含みません。
- PNG内の生成メタデータの自動抽出はありません。生成ワーカーのサイドカー、または手動のサイドカーを使います。
- 同じ画像へ同時にレビューを書いた場合は後から保存した内容を採用します。世代管理はありません。
- ワーカーは1回のリクエストにつき1枚のSDXL txt2imgまたは、PNGの参考画像を使うimg2imgです。LoRA・ControlNet・Refiner・透過処理・Robloxへの自動Importは含みません。
- 本ツールは保存前の画像形式をPNGとして検証しますが、画の品質・対象の仕様一致・利用許諾は人が確認します。

## 一次資料

- [Draw Thingsの公式HTTP API実装](https://github.com/drawthingsai/draw-things-community/blob/main/Libraries/HTTPAPIServer/Sources/HTTPAPIServer.swift)
- [Draw Thingsの公式生成パラメータ](https://github.com/drawthingsai/draw-things-community/blob/main/Libraries/Invocation/Sources/Parameters.swift)
- [Cloudflare Quick Tunnels](https://developers.cloudflare.com/tunnel/get-started/quick-tunnels/)
- [OpenCodeのモデル選択](https://opencode.ai/docs/models/)
