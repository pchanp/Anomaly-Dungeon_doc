-- Prototype tuning only; values are not accepted balance or permanent skill IDs.
return table.freeze({
 DisplayName = "纏絲勁", Slot = 4, Cooldown = 4,
 Damage = 25, DelayedDamage = 8, DelayedDamageDelay = 0.4, StunDuration = 0.5,
 -- These phase times use source-clip seconds; TensikeiTimeline maps to wall time.
 Windup = 0.5, HitWindow = 0.12,
 HitboxSize = Vector3.new(4, 5, 5), HitboxForward = 3,
 ParryDuration = 0.55, ParryMaxDamage = 10, ParryFacingDot = 0,
 -- Keep the old published ID for traceability; it uses the reversed v1 basis.
 AnimationId = "rbxassetid://95405144949752", AnimationIdOrientation = "legacy-v1",
 StudioSequence = "HookPunch_R15_v005",
 AnimationSpeed = 2, AnimationFrontMultiplier = 1.5, AnimationFrontFraction = 0.5,
 AnimationDuration = 64/30, AnimationFade = 0.04,
 DebugHitboxEnabled = true, DebugHitboxStudioOnly = true, DebugHitboxHold = 0.2,
})
