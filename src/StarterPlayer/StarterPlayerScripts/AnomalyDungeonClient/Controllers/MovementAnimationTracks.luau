local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Provider = game:GetService("KeyframeSequenceProvider")
local Config = require(RS.AnomalyDungeon.Shared.Config.MovementAnimationConfig)
local M = {}
local registered, warned = {}, {}
function M.Load(animator, name)
 local spec = Config[name]
 local animation
 if spec then
  local id = spec.AnimationId
  if id == "" and RunService:IsStudio() then
   if not registered[name] then
    local sequence = RS.AnomalyDungeon.Animations:FindFirstChild(spec.Sequence)
    assert(sequence and sequence:GetAttribute("OrientationProfile") == Config.OrientationProfile, "Missing verified movement sequence: " .. spec.Sequence)
    registered[name] = Provider:RegisterKeyframeSequence(sequence)
   end
   id = registered[name]
  end
  if id == "" then
   if not warned[name] then warn("[MovementAnimations] Publish and set verified " .. name .. " AnimationId"); warned[name] = true end
   -- Preserve existing online movement until these new assets are published.
   animation = RS.MovementAnimations:FindFirstChild(name)
  else
   animation = Instance.new("Animation"); animation.AnimationId = id; animation.Name = spec.Sequence
  end
 else
  animation = RS.MovementAnimations:FindFirstChild(name)
 end
 if not animation then return nil end
 local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
 if spec and animation.Parent == nil then animation:Destroy() end
 if not ok then warn("[MovementAnimations] " .. name .. ": " .. tostring(track)); return nil end
 track.Name = spec and spec.Sequence or name
 track.Priority = name == "Sprint" and Enum.AnimationPriority.Movement or Enum.AnimationPriority.Action
 track.Looped = name ~= "Roll" and name ~= "Shade"
 return track
end
return M
