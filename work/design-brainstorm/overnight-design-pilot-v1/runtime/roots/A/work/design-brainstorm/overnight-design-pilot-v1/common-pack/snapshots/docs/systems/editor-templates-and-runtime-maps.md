# 編集テンプレートとRuntimeマップ

**Status: Draft（設計選択肢の整理。未実装）**
**更新日: 2026-10-02**

## この文書が定義すること

Studio編集時にマップを直接見て制作・確認できることと、Party Runごとに独立したマップ状態を持つことを両立するための、編集テンプレートとRuntimeコピーの境界を整理する。

本書は実装開始を承認するものではない。現在の`TSUTAYA`、`AUGUST_31`、都市ロビーはいずれもサーバーが実行時に組み立てる。現行の確定済み最小Run境界は[006: 最小Runの実装で確定したサーバー境界](../decisions/006-minimum-run-server-boundaries.md)を参照する。

## 背景

現行の生成マップはRun開始時に`Workspace/AnomalyDungeon`へ生成され、全PartyメンバーのRun終了時に破棄される。この方式は、8月31日の時刻・8/32状態・出口・Run固有のアノマリー状態を次Runへ持ち越さないこと、途中参加を防ぐことに役立つ。

一方、通常のStudio編集画面にはマップも都市ロビーも存在せず、景観・小物・導線を視覚的に制作しにくい。生成コードだけを唯一のマップ原本にしたままでは、特に8月31日の景観調整を反復しにくい。

## 解決したい境界

| 区分 | 役割 | Runごとに複製するか |
| --- | --- | --- |
| 編集テンプレート | Studioで視覚的に編集する原本。地形、建物、棚、小物、道、部屋構造、配置Markerを持つ。 | しない。編集時だけ原本として残す。 |
| Runtimeマップ | 選出されたPartyが探索する実体。 | する。Run終了時に破棄する。 |
| Runtime状態 | Party、出口の開放、8/32、アノマリー、敵、拾得物、Quest進行、個別認識差。 | する。テンプレートへ書き戻さない。 |
| 共有環境 | Lightingなど、Run中に借用して復元する全体状態。 | 複製せず、所有権と復元を明示する。 |

## 提案する基本構造

以下は採用候補であり、未決定事項を含む。

```text
Studio編集時
Workspace
└── EditorTemplates
    ├── TSUTAYA
    └── AUGUST_31
        ├── Geometry
        ├── Visual
        ├── Rooms
        └── Markers
            ├── Entry
            ├── Return
            ├── ExitTerminal
            ├── AnomalyPoints
            └── ItemPoints

Play時
ServerStorage
└── MapTemplates                 ← 編集原本を退避または複製したカタログ

Workspace
└── Runtime
    ├── CityLobby
    ├── DungeonEntranceLobby
    └── ActiveMap                 ← 抽選されたテンプレートのRun用コピー
```

`EditorTemplates`を編集上の原本にする案では、Play開始時に原本を`ServerStorage`へ退避するか、同内容をカタログへ複製する。どちらを採るかは未決定である。いずれの場合も、プレイヤーが見るのは`Workspace/Runtime/ActiveMap`だけとする。

## テンプレートに含める候補

### 静的に保持する候補

- 地表、建物、部屋、道、棚、遠景、小物
- Room名、表示名、サイズなどの静的Attribute
- `Entry`、`Return`、出口端末、敵・アノマリー・アイテム・ギミック用の配置Marker
- 8月31日の通常時に見える景観

### Runtime Binderが担当する候補

- Party固有の入場・退出と、Run状態のAttribute
- ProximityPrompt、出口の有効／無効、Quest進行への接続
- 敵、アノマリー、拾得物、投射物、個人向けEffects
- 8月31日の時刻、Lighting借用・復元、8/32での状態変化
- Seedを使うなら、そのRunだけの軽微なバリエーション

テンプレートに置くMarkerは、ゲームプレイの実体ではない。Marker自体がプレイヤーの移動、Raycast、Promptを阻害しないことを検証する。

## 現行Generatorとの移行原則

1. `TsutayaGenerator`と`AugustGenerator`を直ちに削除しない。
2. まず既存Generatorの出力を視覚的なテンプレート原案として採取し、現在のマップ固有ギミックと配置Markerを照合する。
3. テンプレート複製とRuntime Binderで同じRunを成立させ、Studio検証を通すまでGeneratorをフォールバックとして残す。
4. 実装済みの`RunService`の終了集約、Map抽選、Party受付、8月31日の環境復元は維持する。
5. テンプレートとRuntimeコピーが一致したと検証できたマップだけを移行済みとする。

8月31日の地表は現在Roblox TerrainではなくPart群として生成している。そのため、現行出力をテンプレートへ移す技術的可能性はある。ただし、出力の採取方法、Part数・負荷、編集後の再配置方法は未確認である。

## 実装前に決める必要がある事項

| ID | 決定事項 | 主な選択肢 | 影響 |
| --- | --- | --- | --- |
| `ETR-01` | 編集原本の置き場所とPlay時の扱い | `Workspace/EditorTemplates`を退避する / ServerStorage原本を編集用に展開する | 原本の一意性、Play中の可視性、制作手順 |
| `ETR-02` | 最初に移行するマップ | `AUGUST_31` / `TSUTAYA` | 制作優先度、移行リスク、検証範囲 |
| `ETR-03` | テンプレートとRuntimeの責務境界 | 静的部品・Markerの範囲、Prompt・8/32部品・ランダム要素の扱い | Binderの規模、誤って状態を持ち越す危険 |
| `ETR-04` | 座標系 | 現行の実行座標を維持する / テンプレートを原点基準へ移す | 既存Serviceとの互換性、Studioでの編集しやすさ |
| `ETR-05` | テンプレート原案の取得方法 | 現行生成物を採取する / 各マップをStudioで再構築する | 初期コスト、既存表現の再現性 |
| `ETR-06` | Seedの役割 | 空間配置にも使う / 静的空間は固定しRuntime変化だけに使う | 同一性、再現性、今後のマップ変種 |
| `ETR-07` | 都市・入口ロビーの対象範囲 | 今回は対象外 / 同じ方式へ含める | 2D都市マップ方針、作業規模 |
| `ETR-08` | 原本変更をRuntimeへ反映する制作手順 | 手動確認 / 将来の同期・検証ツール | GitとStudioの反映関係、変更漏れ |

`ETR-01`から`ETR-04`が決まるまで、テンプレート化の実装指示は生成しない。`ETR-05`以降は先行マップと制作環境を見て決める。

## 最小移行単位の候補

最初の移行は1マップだけを対象にし、次を完了条件とする。

1. Studio編集画面でテンプレート全体と主要Markerを確認できる。
2. Play開始後、編集原本がプレイヤーの探索空間に残らない。
3. Party受付からRunを開始すると、テンプレートのコピーが`Workspace/Runtime/ActiveMap`に1つだけ現れる。
4. Entry、出口条件、帰還、Run終了時の破棄が現行最小Runと同じ結果になる。
5. 次Runで前Runの出口・8/32・アノマリー・拾得物などが残らない。
6. 対象マップの既存Studio検証チェックリストを通す。

## 関連資料

- [006: 最小Runの実装で確定したサーバー境界](../decisions/006-minimum-run-server-boundaries.md)
- [現在の実装状況](current-implementation.md)
- [Robloxプロジェクト構成](project-structure.md)
- [ロビー／ワールドマップ](lobby-world-map.md)
- [Studio検証チェックリスト](../production/studio-verification-checklist.md)
