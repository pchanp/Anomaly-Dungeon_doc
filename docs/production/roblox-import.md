# Robloxへの導入

**Status: Draft（草案）**

## 目的

Blenderから出力したモデルとAnimationをRoblox Studioへ導入し、実ゲーム相当の条件で利用可能か検証します。

## 標準工程

1. Blenderで対象Mesh、Skeleton、Animation、フレーム範囲を確認する。
2. Roblox向けFBXをExportする。
3. Roblox Studioへ対象モデルまたはRigをImportする。
4. Animation EditorでAnimation FBXをImportする。
5. 対象Rigでプレビューする。
6. AnimationをPublishし、Animation IDと用途を記録する。
7. `Animator` と `AnimationTrack` を用いる実ゲーム相当の経路で再生する。
8. ソロおよび必要に応じて複数クライアントで確認する。

## 確認項目

- Skeleton構造が対象Rigと互換である。
- Animation EditorへのImportで欠落や警告がない。
- NPC用とプレイヤー用の適用先を取り違えていない。
- Animation IDの所有者・公開範囲が体験で利用可能である。
- 優先度、Loop、再生速度、停止条件が用途と一致する。
- Server / Clientのどちらが再生を開始し、誰に複製されるかを確認する。

## 動かない場合

[制作トラブルシューティング](troubleshooting.md) の記録形式に従い、Rig、Animator、Animation ID、権限、優先度、再生主体、Export設定を順に確認します。
