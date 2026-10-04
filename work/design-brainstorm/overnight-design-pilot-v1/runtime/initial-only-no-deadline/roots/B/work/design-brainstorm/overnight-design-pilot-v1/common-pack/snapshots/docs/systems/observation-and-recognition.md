# 観察・認識システム

**Status: Draft（草案）**

この文書は、Camera、画面内判定、視野角、遮蔽Raycast、継続時間を利用して、プレイヤーが対象を観察していることを近似判定する共通システムを定義する。これは個別アノマリーの意味・報酬・外見を決める資料ではない。認知アノマリーのゲームプレイ意図は[認知アノマリー](../anomalies/cognitive-anomalies.md)を参照する。

## 役割と境界

視野Raycastは単体で「プレイヤーが見た」という事実を証明しない。画面内、Cameraの向き、遮蔽、距離、継続時間などから得る**Observation Evidence（観察の根拠）**の一つである。

共通システムは候補の観察根拠と進行を扱い、個別Map・Anomalyは何を観察対象にするか、どの根拠を要求するか、Recognition後に何を起こすかを決める。以下を一つの `Seen` Bool に統合しない。

| 概念 | 共通システム上の責務 | 個別案が決めること |
| --- | --- | --- |
| Detect | 痕跡や候補を提示できる状態 | 痕跡の種類、表示方法 |
| Observation Evidence | 画面内・角度・遮蔽・距離・時間の評価結果 | 必須条件と許容範囲 |
| Observe | Evidenceが条件を満たしている継続状態 | 進行速度、中断・減衰規則 |
| Visible | Clientで対象を明確に表現できる状態 | 見た目、段階表現 |
| Recognition | 観察条件を満たした識別済み状態 | 個人／Party／共有世界への保存先、後続効果 |

`Detect` と `Visible` は必ずしも視野Raycastを要求しない。`Recognition` の結果として経路・報酬・Exposureなどを変えるかどうかも、共通システムでは決めない。

## 再利用可能な観察パイプライン

```text
Map / Anomaly が観察候補を有効化
    -> Clientが候補を絞る
    -> 画面内・視野角・距離・遮蔽を評価
    -> Observation Evidence を時間的に蓄積
    -> Clientが進行をServerへ要求
    -> Serverが前提と上限を検証
    -> 個人Recognitionまたは共有State Transition
```

Candidateは少なくとも、対象または対象の代表点、最大距離、画面内要件、中心視野の要否、遮蔽判定、必要継続時間、中断時の扱い、Recognitionの保存スコープを指定できるようにする。これらは個別Map・Anomalyごとの設定であり、全候補に同じ数値を強制しない。

遠景の大きなModelや細い対象は、単一中心点だけで判定しない。必要に応じて複数の代表点を使い、「いずれかが画面内」「一定数が画面内」などを個別設定する。

## Client側の観察評価

