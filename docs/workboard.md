# 開発ワークボード

**Status: Draft（運用開始前）**
**更新日: 2026-10-03**

## 目的

この文書は、開発中に人間が次に判断・確認すべき作業を一箇所で見るための実行キューである。ゲーム仕様、実装状況、判断理由、再発する障害の正本にはしない。

- 仕様・未決定事項の正本は `docs/world/`、`docs/systems/`、`docs/anomalies/` に置く。
- 採否と理由は `docs/decisions/` に置く。
- 実装優先順位と依存関係は [未実装機能の優先順位](systems/implementation-priorities.md) に置く。
- 再発する制作上の障害は [制作トラブルシューティング](production/troubleshooting.md) に置く。

本書には、上記の資料を実行可能な作業へ切り出したものだけを置く。アイデア段階のマップや、判断材料が不足した世界観上の案は `Parked` として扱い、実行キューへ混ぜない。

## 状態

| 状態 | 意味 | 次に動く人 |
| --- | --- | --- |
| `Inbox` | 発見済みだが、範囲・優先度・正本が未整理 | 人間またはCodex |
| `Needs Human` | 仕様、優先順位、権限、費用などの判断が不足 | 人間 |
| `Ready` | 対象と完了条件が揃い、作業指示を生成できる | 担当エージェント |
| `In Progress` | 実行中。担当セッションと範囲を明記する | 担当エージェント |
| `Verify in Studio` | Git側の変更または設計は揃ったが、実プレースでの確認が未完了 | 人間またはStudio操作担当 |
| `Done` | 完了条件を満たし、正本へ結果を反映済み | なし |
| `Parked` | 価値はあるが、現時点では実行しない | 人間 |

`Ready` の項目だけをエージェントへの作業指示へ展開する。`Needs Human` を自動で実装へ進めない。

## 初期実行キュー

### P0: 実装・Studio検証

