-- TSUTAYA config: archive media, CRT channels, listening stations.
-- Thresholds live here so tuning stays in one place; no gameplay formulas are derived from them.
return {
	-- Archive shelves
	ShelfPromptDistance=10,
	ShelfHoldDuration=.35,
	-- Upper bound on entries one shelf query may return, per medium.
	MaxEntriesPerShelf={VHS=8,DVD=7,CD=9,TAPE=5},
	-- A shelf query hides entries the player has not discovered on this map yet.
	ShelfCoverage=0.55,
	-- CRT
	CrtPromptDistance=10,
	CrtChannelCount=6,
	CrtStaticHoldDuration=.35,
	CrtNoiseId="rbxasset://sounds/electronicpingshort.wav",
	CrtStaticVolume=.25,
	CrtStaticToneId="rbxasset://sounds/impact_water.mp3",
	CrtChannelSwitchDelay=1.1,
	-- Listening stations
	ListenPromptDistance=10,
	PreviewDuration=12,
	ListenHoldDuration=.35,
	PreviewId="rbxasset://sounds/electronicpingshort.wav",
	SharedBgmId="rbxasset://sounds/electronicpingshort.wav",
	SharedBgmVolume=.35,
	SharedBgmRange=110,
	PreviewVolume=.4,
	PreviewRange=70,
	-- Archive Selection UI
	UiOptionObjectText="アーカイブ",
	UiWidth=420,
	UiRowHeight=34,
	UiTitle="ARCHIVE SELECTION",
	UiBackText="棚を閉じる",
	UiNoEntriesText="この棚には何も残っていない。",
}
