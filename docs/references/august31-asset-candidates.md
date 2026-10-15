# 8月31日マップのアセット候補

**Status: Draft（候補一覧・未採用）**
**更新日: 2026-10-13**

## 目的と確認範囲

8/31の既存景観・ゾーンに必要な形状と表面素材を整理する調達・試作資料です。新しい建物、ギミック、ロアを決定する資料ではありません。Studioの実構造・最新の生成物は今回未確認です。

作風の検討方向は「ポリゴンは粗くてもよいが、表面は写実的。遠目では自然に見え、近づくと形状と表面の差に奇妙さがある」です。2026-10-13の岩2素材比較をユーザーが確認し、十分かつ良いと評価しました。ただしRock Face単体の正式採用、作風の本番適用は未決定です。

- **比較済み**：同一80三角形モデルへのRock 01 / Rock Face適用をBlender 5.2.1でレンダリング。[材質試作記録](material-preview.md)にはEdit配置あり。通常FBX Import・見た目・Play等の素材固有検証は未確認。
- **配布確認**：具体的な配布ページを確認。モデルへの適用・ダウンロード内容・性能は未検証。
- **要調査**：具体的に適合する配布素材は未確保。存在しないという意味ではありません。
- **個別制作候補**：配置・形状・機能がマップ固有。既存生成物の流用可否も含めて検討します。

## 自然物・地表

