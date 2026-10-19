-- Published IDs must be verified against the anatomical v2 clips before setting.
local ShadeConfig = require(script.Parent.ShadeConfig)
return table.freeze({
 Shade = table.freeze({Sequence = "Shade_R15_v002", AnimationId = "", Duration = 38/24, Speed = ShadeConfig.AnimationSpeed, Fade = 0.04}),
 OrientationProfile = "r15-anatomical-v2",
 Roll = table.freeze({Sequence = "SprintingForwardRoll_R15_v001", AnimationId = "", Duration = 29/30, ActionDuration = 0.6, Fade = 0.025}),
 Sprint = table.freeze({Sequence = "StandardRun_R15_v001", AnimationId = "", Duration = 16/30, Speed = 1.05, Fade = 0.15}),
})
