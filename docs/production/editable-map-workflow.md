# 編集画面で制作する8/31マップ

**Status: Prototype: Implemented（8/31に限定）**

## 正本と編集対象

8/31の形状・配置・材質の正本は `Workspace.MapAuthoring.AUGUST_31` です。Playを開始せず、Explorerからモデルを選択してFでフォーカスできます。地形、道、建物、小物を編集し、FBXのMeshPartもこのモデル内へ配置します。

`Workspace.AnomalyDungeon` は実行時のコピーです。Play中のコピーを編集しても、Stop後の原本へは保存されません。TSUTAYAとCLOSED_STACKSはまだコード生成です。

## 制作フロー

1. Stop状態で原本モデルを確認する。
2. 関連仕様を確認し、テクスチャ・形状を比較する。
3. 原本内のGeometry・Connections等を編集する。静止物はAnchoredと衝突を用途に応じて設定する。
4. 下記の参照・属性が維持されているか確認する。
5. Studioプレースを保存する。srcだけ保存してもモデル本体は残らない。
6. Playして8/31を選び、Runコピーで移動・Prompt・昼夕夜・8/32を検証する。
7. Stopして原本に戻り、問題・未確認事項を記録する。

初回変換は明示的に行い、通常の編集時に生成器を呼ばない。旧生成器の再実行は手編集を失わせるため、原本が存在する初回変換ツールは停止する。

## 維持する参照

- `_MapBindings/{Lobby,Entry,Aug32Spawn,SecretSpawn}`：移動先の位置マーカー。位置を変更する場合はこちらも移動する。
- 各ゾーンの `ZoneCenter` と `Width/Depth/Height/DisplayName`：部屋判定。建物の移動だけで判定領域は移動しない。
- `_MapBindings/Prompts`：端末のProximityPrompt参照。移動や名称変更は参照を保てるが、削除して作り直す場合はObjectValue.Valueも更新する。
- `_MapBindings/{Pool,Observer,Ambience}` と `DateBoards`：既存処理の対象。
- `MapTintGroup`：Ground/Foliage/Structure/Water/Road。新規部品でフェーズ色変化が必要なら設定する。色変化不要な部品は未設定でよい。
- `Aug32Reveal=true`：通常時は非表示・非衝突。`Aug32Transparency` は表示後の透明度。
- `MapGroundTile=true`：既存地表タイルの識別。
- MapId、AuthoringSchema、KillY：Runtime接続情報。任意に削除しない。

編集原本のSpawnLocationは無効化し、ロビーのスポーンに影響させない。移動には既存RunServiceの位置マーカーを使う。

## 初回変換・ツール操作

[Command Bar用スクリプト](../../tools/map-authoring/bake-august.luau) を利用する。初期形状の生成器はStudioに残すが、実行時は利用しない。詳細は [判断記録024](../decisions/024-editable-august-map-authoring.md) を参照。

## 検証記録（2026-10-13）

- Editモデル展開：10ゾーン、日付板2、8/32対象11、地表タイル13,176。
- Clone参照：端末・泉の参照がコピー内部へ移ることを確認。
- 編集色：コピーから再構築するTint Baseに編集したColorが反映されることを確認。
- Play起動：MapAuthoringがWorkspaceからServerStorageへ移り、元のClockTime=0へ戻ることを確認。通常Bootstrapの起動ログを確認。
- PlayでRunService.Buildを2回実行：DAY初期化、旧コピー破棄、実行時の色変更が次Runへ残らないこと、CloseRun後の原本保持を確認。確認用Scriptは削除済み。
- Stop後に編集モデルと昼照明へ戻ることを確認。
- 複数クライアント、実歩行、景観画面、8/32までの通しプレイ、プレース保存後の再起動は未確認。

## 境界

地表の13,176タイルは初期資産として残っており、軽量化が完了したわけではありません。Terrain化や地形メッシュ化は別作業です。岩のEditableMesh比較モデルは別の試作で、本番素材として原本へ組み込んでいません。
