-- 正式Runのマップ抽選。候補と重みを分離し、将来の重み付けはWeightsだけを差し替えれば済むようにする。
-- 現時点の重みは必ず同値とし、Quest・所持品・スキル構成などのプレイヤー状態は抽選入力にしない。
-- CLOSED_STACKS はデバッグ用途であり、ここには含めない。
return {
	Candidates={"TSUTAYA","AUGUST_31"},
	Weights={
		TSUTAYA=1,
		AUGUST_31=1,
	},
}
