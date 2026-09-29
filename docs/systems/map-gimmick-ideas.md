# マップとギミック案

**Status: Mixed（案ごとに下記）**

この資料は、Anomaly Dungeonの基盤ルールを利用して異なるゲーム体験を作るためのマップ案・ギミック案を記録する。基盤ルールは[ゲームルール](game-rules.md)と[ゲームループとポータル遷移](game-loop.md)を参照する。

各マップの採用状況は以下のとおりです。

| マップ | 状態 | 実装場所 |
| --- | --- | --- |
| Abandoned TSUTAYA | Prototype: Implemented | `Maps/Tsutaya/TsutayaGenerator`、`TsutayaArchiveService` |
| 8月31日 | Prototype: Implemented | `Maps/August/AugustGenerator`、`August31Service` |
| SEKIGAHARA | Idea（アイデア） | 未実装 |
| KOROHKAN | Idea（アイデア） | 未実装 |
| Observation / Open Liminal Map | Idea（アイデア） | 未実装 |

実装済みでも設計として採用済みではない。Transition Portal、Party State、以及Map間の遷移条件は未実装であり、TSUTAYAはデバッグフロアから直接読み込む形式である。

マップは独立したゲームシステムを持つのではなく、既存の基盤システムの特定部分が強く生きる状況を作ることを目的とする。

## 8月31日

**Status: Prototype: Implemented（実装済みプロトタイプ）**
**Studio確認日: 2026-09-29**

### 実装済みの範囲

- `LOBBY`、`ROAD`、`VILLAGE`、`SHRINE`、`RICE`、`RIVER`、`APARTMENT`、`TUNNEL`、`FOREST`、`DAM`の10ゾーンと、ゾーン間の12本のTrail。`CLOSED_STACKS`と同じ`AnomalyDungeon`モデルとして生成される。
- 出口条件は`MapDefinitions.AUGUST_31.ExitCondition`が保持し、条件種別は`TERMINAL`のみ。端末Promptは`UnlockExit`。
- Server側で`DAY` → `EVENING` → `NIGHT`の順に時間を進行させる。進行するのは探索者がマップ内にいる間だけで、最初の探索者が入るまで待機のまま止まり、无人になると停止する。
- フェーズ時間は昼480秒、夕方300秒、夜300秒、切り替えのブレンドは24秒。設定値は`AugustConfig`が保持する。
- `EVENING`以降は依頼未達成でもReturn Portalが開く。端末を操作して開いた状態と、時間経過で開いた状態は別々に扱う。
- `NIGHT`が終わると日付が8月32日へ遷移する。別マップへの遷移ではなく、同一マップの状態変化として扱う。
- 8/32ではReturn Portalが閉じる。探索者は団地前の広場へ移動し、Anomaly Exposureの取得速度が`ExposureMultiplier`で2.4倍になり、Run Lifetime300秒が残る。帰還手段はなく、期限切れは強制帰還として処理する。
- 8/32専用Partsが11個生成され、通常は非表示・非衝突。遷移時に一括で表示する。
- 日付板がマップ内に2枚あり、日付変更に合わせて表示が更新される。
- フェーズごとに`Lighting`のAmbient、OutdoorAmbient、Brightness、FogColor、FogStart、FogEnd、ColorShiftと、プレース既存の`Atmosphere`のColor、Density、Haze、Glareを差し替える。マップが有効な間だけ所有し、マップ再構築時にBind前の値へ戻す。
- 生成時の色を`tint`グループとして登録し、フェーズごとに色味を変える。
- 音は`Ambience`としてマップモデル直下に1つだけ保持する。

### 未実装の境界

- 共通Anomaly Systemは未実装であり、「通常のAnomaly発生ルールを適用する」は成立していない。
- 8/32での強制Anomaly発生は未実装である。危険度上昇はExposureの取得速度と帰還閉鎖だけで表現する。
- Rare Lootと特殊Transition Portalは未実装である。
- フェーズごとの日付板の時刻は未確定である。現在は`DateBoardClock`の値のみを全フェーズで使い回す。
- `Ambience`の音源は差し替え用のプレースホルダーであり、実プロジェクトの蝉や風の収録音源は未選定。
- Transition PortalとParty Stateは未実装のため、マップ切り替えはデバッグフロアの`DebugMapSwitch`端末から行う。現時点で同端末の`MapSwitchDeck`が空のFolderとして残る状態があり、8月31日の読み込みは未確認である。

### コンセプト

「ぼくのなつやすみ」「8月32日」的な、日本の夏休みの終端を利用した異常空間。通常の夏休み風景から始まり、「8月32日」は別マップへの遷移ではなく、同一マップの状態変化として発生する。

