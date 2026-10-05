# 018: whisperの元同僚Quest、anxiety、他マップ出現解放

**Status: Accepted（採用済み）**
**Date: 2026-10-02**

## 背景

博士のQuestは、アノマリーの意味を説明するためではなく、明確な目的を持つ相互作用へプレイヤーを導くものとする。`whisper` は、不可解な音響・UIだけで終わらせず、追従先をNPCへ移す行為を世界側の変化へ接続する必要がある。

また、特定アノマリーとの最初のQuest体験が、その後の出現候補や専用スキルに影響し得る構造を定める。

## 決定

- `whisper` はInvisibleだが実体を持ち、出現時に定まるプレイヤーへ付き従うAnomaly Entityとする。
- 攻撃せず、表示された選択UIを選ばないことは表示をやり過ごす対処である。ただし、表示消失は撃退・解決・報酬獲得ではない。
- `whisper` を伴ったプレイヤーが博士の元同僚NPCへ接触すると、追従先は元同僚へ移る。元同僚が研究機材へ閉じこもった後に残る装置を博士へ渡すことで、専用スキル `anxiety` を得る。
- `anxiety` は対象の内側に `whisper` を発生させるスキルとする。通常NPCは不快音として気味悪がる反応を基本とし、潜在要素を持つ対応NPC・Anomaly Entityでは、隠された状態やエピソードを引き出す個別の相互作用を受理し得る。
- 博士は `whisper` が効かない例外とする。博士は迷いなく自分を信じているため、`anxiety` による不快音反応も、潜在要素の引き出しも起こさない。
- この元同僚Questを達成すると、`whisper` は研究所マップ以外でも出現候補になる。
- Party Runでは、開始時Partyにこの候補解放実績を持つプレイヤーが一人でもいれば、`whisper` を他マップの候補にも加える。実績を持たないPartyメンバーにとっては、他マップでの初遭遇になり得る。
- この候補解放は、博士Quest受注中の個別出現確率1.40倍補正とは別であり、マップ抽選そのものを変更しない。

## 判断理由

追従先の移送を主要Interactionにすることで、`whisper` を単なる驚かせる演出や、ポップアップを消すミニゲームにしない。装置と元同僚の不在を残すことで、Questの目的は明確にしながら、装置の正体・人物の行方・博士の意図を断定しない。

`anxiety` は全対象への万能な精神攻撃や状態異常ではなく、対象内の `whisper` を通じて、潜在的な要素を引き出す個別Interactionの接続点とする。博士が効かない例外は、博士の確信を説明しすぎずに示す。Quest達成後のParty候補解放は、未遭遇のPartyメンバーにも同一アノマリーを別文脈で初遭遇させる進行とする。

## 影響

- 個別仕様は[whisper](../anomalies/whisper.md)で管理する。
- `Sound`、`Skill`、`Environment`、NPC接触を[Anomaly Interaction](../systems/anomaly-interaction.md)の共通層へ接続する。
- Quest／Discoveryのデータモデルには、Run単位の出現補正と区別した候補解放実績と、開始時Partyから候補を確定する余地が必要になる。
- UI演出はゲーム内に限定し、OS・Robloxクライアントなど実環境の警告や操作を模倣して実行しない。

## 未決定事項

- `whisper` と `anxiety` のSystem ID。
- 対象プレイヤーの選定、同時出現上限、出現確率、Questの詳細UI。
- `anxiety` によって潜在要素を引き出せるNPC・Anomaly Entityと各結果。
- 候補解放実績の保存、途中切断後の候補状態、例外マップ、再発生条件。

## 関連資料

- [whisper](../anomalies/whisper.md)
- [クエスト](../systems/quests.md)
- [Anomaly Interaction](../systems/anomaly-interaction.md)
- [015: 博士Questによるアノマリー出現補正](015-professor-quest-anomaly-spawn.md)
