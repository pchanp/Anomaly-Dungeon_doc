# 024: 8/31を編集画面の保存モデルから制作する

**Status: Prototype: Implemented（Studio反映済み・検証範囲は下記）**
**Date: 2026-10-13**

## 背景と判断

ユーザーは、実行時生成では編集画面で景観を確認できずデバッグとアセット制作が進めにくいため、編集画面でマップを確認できる制作方法への移行を要求した。

8/31を `Workspace.MapAuthoring.AUGUST_31` の編集可能なモデルへ初回変換する。通常のRunでは形状を生成せず、保存モデルを複製して既存Run・8/31サービスへ接続する。今回は8/31から移行し、CLOSED_STACKSとTSUTAYAは従来生成のままとする。

007の地形計算は初期モデル作成に利用する。008の景観方向・ゾーン・Trail・Prompt・帰還・8/32のルールは変更しない。ただし、実行時の形状生成を正本とする扱いは本記録で置き換える。編集後のモデルに旧生成器を再実行して上書きしない。

## 実装

- `Maps/Authoring/AuthoredAugustMap` が変換、参照再構築、複製を担当する。
- `AugustGenerator.Build(seed,authoringParent)` は明示的な編集用生成先を受け取る。その場合、Workspaceの既存マップを破棄しない。
- RunServiceは8/31のBuildを保存モデルのコピーへ切り替える。
- Play起動時だけMapAuthoringをServerStorageへ移し、編集用モデルとRun用モデルの重複描画・衝突を避ける。Stopで編集モデルに戻る。
- `_MapBindings` の位置マーカーとObjectValueが入口、帰還等の位置、端末、日付板、泉、Observer、音を保持する。ObjectValueはClone時にコピー側へ参照が移る。
- ゾーン内ZoneCenter、Width/Depth/Height/DisplayNameが区域判定の正本になる。
- MapTintGroup属性が色変化の対象を示す。編集した色をRun開始時のBaseとして読む。
- Aug32RevealとAug32Transparencyを維持する。通常の原本では非表示のまま保つ。
- 編集用の昼照明は変更前値をMapAuthoring内に保持し、Play起動時に元の値へ戻す。ゲーム内のLighting所有権はAugust31Serviceが維持する。

## Seedと再読込

8/31の景観は保存モデルで固定される。RunSeedはRunごとに変わるが、景観のランダム再生成には使わない。8/31の再抽選端末は保存モデルの再読込に変える。従来の木・小物の配置変動を維持するには別の設計が必要で、今回は導入しない。

## StudioとGitの差異

作業開始時のStudio AugustGeneratorは596行で、Git側の景観変更（008に対応する広葉樹等）が未反映だった。初回モデルはStudioの実ソースから展開し、景観を同時に変更していない。GitとStudioの生成器の差異は残るが、移行に必要な引数変更は両側へ反映した。

保存モデル本体はStudioプレース内の資産で、srcとの自動同期はない。プレース保存、再起動後の保持、モデルの外部書き出しは別途必要。ゲーム公開は行わない。

## 検証

結果は [制作手順](../production/editable-map-workflow.md) に記載。複数クライアント、実歩行、景観の画面確認、8/32までのプレイは未確認のまま区別する。

## 関連資料

- [007](007-august-31-terrain-lake-and-clocktime.md)
- [008](008-august-31-landscape-composition.md)
- [制作手順](../production/editable-map-workflow.md)