- [ ] **最小Runの複数Client検証**
  - 状態: `Blocked`（2026-10-02）
  - 担当: Studio操作担当（要人間）
  - 実施記録（2026-10-02）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「最小Run: 複数Client／Party Run」全7項目が未確認。`current-implementation.md` の既知未確認事項「複数人での挙動は未確認」はそのまま残る。コードは読み取りのみで変更していない。
    - OutputのError・Warning: なし（Studio未起動のため取得していない）
    - 残件と反映先: 全7項目の実プレース確認。`DEBUG 強制締切`プロンプトは `current-implementation.md` に「未配置で未確認」と記録があり、着手前に配置確認が必要。
  - 実施記録（2026-10-02・2回目）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションでもStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: 「複数Client／Party Run」全7項目が未確認のまま。`StudioMCP` は`opencode.json`に設定済みでバイナリも存在するが、2026-10-02T01:05Zの接続は `tools=0`、本セッション（01:56Z開始）には接続記録自体が無い。`StudioMCP` への直接stdioハンドシェイク（protocolVersion 2024-11-05 / 2025-06-18）も30秒間応答なし。`list_roblox_studios` が使えないためプレースの特定すらできていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照）
    - 残件と反映先: 全7項目。接続障害の詳細は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「検証環境の記録」にある。
  - 実施記録（2026-10-03・3回目）:
    - 日付: 2026-10-03
    - 対象コミット: `57e2c7a`（HEAD。`docs/` のみ）。**`src/` を最後に変更したコミットは `c74a276`**。従来の記録にある `b316d14` は `src/` を変更していないdocsコミットであり訂正が必要。
    - Studioプレースへ反映した内容: なし。**ただしプレース内7モジュール（`LobbyConfig` / `RunConfig` / `MapDrawConfig` / `PartyService` / `LobbyService` / `RunService` / `MapDrawService`）が `src/` とバイト一致することをlength・バイト和・位置重み付き和で照合した。** プレースは既に `c74a276` までを含む。同期操作自体は行っていない。
    - テスト環境: Play Solo（`start_stop_play`）。2回起動し、2回目は入力経路の回復を試すための再起動。
    - 参加Client数: **1**（目標2以上）
    - 実施者: 担当エージェント（Studio MCP経由。`tools>0` で接続済み）
    - 結果: **`Blocked`（項目1・2・4・5・6）／`Pass`（項目3・7）**
    - 観察事項:
      - 項目3「受付中にフィールド外へ出たプレイヤーが残らない」は `Pass`。`RunState=RECRUITING` 中にフィールド外へ出ると `RunState=IDLE`、`LobbyState=ENTRANCE`、参加者 `0 / 5`、看板「受付していません」へ戻り、次の受付を開始できた。
      - 項目7「全員終了後に生成マップが破棄され次のRunが開始できる」は条件付き `Pass`。唯一の参加者が終了すると `workspace.AnomalyDungeon` が消滅し `RunState=IDLE` へ戻り、再入域で新しい受付（30秒）が始まった。**ただし終了経路はハーネスによる落下死亡で、成功帰還・依頼未達帰還での確認はできていない。**
      - 項目4「途中参加拒否」は1Clientでは成立しない。唯一の参加者は常に `InDungeon=true` で、入口ロビーへ移動すると `RunService.Tick` の `KillY` 判定で死亡する（実際に確認）。進行中Runに居ないClientが必要。
      - 項目5「`DEBUG 強制締切`」は `Blocked`。Proンプト自体は配置済みだが（`Workspace.DungeonEntranceLobby.ForceClose`、`ActionText="受付を強制締切する"`、`ObjectText="DEBUG 強制締切"`、Editモードには無く `LobbyService` が実行時生成）、`FORCE_CLOSE` 分岐を起動できなかった。
      - **ワークボードの「`DEBUG 強制締切` プロンプトは未配置」という前提は誤りだった。** 実行時生成のため手動配置は不要。`current-implementation.md` の「未配置で未確認」も訂正してよい。
      - 1Clientでも確認できた付随事項: 受付開始（`RunState=RECRUITING` / `LobbyState=PARTY`）、参加者数と残り秒数の表示（フィールド看板・`EntranceBoard`）、30秒満了での `DEPARTING` → `ACTIVE`、Map抽選（1回目 `TSUTAYA` / 2回目 `AUGUST_31`、毎回別seed）、`Room` の実際の部屋名への更新。
      - `RunState` 属性はプレイヤー属性ではなく **`ReplicatedStorage.AnomalyState`（`Folder`）の属性**である。`current-implementation.md` の `AnomalyState:RunState` はこのパスを指す。
      - 死亡でRun終了した直後、キャラクタは都市ロビー（`-1600, 6.1, 50`）にいるのに `LobbyState` が `CITY` ではなく `ENTRANCE` だった。下記「未確認の論点」と同一の論点。
    - OutputのError・Warning: **ゲームのScript Error / Warningは0件**。Outputに残ったエラー2件は担当エージェントの `execute_luau` 診断スクリプトの失敗（`KeyboardEnabled is not a valid member of ProximityPrompt`、`attempt to index nil with '__keyProbe'`）であり、ゲームの不具合ではない。
    - 残件と反映先: 項目1・2・4・5・6の5項目。`current-implementation.md` の「複数人での挙動は未確認」は、人数上限・切断・途中参加・強制締切が未確認のまま残る。ツール障害は [制作トラブルシューティング](production/troubleshooting.md) へ記載。
  - Blocker理由: 複数Clientを起動できないこと。`start_stop_play` は `is_start` と `studio_id` のみを受け付け、Client数やサーバーモードの指定引数が存在しない。Studioの「Start Server and Players」の人数設定はStudioのUIにのみありMCPから変更できない（`roblox_studio` MCPはResourcesも公開していない）。Roblox APIにサーバー側での `Player` 生成方法が無いため、1人セッションから2人目を湧かせることも不可能。加えて、合成キーボード入力と `screen_capture` がセッション途中に途絶し、`DEBUG 強制締切` のProximityPromptを操作できなかった。
  - 次アクション: 人間がStudioのPlayテスト設定を「Start Server and Players / 2人以上」に変更したうえでPlayを起動する。2Clientで受付先着順と途中参加拒否、6Clientで上限5人、2Clientで切断を実行する。`DEBUG 強制締切` は受付開始直後にプロンプトを操作し、30秒を待たずに出発することと参加者だけが出発することを確認する。
  - 完了条件: [Studio検証チェックリスト](production/studio-verification-checklist.md) の「複数Client／Party Run」結果を記録し、不具合は本書またはトラブルシューティングへ切り出す。
  - 未確認の論点（2026-10-03追加）:
    - Runが死亡で終わった直後に、キャラクタは都市ロビーにいるのに `LobbyState` が `ENTRANCE` になる。`RunService.character()` の遅延 `lobby.SendToCity`（`CITY`）と、`PartyService` の0.25秒周期 `remove()`（`ENTRANCE`）の順序の競合が疑われる。都市ロビー滞在中に `ENTRANCE` が残る影響範囲は確認していない。**論点と判断候補は [020: Run終了後のLobbyStateと物理位置の同期](decisions/020-lobby-state-authority-and-physical-location.md) に記録した（判断未採用・要人間判断）。**
    - 影響は主として `RunController` の目的表示に限られ、受付ループは `LobbyState` ではなく `ReplicatedStorage.AnomalyState.RunState` を分岐条件にしているため受付機構は崩れない。
  - 正本: [現在の実装状況](systems/current-implementation.md)、[最小Runの範囲](decisions/005-minimum-lobby-run-scope.md)