| 必要なもの | 使用場所・根拠 | 形状の候補 | 表面・配布候補 | 状態・注意 |
| --- | --- | --- | --- | --- |
| 山・稜線 | 谷を囲む遠景（007・008） | 大きな面による稜線。既存地形の流用も検討 | [Rock Face](https://polyhaven.com/a/rock_face) | 材質比較済み。山形状は個別制作候補。岩肌を谷全域に貼る決定ではない |
| 谷底・歩く斜面 | ゾーンとTrailの接続（007） | 現行高さ関数による地形／Terrain／地形メッシュの比較が必要 | [Forest Ground 06](https://polyhaven.com/a/forest_ground_06)、[Gravel Floor 04](https://polyhaven.com/a/gravel_floor_04) | 配布確認。地形方式は未決定。素材で高さ整合は解決しない |
| 大きな岩 | 湖畔・河原・斜面（008） | 比較用80三角形岩を基に複数形状を試す | [Rock Face](https://polyhaven.com/a/rock_face)、[Rock 01](https://polyhaven.com/a/rock_01) | 比較済み。80三角形は試作条件であり本番予算ではない |
| 小石・石の群れ | 河原・水際（008） | 少数の粗い立体石＋地表材質 | [Clean Pebbles](https://polyhaven.com/a/clean_pebbles) | 配布確認。テクスチャ内の石を立体として扱わない |
| 砂利道 | Trail・水辺の地表 | 起伏に沿う路面 | [Gravel Floor 04](https://polyhaven.com/a/gravel_floor_04) | 配布確認。適用範囲は未確定 |
| 森の土 | FOREST・土のTrail | 地表と共通 | [Forest Ground 06](https://polyhaven.com/a/forest_ground_06) | 配布確認 |
| 針葉樹 | 森の量塊（008） | 少数の樹冠の量塊と単純な幹。具体形状は試作 | [Bark Willow 02](https://polyhaven.com/a/bark_willow_02)は樹皮比較の候補。葉は要調査 | 樹皮配布確認。柳の樹皮を針葉樹に正式採用する意味ではない |
| 広葉樹 | バス停・集落・田の周囲（008） | 粗い幹・枝・樹冠 | [Bark Willow](https://polyhaven.com/a/bark_willow)、[Bark Willow 02](https://polyhaven.com/a/bark_willow_02) | 樹皮配布確認。樹種、葉の素材、透過の構成は未決定 |
| 夏草・茂み | 道路沿い・集落（008） | 少数の草群／カード等を比較 | 葉・草の写真素材は要調査 | 要調査。遠景と近景での輪郭、透過描画、密度を検証する |
| 葦 | 湖畔（008） | 少数の茎と葉のまとまり | 適合モデル・葉素材は要調査 | 要調査。汎用草を葦として扱わない |
| 田の植生 | RICE（008） | 低い草のまとまり。稲として作るかは未確定 | 具体的な稲・草素材は要調査 | 要調査。既存記録は低い草のまとまりで、稲の品種・生育段階は未指定 |
| 田の土・畦 | RICEの補助素材 | 現行区画に合わせる | [Farm Furrows](https://polyhaven.com/a/farm_furrows) | 配布確認。ただし耕した畑の土で、水田そのものではない。使用は適合確認後 |
| 湖底・岸・水面 | 湖（007・008） | 現行湖との整合を確認して制作 | 岸は砂利・土を共用。水面はRoblox側の表現を検討 | 個別制作候補。Terrain水への変更を採用したわけではない |

## 人工物・建築

| 必要なもの | 使用場所・根拠 | 形状の候補 | 表面・配布候補 | 状態・注意 |
| --- | --- | --- | --- | --- |
| 道路 | ROAD・集落への視線（008） | 現行地形に沿う路面 | [Asphalt 02](https://polyhaven.com/a/asphalt_02) | 配布確認。起伏との接続は別作業 |
| バス停 | 入口の前景（008） | 既存構造を確認し、必要部品のみ制作 | [Metal Plate 02](https://polyhaven.com/a/metal_plate_02)、[Wood Planks](https://polyhaven.com/af/a/wood_planks)は材質候補 | 材質配布確認。ベンチ・屋根などの構成を新規に決定しない |
| 電柱・電線 | 谷から集落への方向（008） | 少ない面の柱、低密度の線。既存物を基準にする | [Concrete Wall 009](https://polyhaven.com/a/concrete_wall_009)は表面候補。電線は単色も比較 | 配布確認。柱材質・設備形式は未確定 |
| 集落の住宅 | VILLAGE（008） | 単純な壁・屋根・窓。既存建物を確認して再構成 | [Concrete Wall 009](https://polyhaven.com/a/concrete_wall_009)、[Wood Planks](https://polyhaven.com/af/a/wood_planks) | 配布確認。住宅の建築様式は未決定 |
| 屋根 | 集落の建物の表面候補 | 大きな屋根面を基本に試作 | [Grey Roof 01](https://polyhaven.com/a/grey_roof_01) | 配布確認。全建物を瓦屋根にする決定ではない |
| 商店・日除け | 集落の生活の密度（008） | 壁・屋根は共通化、日除けは簡単な面 | 布・外壁の具体的な組み合わせは要調査 | 個別制作候補。名称・商品の創作はしない |
| 団地・前面広場 | APARTMENT・8/32の遠景マーカー（008） | 繰り返す壁・窓・廊下の部品を検討 | [Concrete Wall 009](https://polyhaven.com/a/concrete_wall_009)、[Metal Plate 02](https://polyhaven.com/a/metal_plate_02) | 配布確認。外形・移動経路・8/32増築との整合が必要 |
| SHRINEの構造物 | 現行ゾーン（map-gimmick-ideas） | 既存構造を確認してから必要部品を確定 | 木・石の共通材質を比較 | 個別制作候補。鳥居・社殿等を必須資産として創作しない |
| トンネル入口・内壁 | TUNNEL | 外形と内側を持つ粗い形状 | [Concrete Wall 009](https://polyhaven.com/a/concrete_wall_009)、[Rock Face](https://polyhaven.com/a/rock_face) | 配布確認。通れる断面と衝突形状を別途検証 |
| ダムの構造物 | DAM | 現行構造を確認して部品化 | [Concrete Wall 009](https://polyhaven.com/a/concrete_wall_009)、[Metal Plate 02](https://polyhaven.com/a/metal_plate_02) | 個別制作候補。設備の種類・構成は未確定 |
| 学校の建物 | 007で旧生成物の流用に言及 | 既存構造・配置を確認 | 壁・窓・屋根の共通材質を検討 | 要確認。今回の10ゾーン一覧だけでは配置を特定できない |
| サイン・日付板 | 景観サイン（008）・既存日付板 | 既存の表示面と機能を維持して検討 | 架空の表記は既存仕様に従い別途制作 | 個別制作候補。実在の標識・制度をそのまま採用しない |
| 端末の外装 | 既存UnlockExit Prompt | 操作位置を維持する単純な筐体 | 金属素材を比較 | 個別制作候補。ゲームロジックは変更しない |
| 8/32専用増築物 | 既存Aug32Reveal属性 | 既存物と属性を確認して外装を検討 | 通常時の共通材質を基本候補とする | 個別制作候補。新たな異常挙動を作らない |

## 配布モデルの補助候補

完成モデルの見た目をそのまま採用するより、形状の流用や簡略化後の材質再設定を検討します。再設定にはUVの確認が必要です。

| 配布候補 | 調査対象 | 状態 |
| --- | --- | --- |
| [Kenney Nature Kit](https://kenney.nl/assets/nature-kit) | 木・岩・植生の形状 | 配布確認・CC0。個別モデルの適合、形式、UVは未確認 |
| [Quaternius Ultimate Nature Pack](https://quaternius.com/packs/ultimatenature.html) | 木・岩・草群の形状 | 配布確認・CC0・FBX/OBJ/Blend。写実的テクスチャへの貼り替えは未検証 |
| [Kenney City Kit Suburban](https://kenney.nl/assets/city-kit-suburban) | 住宅の形状 | 配布確認・CC0。8/31の建築の雰囲気への適合は未確認 |
| [Kenney City Kit Commercial](https://kenney.nl/assets/city-kit-commercial) | 商業建築の形状 | 配布確認・CC0。必要な店舗部品が含まれるかは未確認 |
| [Kenney City Kit Roads](https://kenney.nl/assets/city-kit-roads) | 道路部品 | 配布確認・CC0。谷の起伏への適合は未確認 |

高詳細スキャンのCoast Rocks 01やMountainsideは、今回の軽い形状を基本とする方向では優先度を下げます。必要な用途が出た場合に再検討し、不採用決定とは扱いません。

## 試作する順序（提案）

1. 岩：比較済み素材を基準に、面の陰影・UV継ぎ目・模様の大きさを調整する。
2. 地表：砂利・森の土・アスファルトを同じ路面で比較する。
3. 建築：粗い壁と筐体で、コンクリート・木・金属を比較する。
4. 植生：幹・樹冠・草を比較する。樹皮だけでは木全体の写実感を判断できない。
5. 景観：バス停から道・集落・水面・団地へ続く一場面でまとめて確認する。

必要点数・配置密度・解像度・ポリゴン予算は、本番マップの大きさ、描画距離、端末性能を確認して決めます。全素材を高解像度にする前提ではありません。素材選定→同一形状への適用→固定条件で距離比較→熟考準備、という試作フローを利用し、採用は別に判断します。

## 実装との整合・未決事項

- 007の高さ関数、ゾーン平坦化、湖、Trailを維持して表面を更新する作業と、地形方式を変更する作業を分けて検討します。008の変更範囲は景観小物とCanopyでした。地形の全面再構築はその範囲を超えるため、実施時は新しい判断記録が必要です。
- 8/32表示制御、Tint、Prompt、移動経路への材質・形状変更の影響はStudioで確認します。
- 葉、草、葦、田の植生、日除けの布、窓の表現は具体素材未選定です。
- 天空と水は外部モデルの調達だけで完成せず、Roblox側の照明・材質設定も含みます。蝉・風の音源は既存記録でも未選定ですが、この一覧は視覚アセットに限定します。
- Poly Haven素材はCC0。取得時はAPIからマップ種類と利用可能な解像度を確認します。金属ではMetalnessも必要に応じて使います。Blenderの材質ノード、Displacement等がStudioへそのまま移ることは保証しません。
- 代替はRoblox既存材質、既存生成物の再利用、Blenderでの簡単な個別制作です。新しい有料アセットや外部アドオンを導入したわけではありません。

## 関連資料・出典

- [007: 地形・湖・時計](../decisions/007-august-31-terrain-lake-and-clocktime.md)
- [008: 景観構成](../decisions/008-august-31-landscape-composition.md)
- [マップとギミック案](../systems/map-gimmick-ideas.md)
- [舞台設定](../world/setting.md)
- [比較ツールと再実行手順](material-preview.md)
- https://aug31-rock-review.bonnymelon65.chatgpt.site
- https://polyhaven.com/license
- https://3d.shep.bot/ （検索窓口。個別候補は配布元で確認）
