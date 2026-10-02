# Forest Ferrets (Three.js cinematic)

`forest-ferrets.html` は、白いフェレットとタヌキのフェレットが森を駆け抜ける
15秒ループのシングルファイル・シネマティックです。

## 構成

- 外部依存は `three@0.160.0`（unpkg の ESM）のみ
- モデル・テクスチャ・音源はすべて手続き生成。ダウンロードするアセットはありません
- Web Audio で森の音と着地の衝撃音を手続き生成（最初のクリック後に開始）

## 操作

| 入力 | 動作 |
| --- | --- |
| クリック | 開始（オーディオの有効化） |
| `Space` | 一時停止 / 再開 |
| `R` | 0秒へリセット |
| `D` | FPS 統計の表示切替 |
| `#t=<秒>` | 指定時刻へシーク（決定論的レンダリング用） |

デバッグ用のフック: `window.__seek`, `window.__diag`, `window.__camOverride`, `window.__dbg`

## ローカルでの確認

```bash
python3 -m http.server 8765 --bind 0.0.0.0
# 同じWi-FiのiPhoneなどは http://<MacのLAN IP>:8765/forest-ferrets.html から閲覧できる
```

ブラウザでURLを開き、長押し →「ダウンロード済みのファイルをダウンロード」で
Files に保存できます。

## ステータス

単一HTMLのプロトタイプ（Implemented）。タイムラインは15秒でシームレスにループします。
検証はソフトウェアラスタライザ（SwiftShader）付きのヘッドレス Chrome で行っており、
実GPUでのフレームレートは未計測です。オーディオは実ブラウザのユーザー操作が必要です。