### 初期状態と帰還

- 日付は8月31日で、通常の夏の風景を探索できる。
- 通常のAnomaly発生ルールを適用する。
- 時間はServer側で進行する案とする。
- 夕方になるとReturn Portalが出現し、プレイヤーは帰還または探索継続を選べる。

### 8月32日

一定条件で日付が8月32日に移行する案とする。変化の候補は以下のとおり。

- テクスチャ・環境が徐々に崩壊する。
- 異常現象が増加し、Anomalyが強制的に発生する。
- 危険度が上昇する。
- Rare Lootと特殊Transition Portalが出現する。

実装済み範囲では、日付板の書き換え、帰還閉鎖、Exposure上昇、Run Lifetimeによる強制帰還までに限られる。強制Anomaly発生とRare Lootは未実装である。

```text
8/31
    -> Return可能
    -> 「もう少し探索する」
    -> 8/32
    -> 危険度上昇とRare Loot
    -> 帰還 / 脱出 / Run Termination
```

**主役:** Risk / Reward、Secure Slot、Anomaly Exposure、Exploration

## Abandoned TSUTAYA

**Status: Prototype: Implemented（実装済みプロトタイプ）**
**Studio確認日: 2026-09-29**

### 実装済みの範囲

- `FRONT`、`VHS`、`DVD`、`CD`、`BROADCAST`、`TAPE`、`BACKROOM`の7ルームと7つの通路。`CLOSED_STACKS`と同じ`AnomalyDungeon`モデルとして生成され、`Rooms`、`Connections`、`Roofs`を持つ。
- 扉は`ROOMS`の指定だけで開通し、各部屋は袋小路構造になっている。9スタッド高の棚スタック、柱、レジカウンター、返却ラック、放送卓が視界を分断し、床全体を見渡せない。
- 出口条件は`MapDefinitions.TSUTAYA.ExitCondition`が保持する。条件種別は`TERMINAL`のみで、`CLOSED_STACKS`と同じ型である。
- 棚（`ArchiveShelf`）5基。調べる操作でArchive Selection UIが開き、VHS／DVD／CD／Tapeの項目から選択できる。1回の検索で全項目が返ることはない。
- CRT 4台。チャンネル変更で停波ノイズを挟んで映像が切り替わり、放送中のチャンネルと停波中のチャンネルでは音が変わる。
- 試聴機3台。個人試聴は`PreviewDuration`で自動的に終わり、共有BGM（`SharedBgm`）とは独立している。
- 共有BGMはマップモデル直下の`Sound`として保持し、Server Stateで管理する。個人試聴がこの音を変えることはない。

### 未実装の境界

- Transition PortalとParty Stateは未実装のため、マップ切り替えはデバッグフロアの`DebugMapSwitch`端末から行う。
- 共有BGMの選択UIは未実装であり、現状は固定の音源をループ再生する。
- 個別メディアの実際の内容（映像・音声）は未実装であり、項目は名前と選択結果のみを持つ。
- Archive Selection UIには一覧、選択、閉じる以外の遷移がない。
- Map固有のAnomalyは`/dev/null`Existingのプロトタイプに依存していない。TSUTAYA独自の異常は未実装。

### コンセプト</new_string>

廃店舗化したTSUTAYAを、存在するはずのないメディアを収集し続ける「アーカイブ」として扱う案。VHS、DVD、CD、Audio Tape、Broadcast、CRT、店内設備などを含み、発売されていない作品・存在しない作品が混在する。

MediaとRealityが干渉し、メディアを見る行為自体が現実側の変化を引き起こす。特定作品の再現ではなく、メディアと現実の境界が崩れる原理を利用する。

### アーカイブと相互作用

- 棚にある全メディアを個別オブジェクトにせず、棚を調べると検索・閲覧用のArchive Selection UIを開く方式を基本案とする。
- VHSだけを調べると、DVD、CD、CRTなどにある情報を見落とす可能性がある。
- VHS内の店舗映像の棚配置が現実側へ反映される、映像にしか存在しない部屋、未来の店内、現在位置を映す映像、再閲覧で内容が変わる映像などを候補とする。
- CDはListening Stationで個人試聴でき、Back Roomなどで再生すると店舗のShared BGMを変えられる案とする。Shared BGMはServer Stateで管理する。
- CRTのチャンネル変更、店内放送、古い機器の操作、VHS/DVD/CDの閲覧、meme・analog horror的断片の再生を小規模な相互作用の候補とする。

