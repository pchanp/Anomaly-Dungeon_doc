-- Run終了の種別。サーバーが確定し、Successフラグだけが成功・失敗と所持品の扱いを決める。
-- ラベルはリザルト画面がそのまま表示するため、表示文言をクライアントで創作しない。
-- TRANSFORMED_TIMEOUT は異常化後のRun Lifetime満了で、設計上は未確定。最小版では失敗として扱う。
return {
	SUCCESS={Id="SUCCESS",Label="帰還成功",Success=true},
	RETURN_INCOMPLETE={Id="RETURN_INCOMPLETE",Label="依頼未達の帰還",Success=false},
	DEATH={Id="DEATH",Label="戦闘不能",Success=false},
	DISCONNECT={Id="DISCONNECT",Label="接続の切断",Success=false},
	LIFETIME_EXPIRED={Id="LIFETIME_EXPIRED",Label="8/32 Run Lifetime満了",Success=false},
	TRANSFORMED_TIMEOUT={Id="TRANSFORMED_TIMEOUT",Label="異常化後のRun Lifetime満了",Success=false},
}