- [ ] **リザルトUIの実表示検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当
  - 実施記録:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「リザルト／Inventory」全5項目が未確認。`src/` の読み取りのみで、サーバー送信値（`RunService.Finish`）とクライアント描画（`RunResultController`）の対応は静的に確認したにとどまる。コードは変更していない。
    - OutputのError・Warning: なし（Studio未起動のため取得していない）
    - 残件と反映先: 全5項目の実プレース確認。判断を要する論点は下記「未確認の論点」。
  - 実施記録（2026-10-02・2回目）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションでもStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: 「リザルト／Inventory」全5項目が未確認のまま。Studio MCPは2026-10-02T01:05Zの接続で `tools=0`、本セッション（01:56Z開始）には接続記録が無く、`StudioMCP` の直接stdioハンドシェイクも30秒間応答なし。下記「未確認の論点」の前提となる画面確認は開始できておらず、論点の解消には至っていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照）
    - 残件と反映先: 全5項目と下記「未確認の論点」。接続障害の詳細は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「検証環境の記録」にある。
  - Blocker理由: Studio MCPがツール0件で接続できず、Play／複数Clientを起動できない。Studio操作可能なセッションまたは人間が必要。
  - 未確認の論点（Studio表示前に仕様判断を要する可能性）:
    - 死亡失敗時、`RunResultController` は `ResetOnSpawn=false` なのでリザルト画面は保持される。一方サーバー側は `CharacterAdded` の `character()` で `M.Reset(p)` と `lobby.SendToCity(p)` を実行する（`RunService.luau:239-241`）。このため「死亡リザルト表示中も都市ロビーへ移動済みの状態」になる可能性がある。死亡リザルトを保持したいか、それとも成功時のみResultへ留めるwantは未定義。`LobbyState=RESULT` と物理位置のどちらを優先するかの判断が必要。
    - 失敗時の `Gained` / `Lost` は `Inventory.Settle(p, success)` の実装に依存する。Secure Slotのみ残す仕様が実装と一致するかはStudio未確認。
  - 再現手順（Studio操作担当が実行）:
    1. `src/` をStudioプレースへ反映し、反映経路と対象コミットを記録する。
    2. Play Soloで都市ロビーへ入り、`DUNGEON ENTRANCE` で入口ロビー、`PartyField` に入る。
    3. 成功経路: Map条件を解除して出口ポータルから帰還する。リザルト画面で獲得物・Quest達成状況・Credits変化・インベントリ／Secure枠表示を確認する。
    4. 失敗経路: Run中に死亡させる（落下 或 泉の毒）。死亡直後のリザルト画面、喪失物表示、画面保持と都市ロビー位置を確認する。
    5. いずれの画面でも「都市ロビーへ戻る」を押し、`LobbyState` が `CITY` へ戻り次の受付_buffを開始できることをOutputと 属性で確認する。
    6. リザルト表示中にスキルとDashを試み、実行されないことを確認する。
    7. 空の獲得物・喪失物が「なし」と表示されることを確認する。
  - 完了条件: [Studio検証チェックリスト](production/studio-verification-checklist.md) の「リザルト／Inventory」5項目にPass／Failを記録し、不具合は本書またはトラブルシューティングへ切り出す。
  - 正本: [現在の実装状況](systems/current-implementation.md)、[最小Runの範囲](decisions/005-minimum-lobby-run-scope.md)

