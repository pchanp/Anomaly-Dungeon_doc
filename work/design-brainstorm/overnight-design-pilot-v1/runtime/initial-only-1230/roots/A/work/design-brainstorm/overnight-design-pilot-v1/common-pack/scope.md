# 対象範囲と終了条件

**Status: Draft（今回の候補生成用の契約）**

成果は設計候補だけ。基礎部品の実装、ゲームデータの配置、採用、統合を含めない。現在の正式Runは `TSUTAYA` / `AUGUST_31` から1マップを選んで戻る範囲であり、今回の4マップ文脈のブレストは実装対象の追加ではない。

## 件数と予約枠

| 各担当の末尾番号 | 主な文脈 | 件数 | 基準状態 |
| --- | --- | ---: | --- |
| 001〜003 | 8/31 | 3 | マップPrototype: Implemented。候補自体はIdea/Draft。 |
| 004〜006 | 廃TSUTAYA | 3 | マップPrototype: Implemented。媒体の実内容・選曲等は未実装。 |
| 007〜009 | SEKIGAHARA | 3 | Idea。史実の戦場ではない。勢力・地形・戦況は未確定。 |
| 010〜012 | 研究所 | 3 | 元同僚・whisperのDraftと判断018を根拠とする。建物構造は未確定。 |
| 013〜015 | 全マップ共通 | 3 | 複数文脈で成立し得る候補。全マップへの配置や出現を保証しない。 |

主対象マップは設計文脈。B/Cでマップ限定入手・使用・習得を意味しない。Aでは `マップ固有` / `全マップ共通` と分類する。

## 役割

- **A**: ギミックイベント・NPC。共通3件のうち少なくとも1件はイベントから通常モブ敵が発生する案。発生条件・上限・戦闘以外の対応・退場条件・Anomaly Entityとの差を記す。通常NPCはその場の目的を持つ。
- **B**: アイテム。取得・所持・使用・提示・配置・喪失・Secure Slot・売却・Quest・Anomaly Interactionの全経路について、関係あり／未確定／対象外を明記する。保持・使用・譲渡等の判断を作る。
- **C**: スキル。ギミックへのアクションと、環境・アノマリー・モブへの回避／対処を重視する。何を避け、何へ介入し、何を犠牲にするかを書く。4系統・ランク・レベル1〜3・4枠・通常攻撃連携を参照する。

各候補の名前は作業用の見出し。正式System IDやゲーム内名称に昇格させない。似た仕組みの名称・数値・マップだけを替えた案は別候補に数えない。

## 必読資料

パック内 `snapshots/` をrootとして以下を読む。

1. `AGENTS.md`、`README.md`。
2. `docs/world/setting.md`、`information-design.md`、`anomaly-worldview.md`。
3. `docs/systems/effect-components.md`、`anomaly-interaction.md`、`game-rules.md`、`map-gimmick-ideas.md`、`current-implementation.md`、`skill-build.md`、`quests.md`。
4. `docs/anomalies/whisper.md`、`docs/decisions/018-whisper-colleague-quest-and-anxiety.md`、`021-effect-categories-lifetime-and-stacking.md`。
5. 自分の案に関係する `docs/anomalies/`、`docs/decisions/`。Bは経済・010〜012、Cは012・019、Aは003・007〜009・005を追加確認する。

明示的に既存アノマリーへ作用する案では、その個別MDを読む。HealやSound等のタグだけで全Anomaly Entityへの有効性を保証しない。

## 成果物と完了

担当出力rootに `ROLE-X-NNN.html` と同名の `.json` を15組、`index.html`、`manifest.json`、`board.css`、`progress.json`、`events.jsonl`、`handoff.md` を置く。スクリーンショットを取れる場合は `preview/` に保存してよい。

各HTMLは少なくとも1つの候補固有のインラインSVGを持つ。外部スクリプト・フォント・画像・CDN不要で開ける。メタデータと人間が読む本文の両方に必須内容を載せる。

15組と各分類3件が揃い、final機械検証が通り、表示確認結果と未解決事項をhandoffへ記録したら担当作業を終了する。確認できない表示・時間・モデル情報は未確認のまま報告する。期限／予算／停止に達した場合は実数を保存し、空ファイルで件数を埋めない。
