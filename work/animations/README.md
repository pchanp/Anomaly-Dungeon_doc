# アニメーション作業フォルダ

Mixamoを通常モーションの編集元とし、特殊モーションはDeepMotion等から取得する。標準工程は[アニメーション制作パイプライン](../../docs/production/animation-pipeline.md)を参照する。

制作ワークショップでは **W05** に対応する。[共通契約](../../docs/production/workshop/shared/handoff.md)に沿って既存motions内の記録を参照し、元データ・出力・検証版を固定する。R15と独自Rigの成立を別々に検証する。現在の記録の更新差は [棚卸し](../../docs/production/workshop/inventory-2026-10-14.md)を参照。

```text
animations/
├── rigs/                  # 共通の対象Rig（FBX / .blend）
├── templates/             # 再利用するリターゲット用.blend
└── motions/
    └── <作業名>/
        ├── README.md      # 出所・編集・検証状況
        ├── source/        # 取得した元Animation FBX（原本を保持）
        ├── blender/       # リターゲット・編集用.blend
        ├── export/        # Robloxに取り込むAnimation FBX
        └── preview/       # 比較用動画・画像
```

## 使い方

1. `motions/_template/`を複製し、モーションを識別できる作業名に変更する。作業名はゲームのSystem IDを確定するものではない。
2. 元FBXを`source/`へ置く。
3. 再利用するリターゲットファイルがあれば`templates/`へ原本を置き、各モーションの`blender/`へコピーして編集する。
4. 編集ファイルは例として`<作業名>-retarget-v001.blend`、出力は`<作業名>-roblox-v001.fbx`のように版を付ける。
5. `README.md`にRig・Action・フレーム範囲・検証結果を記録する。

FBX、Blenderファイル、動画はこのフォルダの`.gitignore`でGit対象から除外する。ローカルファイルのバックアップは別途必要。公式R15配布原本は[`rigs/roblox-r15-official/`](rigs/roblox-r15-official/README.md)に保管する。

## W05固定手順（2026-10-17採用）

Mixamoから公式R15への通常作業は[保存済みスクリプトと実行手順](scripts/README.md)を使う。`scripts/retarget_mixamo_r15.py`で基準姿勢補正・Bake・数値検査・指定時の版付き保存／FBX出力を一括実行する。対話操作の記憶だけに依存しない。

- 対象Rig、Source Action、版、範囲、Root Modeを固定して実行する。
- `Bone.vector`を基準方向に用いず、`tail_local-head_local`を使う。
- 保存後の再読込を必須とする。Sourceだけ動く状態を完了にしない。
- 通常FBX Importの余分なルート・軸は、同READMEの保存済みPose変換／Studio導入アダプタで処理する。
- 人間の見た目レビュー、公開ID、実ゲーム再生は独立した通過条件。独自Rigへ無条件適用しない。

### 方向検査を必須化

前後逆の原因となった旧Pose exporter v1を廃止。現在はanatomical v2で「前−Z・右+X・上+Y」を明示し、旧形式はImportで停止する。[固定手順・回帰検査](scripts/README.md#前後逆を防ぐ必須ゲートanatomical-v2)を実行してからPublishする。SourceとTargetの数値一致・Track再生成功だけで導入完了にしない。
