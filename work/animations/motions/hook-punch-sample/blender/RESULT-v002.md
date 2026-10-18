# Hook Punch R15リターゲット再試行

- 実施日: 2026-10-17（JST）
- 状態: Blender焼き込み・保存再読込検証済み。見た目レビュー・正式採用・Studio Importは未完了。
- 実行環境: 開いているBlender 5.2.1 LTS。UIのPython Consoleを通じ実行。
- 入力: 開いていたv001の現在データ。標準Armature（17ボーン、Action・制約なし）、Armature.001（65ボーン、mixamo.com Action、1〜65フレーム）。未保存変更を含んだ可能性があり、ディスク上v001の内容とは同一と断定しない。
- 出力: hook-punch-retarget-v002.blend、標準リグのAction HookPunch_R15_Retarget_v002。
- 方法: armature空間のhead_local/tail_localで基準方向を合わせ、sourceのレストからの回転差をtargetへ適用。階層ごとのローカルQuaternionと腰の移動を毎フレームに焼き込み。15ボーン・63カーブ・4,095キー。
- 保持: 元v001、Source Action。途中の試行ActionはTrial名で保持。処理コードと検証JSONはblend内のTextにも保存。
- 検証: 全65フレームで有限値・姿勢・骨方向・骨長を検査。元との方向差の測定最大0度、骨長差最大約1.58e-6（Blender数値精度範囲）。詳細はretarget-validation-v002.json。
- 再読込: v002を開き直し、対象Action・範囲1〜65・63カーブ・4,095キーの残存をConsoleで確認。複数フレームの標準リグ姿勢変化を画面確認。
- 制約: 方向一致は接地・接触・体型差・メッシュ変形品質の合格を意味しない。元FBX出典・Studio互換性の検証は本試行に含めない。既存スクリプトと文書はResource deadlock avoidedで読み出せず、今回は独立した試行コードを別名保存。標準工程・ツール採否は変更しない。
