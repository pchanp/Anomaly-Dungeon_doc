-- Shared damage entry for the prototype. No interception of arbitrary Health writes.
local Players = game:GetService("Players")
local Config = require(game.ReplicatedStorage.AnomalyDungeon.Shared.Config.TensikeiConfig)
local M = {}
local stuns = setmetatable({}, {__mode="k"})
local function now() return workspace:GetServerTimeNow() end
local function actorCharacter(actor)
 if typeof(actor) ~= "Instance" then return nil end
 return actor:IsA("Player") and actor.Character or (actor:IsA("Model") and actor or nil)
end
function M.IsStunned(character)
 return character and (character:GetAttribute("CombatStunnedUntil") or 0) > now()
end
function M.Apply(actor, humanoid, amount, options)
 options = options or {}
 if not humanoid or not humanoid.Parent or humanoid.Health <= 0 or type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount == math.huge then return 0,"invalid" end
 local character = humanoid.Parent
 local attacker = actorCharacter(actor)
 if character == attacker then return 0,"self" end
 local victim = Players:GetPlayerFromCharacter(character)
 if character:GetAttribute("IsInvincible") or (victim and victim:GetAttribute("IsInvincible")) or character:FindFirstChildOfClass("ForceField") then return 0,"invincible" end
 if options.Direct and amount <= Config.ParryMaxDamage and (character:GetAttribute("TensikeiParryUntil") or 0) > now() then
  local vr, ar = character:FindFirstChild("HumanoidRootPart"), attacker and attacker:FindFirstChild("HumanoidRootPart")
  if vr and ar then
   local delta = ar.Position-vr.Position
   if delta.Magnitude > .001 and vr.CFrame.LookVector:Dot(delta.Unit) >= Config.ParryFacingDot then
    character:SetAttribute("TensikeiParryCount",(character:GetAttribute("TensikeiParryCount") or 0)+1)
    return 0,"parried"
   end
  end
 end
 local sourcePlayer = attacker and Players:GetPlayerFromCharacter(attacker)
 local damage = amount
 if victim and sourcePlayer and victim:GetAttribute("PlayerAnomalyState") ~= "TRANSFORMED" and sourcePlayer:GetAttribute("PlayerAnomalyState") ~= "TRANSFORMED" then
  damage = math.min(damage, math.max(0,humanoid.Health-humanoid.MaxHealth*.8))
 end
 if damage <= 0 then return 0,"pvp-floor" end
 local before = humanoid.Health
 humanoid:TakeDamage(damage)
 return before-humanoid.Health,"hit"
end
function M.Stun(humanoid, duration)
 if not humanoid or not humanoid.Parent or humanoid.Health <= 0 then return end
 local character = humanoid.Parent
 local entry = stuns[humanoid]
 if entry then entry.expires = now()+duration; character:SetAttribute("CombatStunnedUntil",entry.expires); return end
 local player = Players:GetPlayerFromCharacter(character)
 entry = {expires=now()+duration, saved={}, connections={}, inDungeon=player and player:GetAttribute("InDungeon")}
 stuns[humanoid] = entry
 character:SetAttribute("CombatStunnedUntil",entry.expires)
 for _,property in ipairs({"WalkSpeed","JumpPower","JumpHeight"}) do
  entry.saved[property] = humanoid[property]
  entry.connections[#entry.connections+1] = humanoid:GetPropertyChangedSignal(property):Connect(function()
   if humanoid[property] ~= 0 then entry.saved[property] = humanoid[property]; humanoid[property] = 0 end
  end)
  humanoid[property] = 0
 end
 task.spawn(function()
  while humanoid.Parent and humanoid.Health > 0 and now() < entry.expires do
   if player and (player.Character ~= character or player:GetAttribute("RunResultPending") or player:GetAttribute("InDungeon") ~= entry.inDungeon) then break end
   task.wait(.03)
  end
  for _,connection in ipairs(entry.connections) do connection:Disconnect() end
  if humanoid.Parent then
   for property,value in pairs(entry.saved) do if humanoid[property] == 0 then humanoid[property] = value end end
  end
  if character.Parent then character:SetAttribute("CombatStunnedUntil",nil) end
  stuns[humanoid] = nil
 end)
end
return M