- [ ] **8月31日景観変更のStudio検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当（要人間）
  - 実施記録（2026-10-02）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「8月31日: 景観・フェーズ」全5項目が未確認。`008` の「検証が必要な事項」5項目も未確認のまま。DAY／EVENING／NIGHT／AUG_32の遷移確認は実プレースを起動できないため着手できていない。`StudioMCP` は2026-10-02T01:05Zの接続で `tools=0`、本セッション（01:56Z開始）には接続記録が無く、直接stdioハンドシェイク（protocolVersion 2024-11-05 / 2025-06-18）も30秒間応答なし。`list_roblox_studios` が使えないため、Gitの`src/`とStudioプレースの反映関係の確認にも着手できていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照。ゼロであることは意味しない）
    - 残件と反映先: 全5項目。復旧手順は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「復旧後に必要な手順」を参照。
  - 備考: 本項目には本セッションのほかに実施記録が無い。上記が最初の記録である。
  - Blocker理由: Studio MCPがツール0件で接続できず、Playを起動できない。Gitソースとプレースの反映関係の確認にもStudio操作を要する。Studio再起動は破壊的な操作のため、勝手に試行せず人間に委ねる。
  - 次アクション: Trail、Prompt、カメラ、移動、8/32遷移、負荷とStreamingを実プレースで確認する。
  - 完了条件: [008](decisions/008-august-31-landscape-composition.md) の検証事項を記録し、GitソースとStudioプレースの反映関係を確認する。
  - 正本: [008: 8月31日の景観構成](decisions/008-august-31-landscape-composition.md)

- [ ] **TSUTAYA「閉店直後のアーカイブ」改修のStudio検証**
  - 状態: `Verify in Studio`
  - 担当: Studio操作担当（要人間）
  - 実施記録（2026-10-02）:
    - 日付: 2026-10-02
    - 対象コミット: `b316d14`
    - Studioプレースへ反映した内容: なし。本セッションではStudioを操作していない。
    - テスト環境: 実行せず
    - 参加Client数: 0
    - 実施者: 担当エージェント（Studio操作権限なし）
    - 結果: `Blocked`
    - 観察事項: チェックリストの「TSUTAYA: 閉店直後のアーカイブ」全5項目が未確認。`009` の「検証が必要な事項」5項目も未確認のまま。棚追加のPart数・PointLight数・負荷は実プレースを起動できないため計測できていない。`StudioMCP` は2026-10-02T01:05Zの接続で `tools=0`、本セッション（01:56Z開始）には接続記録が無く、直接stdioハンドシェイク（protocolVersion 2024-11-05 / 2025-06-18）も30秒間応答なし。Archive Shelf／CRT／試聴／出口端末の操作可否確認にも着手できていない。推測でPassにはしていない。
    - OutputのError・Warning: 取得不能（`get_console_output` 利用不可、Output画面未参照。ゼロであることは意味しない）
    - 残件と反映先: 全5項目。復旧手順は [Studio検証チェックリスト](production/studio-verification-checklist.md) の「復旧後に必要な手順」を参照。
  - 備考: 本項目には本セッションのほかに実施記録が無い。上記が最初の記録である。
  - Blocker理由: Studio MCPがツール0件で接続できず、Playを起動できない。Gitソースとプレースの反映関係の確認にもStudio操作を要する。Studio再起動は破壊的な操作のため、勝手に試行せず人間に委ねる。
  - 次アクション: 背表紙、小物、照明が通路、Prompt、Raycast、移動、負荷を阻害しないか確認する。
  - 完了条件: [009](decisions/009-tsutaya-closing-time-archive.md) の検証事項を記録し、必要なら改修案を `Inbox` として追加する。
  - 正本: [009: TSUTAYAを「閉店直後のアーカイブ」として再構成する](decisions/009-tsutaya-closing-time-archive.md)

