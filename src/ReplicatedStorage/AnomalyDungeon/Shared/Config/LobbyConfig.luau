-- 暫定のロビー配置。機能検証用の最小構造であり、最終アートでも2Dワールドマップでもない。
-- 都市ロビーとダンジョン入口ロビーは、生成ダンジョンモデルとは別の常設Runtimeモデルとして作る。
return {
	CityOrigin=Vector3.new(-1600,0,0),
	CitySize=Vector3.new(160,1,160),
	CitySpawnOffset=Vector3.new(0,3,50),
	CityEntrancePadOffset=Vector3.new(0,1,-45),
	CityResultPadOffset=Vector3.new(-55,3,10),
	CityBoardOffset=Vector3.new(40,10,50),

	EntranceOrigin=Vector3.new(1600,0,0),
	EntranceSize=Vector3.new(160,1,160),
	EntranceArrivalOffset=Vector3.new(0,3,55),
	EntranceReturnPadOffset=Vector3.new(0,1,-55),
	EntranceBoardOffset=Vector3.new(-45,10,55),

	-- パーティ用フィールド。範囲判定はこの箱のXZ寸法とY許容で行い、Touchではなくサーバー側polled判定に寄せる。
	PartyFieldCenter=Vector3.new(0,1,0),
	PartyFieldSize=Vector3.new(70,1,70),
	PartyFieldYTolerance=14,

	ForceClosePadOffset=Vector3.new(0,2,-40),
	ForceCloseAction="受付を強制締切する",
	ForceCloseObject="DEBUG 強制締切",

	-- パーティ受付の上限。最初の参加者からRecruitSecondsで締め切り、その時点の参加者で出発する。
	PartyMax=5,
	RecruitSeconds=30,
}