架空楽曲には、AnomalyやMapに関する歌詞・音響的手掛かりを仕込む案がある。明確な正解は提示せず、元ネタを知らなくても異常な映像として成立することを優先する。

**主役:** Exploration、Information、Media / Reality Interaction
**副役:** Multiplayer Information Sharing、Anomaly、Collection

## SEKIGAHARA

### コンセプト

歴史的な関ヶ原そのものを再現せず、なぜか延々と続く巨大な戦場として扱う案。複数勢力のNPCが常時戦闘し、プレイヤーは戦闘回避、戦場を利用した探索、弱ったNPCの撃破、戦闘介入、乱戦への参加を選べる。

NPCは有限数を常時生成せず、Active NPC数の上限を設け、倒されたNPCを後方から補充する。プレイヤーには戦争が永遠に続くように見せる。

### ビルドとAnomaly

`Attack / Attack / Attack / Attack`のようなFull Attack Buildが強く機能する状況を作る。単体処理、範囲処理、ノックバック、突進、遠距離攻撃などが異なる戦場攻略を可能にする。

攻撃型Individual Anomalyと組み合わさると、戦場を一人で破壊できるほどの戦闘力が偶発的に発生し得る。固定の無双モードではなく、Build、Map、Anomalyの組み合わせによる一時的な体験を目指す。

**主役:** Skill Build、Combat Events
**副役:** Multiplayer、Secure Slot、Risk Management

## KOROHKAN

### コンセプト

歴史的な虎牢関などのイメージを抽象化した、複数勢力が攻め続け、守り続ける巨大要塞の案。

外郭、門、内郭、複数ルート、高所、裏道を持ち、NPCは攻撃、防衛、退却、増援を繰り返す。

### プレイヤーの選択

- **Combat**: 正面突破する。
- **Mobility**: 戦闘を避け、別ルートから侵入する。
- **Exploration**: 隠し通路、物資、特殊アイテムを探す。
- **Hybrid**: 戦況変化の隙に突破する。

**主役:** Combat、Mobility、Exploration
SEKIGAHARAよりも、戦場と探索の比重を高くする。

## Observation / Open Liminal Map

### コンセプト

閉鎖されたループ廊下ではなく、開けた風景で観察、反復、知覚の変化を扱う案。遠景の物体、建物、人物などが徐々に変化する。

```text
遠景を観察
    -> 微細な異常を発見
    -> 観察・Interaction
    -> Focus / Recognitionが進行
    -> 遠景の異常が明確になる
    -> Portalが出現
```

Focus値はUIで直接表示せず、プレイヤー自身が「さっきより見えている」と感じることを重視する。

Focus / Recognitionの視野・遮蔽・継続観察の判定は、個別Map固有の仕組みとして作らず、[観察・認識システム](observation-and-recognition.md)の共通契約へ接続する案とする。具体的なCandidate条件と報酬は未決定である。

### 相互作用とリスク

短いInteractionの候補として、目標位置に止める、一瞬だけ出る物体を認識する、ノイズから対象を見つける、音の方向を当てる、形状を識別する、違いを発見するなどを扱う。

完全に観察しなくても帰還できる一方、深く観察するとRare Loot、FILE、特殊情報、新しいAnomalyを得られる可能性がある。観察するほど危険になる設計も検討対象とする。

**主役:** Exploration、Observation、Information

## マップ設計原則

新しいMapを追加する際は、「このMapは何が面白いか」だけでなく、**既存のどの基盤システムが、このMapで別の価値を持つか**を定義する。

最低限、以下を記録する。

```text
Map Name
Core System
Secondary Systems
Player Choice
Risk / Reward
Combat Role
Anomaly Interaction
Return Condition
Termination Condition
Unique Experience
```

マップ固有システムを増やすこと自体を目的にせず、既存のゲームルールを別の文脈で使わせることを優先する。

## 未決事項

- 各マップの採用、マップ名、ポータル候補群に含める条件。
- Return Portal、Transition Portal、Terminationの具体条件と優先関係。
- 8月32日への移行タイミングは実装済みである。Rare Loot、強制Anomalyの内容、フェーズごとの日付板の時刻は未確定のままである。
- Abandoned TSUTAYAにおける個別メディア、Archive UI、Shared BGM、外部作品・商標との最終的な扱い。
- SEKIGAHARAとKOROHKANのNPC勢力、戦況ロジック、敵対・協力関係。
- Observation / Open Liminal MapのFocus / Recognition、短いInteraction、知覚変化の実装と評価。

## 関連資料

- [ゲームルール](game-rules.md)
- [ゲームループとポータル遷移](game-loop.md)
- [ゲームシステムドキュメント](README.md)