`Workspace.CurrentCamera` は各ClientのローカルCameraであるため、観察のEvidenceはLocalScriptで評価する。[RobloxのCamera API](https://create.roblox.com/docs/reference/engine/classes/Camera/CameraSubject)にある `WorldToViewportPoint()`、`ViewportPointToRay()`、`Camera.CFrame`、`ViewportSize` を利用できる。

基本候補は次の組み合わせである。

1. 対象の代表点が `WorldToViewportPoint()` で画面内か調べる。
2. Cameraから対象への方向と `Camera.CFrame.LookVector` の角度を使い、中心視野に近いか評価する。
3. Cameraから対象へ `Workspace:Raycast()` し、対象または対象Modelの一部が最初のヒットかを確認する。
4. 最大距離、最小画面領域、継続観察時間、観察中断を組み合わせて進行を更新する。

画面内であること、遮蔽されていないこと、中心を見ていることは別のEvidenceとして残す。Camera方向のみ、距離のみ、キャラクターの向きのみを `Observe` の唯一条件にしない。

## 遮蔽Raycast

`Workspace:Raycast()` は対象までの遮蔽を検証できる。[Raycastingの公式資料](https://create.roblox.com/docs/workspace/raycasting)に従い、`RaycastParams` でプレイヤー自身、観察用の装飾、意図的に無視するPartを除外する。`CanQuery=false` のPartはRaycast対象外にできる。

Raycastは最初の衝突しか返さない。透明装飾、Terrain、複数Partの対象、大型Modelでは、対象の代表点、複数点、Raycast対象に含めるPartを個別に調整する。Raycastの方向ベクトル長が最大検査距離を決める点も設定側で明示する。

## Server権威とRemote境界

ServerはClientのCamera方向・画面内状態・UI被覆状態を直接確認できない。Clientからの観察進行は要求であり、世界状態の証明ではない。

Serverは少なくとも以下を検証してから進行を受理する。

- Candidateが現在のMap・Run・Anomaly状態で有効か。
- 対象が存在し、プレイヤーが正しいRun参加者か。
- プレイヤーキャラクターと対象の概算距離が上限内か。
- 報告頻度、1回あたりの進行量、累積量が許容範囲内か。
- 個人、Party、共有世界のどのRecognitionを更新するか。

経路開放、報酬、Exposure、共有State TransitionはServerだけが確定する。Clientの一回の通知だけで高価値報酬や共有変化を発生させない。

## パフォーマンスと技術的制約

- 全候補に毎フレームRaycastしない。Client側でMap、距離、状態により候補を絞り、必要な候補だけを適切な頻度で評価する。
- `WorldToViewportPoint()` が画面内を返しても、実際の注意、遮蔽、対象の理解は保証しない。Observeは認知の近似である。
- Instance Streaming使用時、遠方PartがClientへ届いていなければRaycastは偽陰性になり得る。遠景候補はStreaming範囲、距離、Detectの代替痕跡を考慮する。
- VR、`CameraType` の変更、Spectator的Camera、画面比率変更は未検証である。最初のプロトタイプは標準Cameraを対象にする。
- Cameraを共有世界のServer事実として保存しない。PlayerのCharacter向きはCamera観察の代替ではない。

## 既存案への適用

| 既存案 | 共通システムとの関係 | 現状 |
| --- | --- | --- |
| Observation / Open Liminal Map | Focus / RecognitionをObservation EvidenceとRecognitionへ接続できる | Idea。具体的条件は未決定 |
| Visible / Invisible Inversion | Visible表現と個人Recognitionの差を扱えるが、答えを直接表示しない | Draft、未実装 |
| Memory Swapper | 認識・記憶の差を個別挙動へ接続できる | Draft、ItemStack等が未実装 |
| MiW | 現在のProximityPromptによる観測は明示Interactionであり、視野観察の実装ではない | プロトタイプ |
| 既存Observer | 近接によるExposure取得であり、視野観察の実装ではない | 実装済みプロトタイプ |

既存の近接判定やPromptを、名前だけを理由に観察システムへ置き換えない。個別のゲームプレイ意図が視野観察を必要とする場合だけ、この共通システムを使う。

## プロトタイプの順序

1. 単一候補に対し、Clientで画面内・角度・遮蔽・距離・継続時間をログ化する。報酬やExposureは接続しない。
2. Client報告をServerが検証し、個人Recognitionだけを更新する。
3. Server確定の小さな共有変化を一つだけ追加し、複数Client・切断・偽の連続報告を確認する。
4. 個別Map、Individual Anomaly、Exposureへの接続を一つずつ評価する。

## 未決事項

- Candidateの静的Definition、Runtime状態、Remote名をどこへ置くか。
- 観察進行の保存期間、中断時の減衰、再観察の扱い。
- Party単位で複数人の観察を要求する条件。
- 実装対象プラットフォームと、VR／Streamingへの対応範囲。
- 不正なClient報告に対する許容度と、報酬規模に応じた追加検証。

## 関連資料

- [アノマリー相互作用](anomaly-interaction.md) — Observation を他の相互作用種別と接続する設計層
- [認知アノマリー](../anomalies/cognitive-anomalies.md)
- [Visible / Invisible Inversion](../anomalies/player-anomalies/visible-invisible-inversion.md)
- [Memory Swapper](../anomalies/memory-swapper.md)
- [マップとギミック案](map-gimmick-ideas.md)
- [ゲームルール](game-rules.md)
