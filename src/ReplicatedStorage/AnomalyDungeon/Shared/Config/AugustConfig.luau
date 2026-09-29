-- 8月31日 config: server clock, evening return portal, 8/32 transition.
-- Thresholds live here so tuning stays in one place; no gameplay formulas are derived from them.
return {
	-- Server clock. Phases run in this order while the map is occupied.
	PhaseOrder={"DAY","EVENING","NIGHT"},
	PhaseSeconds={DAY=480,EVENING=300,NIGHT=300},
	-- The clock waits for the first explorer and pauses when nobody is left inside.
	StartOnFirstEntry=true,
	-- Blend length between two phases, so the change reads as a slow slide rather than a cut.
	PhaseBlendSeconds=24,
	-- Return portal. Available to everyone from the evening, whether or not the quest was completed.
	ReturnFromPhase="EVENING",
	-- 時刻。003では「ClockTimeは変更しない」としていたが、プレースの既定が0時であり、
	-- 8月の湖の町が真夜中に描画されてイメージから崩れるため、フェーズごとに時刻を持たせる。
	-- 8月32日は存在しない日付なので、時刻だけ本来のある時間帯へ戻して日常感を残す。
	ClockTime={DAY=13.5,EVENING=18.4,NIGHT=23.2,AUG_32=23.6},
	-- 8/32. Forced on every exploring player when the night ends; there is no return from it.
	Aug32DateLabel="8月32日",
	Aug32LifetimeSeconds=300,
	-- Exposure gain multiplier once the map is on 8/32. Dangers rise, the map does not respawn.
	Aug32ExposureMultiplier=2.4,
	-- Date board. 8/32 is not a date that exists, but the board keeps printing it.
	DateLabel="8月31日",
	DateBoardClock="14:00",
	-- Tint groups registered by the generator. DAY is the authored look and applies no tint.
	TintGroups={"Ground","Foliage","Structure","Water","Road"},
	Tints={
		DAY={},
		EVENING={
			Ground={Color=Color3.fromRGB(232,148,86),Weight=.45},
			Foliage={Color=Color3.fromRGB(206,132,74),Weight=.5},
			Structure={Color=Color3.fromRGB(226,158,104),Weight=.4},
			Water={Color=Color3.fromRGB(150,116,124),Weight=.5},
			Road={Color=Color3.fromRGB(158,116,100),Weight=.3},
		},
		NIGHT={
			Ground={Color=Color3.fromRGB(38,48,72),Weight=.72},
			Foliage={Color=Color3.fromRGB(26,40,58),Weight=.7},
			Structure={Color=Color3.fromRGB(42,50,72),Weight=.68},
			Water={Color=Color3.fromRGB(22,34,62),Weight=.7},
			Road={Color=Color3.fromRGB(34,40,60),Weight=.65},
		},
		AUG_32={
			Ground={Color=Color3.fromRGB(112,118,96),Weight=.78},
			Foliage={Color=Color3.fromRGB(94,104,80),Weight=.8},
			Structure={Color=Color3.fromRGB(128,132,116),Weight=.75},
			Water={Color=Color3.fromRGB(102,124,110),Weight=.8},
			Road={Color=Color3.fromRGB(118,120,110),Weight=.7},
		},
	},
	-- Map-local environment on the Lighting service. The map owns these only while it is the
	-- active map and restores them on rebuild, so an indoor map is never left tinted.
	-- Lighting has no SkyboxColor / FogDensity / FogEnabled: the sky is driven by Atmosphere below.
	Lighting={
		DAY={Ambient=Color3.fromRGB(138,140,138),OutdoorAmbient=Color3.fromRGB(176,180,176),Brightness=2.4,FogColor=Color3.fromRGB(186,206,212),FogStart=340,FogEnd=1400,ColorShift_Top=Color3.fromRGB(255,252,242),ColorShift_Bottom=Color3.fromRGB(242,248,255)},
		EVENING={Ambient=Color3.fromRGB(122,98,88),OutdoorAmbient=Color3.fromRGB(198,126,82),Brightness=1.7,FogColor=Color3.fromRGB(226,152,106),FogStart=200,FogEnd=900,ColorShift_Top=Color3.fromRGB(255,206,152),ColorShift_Bottom=Color3.fromRGB(255,172,122)},
		NIGHT={Ambient=Color3.fromRGB(30,36,56),OutdoorAmbient=Color3.fromRGB(38,46,74),Brightness=.7,FogColor=Color3.fromRGB(24,30,52),FogStart=110,FogEnd=560,ColorShift_Top=Color3.fromRGB(92,106,162),ColorShift_Bottom=Color3.fromRGB(62,72,122)},
		AUG_32={Ambient=Color3.fromRGB(74,78,68),OutdoorAmbient=Color3.fromRGB(84,90,76),Brightness=1,FogColor=Color3.fromRGB(112,116,102),FogStart=50,FogEnd=320,ColorShift_Top=Color3.fromRGB(172,178,160),ColorShift_Bottom=Color3.fromRGB(152,160,142)},
	},
	-- Map-local environment on the place's existing Atmosphere instance, which carries the sky tint.
	Atmosphere={
		DAY={Color=Color3.fromRGB(198,214,222),Density=.28,Haze=.6,Glare=0},
		EVENING={Color=Color3.fromRGB(255,176,118),Density=.34,Haze=2.2,Glare=.4},
		NIGHT={Color=Color3.fromRGB(44,52,84),Density=.4,Haze=1.2,Glare=.1},
		AUG_32={Color=Color3.fromRGB(158,162,146),Density=.46,Haze=4,Glare=0},
	},
	-- Placeholder ambience. Replace with recorded cicada / wind / radio assets before shipping.
	AmbienceId="rbxasset://sounds/impact_water.mp3",
	AmbienceVolume=.12,
	AmbienceRange=420,
	-- Where 8/32 puts everyone: the open ground in front of the apartment block.
	Aug32SpawnOffset=Vector3.new(0,4,46),
	-- Notices fired to exploring players on each phase change.
	Notice={
		DAY="8月31日 / 夏休み最後の日",
		EVENING="夕方 / バス停に帰還ポータルが出現した",
		NIGHT="夜 / 虫の音が変わった",
		AUG_32="8月32日になった / 帰還先はない",
	},
}
