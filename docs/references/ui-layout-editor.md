# UI Layout Editor

**Status: Implemented（実装済み・Prototype）**

## 位置付け

[`tools/ui-layout-editor/`](../../tools/ui-layout-editor/) に置いた、Anomaly Dungeon の2D UIレイアウトを YAML で定義するためのローカルWebエディタです。

このツールはゲーム制作の標準工程の一部ではありません。UIレイアウトの**設計情報**を作る場所であり、実行時のUI.Frameを生成する道具ではありません。

解決しようとしている問題は1つに絞っています。

> LLMが作ったUI部品定義（YAML）を読み込み、人間がブラウザ上でドラッグして配置を調整し、またYAMLに戻す。

## なぜこの分離が必要か

`Layout Definition`（YAML）と `Editor UI`（React）を分離してあります。Reactコンポーネント内に座標をハードコードせず、YAMLが唯一のデータソースです。これにより次のいずれにも分岐できます。

```text
Layout Definition
      ├── Web Preview
      ├── Roblox UI Generator
      └── Documentation / MD
```

いずれも未実装ですが、データモデルはこの前提を壊していません。特にMD埋め込み（`<!-- ui-components:start -->` と `<!-- ui-components:end -->` の間にYAMLを置く構成）は、往復安全性を担保している関係で将来に拡張できます。

## 記録する情報

- 起動手順と利用可能なスクリプト
- YAMLフォーマットとComponent Schema
- 現在の制約（画像のパス永続化、複数選択、propertiesのネスト非対応など）
- 将来拡張候補の優先順位

これらは [`tools/ui-layout-editor/README.md`](../../tools/ui-layout-editor/README.md) を正本とします。このファイルは位置付けとリポジトリ内での扱いだけを記録します。

## ID規約との関係

Layout Definition の `id` と `type` は、コードとジェネレータが依存するシステムIDとして扱う。ゲーム内で表示するラベルは別の値とする。

リポジトリの「システムIDとゲーム内表示名を混同しない」という方針を、UI設計情報の側にもそのまま適用している。

## 未確定・未実装

- Roblox UI Generator（YAMLからScreenGuiを生成する）
- MD内埋め込みの実装
- アセットをLayout Definitionから切り離した配布
- 複数選択、アンカー制約、Auto Layout
