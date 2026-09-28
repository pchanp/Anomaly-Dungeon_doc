# 制作トラブルシューティング

制作工程で再発し得る問題を蓄積します。各項目には `Symptom`、`Cause`、`Resolution`、`Status` を記載してください。原因が未確認の場合は推測で確定せず、`Unconfirmed（未確認）` とします。

## Rokoko Retargeting UIが表示されない

### Symptom

Rokoko Blender Pluginは有効だが、Retargeting UIを正常に利用できない。

### Cause

BlenderバージョンとRokoko Blender Pluginバージョンの互換性問題が疑われる。対象環境における厳密な組み合わせは未確定。

### Resolution

Current PipelineではRokoko Blender Pluginを必須依存としない。対象Blenderバージョンで動作確認できるリターゲット手段を使用し、Target ArmatureへのBakeとRoblox上の再生を検証する。

### Status

Known issue / Workaround available

### Related

- [判断記録002](../decisions/002-animation-retarget-tool.md)
- [Blenderリターゲット参照](../references/retarget.md)
