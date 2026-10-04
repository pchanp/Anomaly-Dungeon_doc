# 013: Mad StomperとGIANTプロトタイプの同一性

**Status: Accepted（採用）**
**Date: 2026-10-01**

## 背景

Studio実装には`GIANT`というSystem IDと`Giant Anomaly`というプロトタイプ表示名を持つ巨人がある。一方、設計資料には巨大環境アノマリーとして`Mad Stomper`があり、両者の対応が未確定として残っていた。

このまま別アノマリーとして扱うと、鎮静化、花の胞子、固有スキル、アセット、実装モジュールの参照先が二重になる。また、`Player Anomaly`と`Anomaly Entity`を混同する危険がある。

## 決定内容

`GIANT`、`Giant Anomaly`、`Mad Stomper`は、同一の**Anomaly Entity**を指す。

- `GIANT`は安定したSystem IDとして維持する。
- `Giant Anomaly`は現在のプロトタイプ表示名として扱う。
- `Mad Stomper`は設計上の名称として扱う。
- 最終的なプレイヤー向け表示名は、外見・演出・ローカライズを含めて別途決める。
- Mad Stomperは`Player Anomaly`ではない。Exposureによってプレイヤーへ生じる状態と、外部の巨大Anomaly Entityを混同しない。

この同一性により、Healによる鎮静化と、左足を肥大化させる花の胞子を固有品として扱う設計は、同じアノマリー資料へ集約する。花の胞子に対応する専用スキルの名称・効果は未決定である。

## 影響

- 今後のコード、定義、Remote、アセット参照では`GIANT`をSystem IDとして使う。
- プレイヤー向け表示名を変える場合でも、System IDを変更しない。
- `Mad Stomper`資料を、巨人プロトタイプの設計上の正本として扱う。
- 過去資料中の「対応未確定」という記述を更新する。

## 関連資料

- [Mad Stomper](../anomalies/mad-stomper.md)
- [アノマリー相互作用](../systems/anomaly-interaction.md)
- [現在の実装状況](../systems/current-implementation.md)
- [アノマリー相互作用による固有スキル取得](012-anomaly-linked-skill-acquisition.md)