### P1: 最小Runを継続可能なゲームへつなぐ基盤

- [ ] **編集テンプレートとRuntimeマップの境界を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: 編集原本の置き場所とPlay時の扱い、先行マップ（`AUGUST_31`／`TSUTAYA`）、静的テンプレートとRun固有状態の境界、座標系、既存Generatorからの移行方法、Seedの役割、ロビーを対象に含めるか。
  - 完了条件: `ETR-01`から`ETR-04`を決定し、先行マップ1件のテンプレート化を安全な実装指示へ展開できる。
  - 正本: [編集テンプレートとRuntimeマップ](systems/editor-templates-and-runtime-maps.md)、[006: 最小Runの実装で確定したサーバー境界](decisions/006-minimum-run-server-boundaries.md)

- [ ] **正式Inventory／ItemStackの最小仕様を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: Item ID、スタック、所有者、所在、マップ上の取得源、Run終了時の移管。
  - 完了条件: Quest回収とSecure Slotを一つのデータモデルで扱える最小仕様を、既存資料の正本へ記録する。
  - 正本: [現在の実装状況](systems/current-implementation.md)、[未実装機能の優先順位](systems/implementation-priorities.md)

- [x] **Secure Conversionの成長経路を決定する**
  - 状態: `Done`
  - 担当: 人間
  - 決定: 都市ロビーのアノマリー研究室で、レアルート品を消費して通常スロット1枠をSecure Slotへ変換する。総枠数は増えない。
  - 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)、[経済と成長](systems/economy-and-progression.md)

- [x] **レアルート品の分類と取得経路を決定する**
  - 状態: `Done`
  - 担当: 人間
  - 決定: レアルート品をスキル強化用とスロット強化用に分け、前者を相対的に出やすくする。アノマリー相互作用、低難度以外のQuest、チュートリアルQuestを取得経路にする。
  - 正本: [011: レアルート品の分類と取得経路](decisions/011-real-route-acquisition.md)、[経済と成長](systems/economy-and-progression.md)

- [x] **アノマリー相互作用による固有スキル取得を決定する**
  - 状態: `Done`
  - 担当: 人間
  - 決定: アノマリーの一部または関連アイテムを専用スキルと交換する。博士の調査Questと研究対象外のレアアノマリーの双方で、相互作用成立時に同一Runのパーティ全員へ固有品を出現させる。
  - 正本: [012: アノマリー相互作用による固有スキル取得](decisions/012-anomaly-linked-skill-acquisition.md)、[アノマリー相互作用](systems/anomaly-interaction.md)

- [x] **Capacity Expansionの基礎仕様を決定する**
  - 状態: `Done`
  - 担当: 人間
  - 決定: 総インベントリ枠を増やす強化を設け、Secure Conversionと同種のレアルート品を消費する。追加枠は通常スロットとして始まり、Secure化は別途Secure Conversionで行う。
  - 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)、[ゲームループとポータル遷移](systems/game-loop.md)

- [ ] **追加のスロット強化とCapacity Expansionの数値設計**
  - 状態: `Parked`
  - 担当: 人間
  - 保留理由: 交換レート、上限、入出庫時点、Player Anomaly時の制約、別種のスロット強化は、現時点の仕様範囲では決めない。
  - 正本: [010: レアルート品によるSecure Slot成長](decisions/010-real-route-secure-slot-progression.md)

- [x] **QuestとDiscoveryの最小分離を決定する**
  - 状態: `Done`
  - 担当: 人間
  - 決定: 同時受注は博士Quest 1件、その他Quest 3件、合計4件。DiscoveryはQuest枠を消費しない発見・認識記録とする。博士Quest受注中は対象アノマリーの個別出現確率を1.40倍へ上げ、対応する固有品を専用スキルへ交換できる。Party Runは開始時の異なる対象をサーバーが固定し、重複なしで補正する。アノマリー発生ごとに全候補は0.90倍へ減衰し、途中脱落後も補正を維持する。
  - 正本: [016: Party Runにおける博士Quest出現補正の固定](decisions/016-party-professor-quest-spawn-snapshot.md)、[クエスト](systems/quests.md)

