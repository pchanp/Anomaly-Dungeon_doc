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