- [ ] **Quest／Discoveryのデータモデルと交換状態を定義する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: Questの受注・放棄・完了・失敗状態、博士Questの解放条件、Discoveryの保存・UI、複数人のQuest入力と切断時の扱い。
  - 完了条件: `QuestService`、Discovery、アノマリー出現補正、研究室交換UIを実装指示へ展開できる最小データモデルを定義する。
  - 正本: [014: Quest枠、Discovery、博士Questによる研究解放](decisions/014-quest-discovery-and-research-unlocks.md)、[未実装機能の優先順位](systems/implementation-priorities.md)

- [ ] **Run単位のアノマリー出現コンポーネントを定義する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 決定済み: 候補外の博士Quest対象は何も起こさない。同種の同時出現上限はアノマリーごとのコンポーネントで持ち、特定アイテムが個別出現確率や同時出現数をRun単位で変動させ得る。
  - 判断対象: コンポーネントのデータ形式、解決後の枠、変動アイテム、重ね方、出現判定順。
  - 完了条件: Anomaly SystemとItem Interactionの実装指示へ展開できる最小データモデルを定義する。
  - 正本: [017: Run単位のアノマリー出現コンポーネント](decisions/017-run-anomaly-spawn-components.md)

- [ ] **異常化後のRun終了を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 決定済み: 同時Player Anomalyは1人まで。閾値超過者は先行者の死亡／帰還まで待機する。通常プレイヤー同士はHP 80%下限、Player Anomalyとの間は相互キル可能。固有InteractionのPortal帰還とRuntime満了帰還を設ける。
  - 判断対象: 固有Portal帰還・Runtime満了時のQuest／資産／基本報酬の精算、待機者へのUI、実装優先順位。
  - 完了条件: 現行の`TRANSFORMED_TIMEOUT`仮実装を置き換える終了・精算処理を実装指示へ展開できる。
  - 正本: [ゲームルール](systems/game-rules.md)、[現在の実装状況](systems/current-implementation.md)

- [ ] **Player Anomaly待機者の選出順を決定する**
  - 状態: `Done`
  - 担当: 人間
  - 決定: サーバーはExposure閾値を先に超えた順で待機キューを保持し、先行Player Anomalyの退場後に先頭をアノマリー化する。
  - 残件: 待機状態のUIと、待機中の切断時の扱いは「異常化後のRun終了を決定する」で扱う。
  - 正本: [019: Player Anomalyの単独発生、PvP、固有帰還](decisions/019-player-anomaly-runtime-pvp-and-return.md)、[ゲームループとポータル遷移](systems/game-loop.md)

- [ ] **スキルビルドの最小仕様を決定する**
  - 状態: `Needs Human`
  - 担当: 人間
  - 判断対象: 4枠案の採否、取得、強化、失効、通常成長とPlayer Anomaly時の強化の関係。
  - 完了条件: 現在の3スキル実装との移行方針を含め、最初のビルド実装単位を定義する。
  - 正本: [ゲームルール](systems/game-rules.md)、[経済と成長](systems/economy-and-progression.md)

## 更新ルール

1. 作業の区切りで、担当者は状態、結果、残った判断を更新する。
2. 同じ原因の障害が2回発生した場合は、原因と回避策を [制作トラブルシューティング](production/troubleshooting.md) へ移す。
3. 設計採否が必要になった場合は `Needs Human` に戻し、決定後は該当する設計資料と必要に応じてDecision Logを更新する。
4. `Done` にする前に、正本への反映先を各項目に追記する。Studio確認が必要な変更は、確認前に `Done` にしない。

## 指示への展開

`Ready` の項目を作業指示にする際は、次のテンプレートを使う。

```text
目的:
対象:
正本・参照資料:
変更してよい範囲:
変更しない範囲:
完了条件:
検証方法:
Studio確認:
コミット／プッシュ:
不明点・エスカレーション条件:
報告形式:
```

このテンプレートは、判断が未完了の項目を実装へ誤って進めないための境界でもある。
