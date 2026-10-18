local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Config = require(RS.AnomalyDungeon.Shared.Config.TensikeiConfig)
local Damage = require(script.Parent.CombatDamage)
local Timeline = require(script.Parent.TensikeiTimeline).Build(Config.AnimationDuration,Config.AnimationSpeed,Config.AnimationFrontMultiplier,Config.AnimationFrontFraction)
local M = {}
local cooldowns, casts = {}, {}
local studioAnimationId
local function now() return workspace:GetServerTimeNow() end
local function animationId()
 if Config.AnimationId ~= "" and Config.AnimationIdOrientation == "r15-anatomical-v2" then return Config.AnimationId end
 if not RunService:IsStudio() then return nil end
 if not studioAnimationId then
  local sequence = RS.AnomalyDungeon.Animations:FindFirstChild(Config.StudioSequence)
  if sequence and sequence:GetAttribute("OrientationProfile") == "r15-anatomical-v2" then
   local ok,id = pcall(function() return game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(sequence) end)
   if ok then studioAnimationId = id else warn("[TENSIKEI] Studio animation registration failed", id) end
  end
 end
 return studioAnimationId
end
local function play(character,humanoid)
 local id = animationId()
 if not id then warn("[TENSIKEI] Published AnimationId required outside Studio"); return nil end
 local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator",humanoid)
 local animation = Instance.new("Animation"); animation.AnimationId = id
 local ok,track = pcall(function() return animator:LoadAnimation(animation) end)
 animation:Destroy()
 if not ok then warn("[TENSIKEI] Animation load failed",track); return nil end
 track.Priority = Enum.AnimationPriority.Action; track.Looped = false
 -- Wait for cold assets before starting the authoritative attack clock.
 local deadline=os.clock()+3
 while track.Length==0 and humanoid.Parent and humanoid.Health>0 and os.clock()<deadline do task.wait(.03) end
 if track.Length==0 then track:Destroy(); return nil end
 return track
end
local function targetFor(character,root,box)
 local overlap = OverlapParams.new(); overlap.FilterType = Enum.RaycastFilterType.Exclude; overlap.FilterDescendantsInstances = {character}
 local candidates, seen = {}, {}
 for _,part in ipairs(workspace:GetPartBoundsInBox(box,Config.HitboxSize,overlap)) do
  local model = part:FindFirstAncestorOfClass("Model")
  while model and not model:FindFirstChildOfClass("Humanoid") do model = model:FindFirstAncestorOfClass("Model") end
  local hum = model and model:FindFirstChildOfClass("Humanoid")
  local targetRoot = model and model:FindFirstChild("HumanoidRootPart")
  if hum and targetRoot and hum.Health > 0 and not seen[hum] then
   seen[hum] = true
   local ray = RaycastParams.new(); ray.FilterType = Enum.RaycastFilterType.Exclude; ray.FilterDescendantsInstances = {character}
   local obstruction = workspace:Raycast(root.Position,targetRoot.Position-root.Position,ray)
   if not obstruction or obstruction.Instance:IsDescendantOf(model) then candidates[#candidates+1] = {hum=hum,distance=(targetRoot.Position-root.Position).Magnitude} end
  end
 end
 table.sort(candidates,function(a,b)return a.distance<b.distance end)
 return candidates[1] and candidates[1].hum
end
local function hitboxCFrame(root)
 return root.CFrame*CFrame.new(0,0,-Config.HitboxForward)
end
local debugColors={Windup=Color3.fromRGB(95,170,255),Active=Color3.fromRGB(255,165,50),Hit=Color3.fromRGB(80,255,130),Recovery=Color3.fromRGB(155,155,170)}
local function makeDebugHitbox(player,timestamp)
 local enabled=workspace:GetAttribute("TensikeiDebugHitboxes")
 if enabled==nil then enabled=Config.DebugHitboxEnabled end
 if not enabled or (Config.DebugHitboxStudioOnly and not RunService:IsStudio()) then return nil end
 local folder=workspace:FindFirstChild("TensikeiDebug")
 if not folder then folder=Instance.new("Folder");folder.Name="TensikeiDebug";folder.Parent=workspace end
 local part=Instance.new("Part")
 part.Name="TensikeiHitbox";part.Size=Config.HitboxSize;part.Anchored=true
 part.Transparency=1;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false
 part:SetAttribute("OwnerUserId",player.UserId);part:SetAttribute("CastStartedAt",timestamp)
 part:SetAttribute("ActiveStartsAt",timestamp+Timeline.ToElapsed(Config.Windup))
 part:SetAttribute("ActiveEndsAt",timestamp+Timeline.ToElapsed(Config.Windup+Config.HitWindow))
 part:SetAttribute("AnimationEndsAt",timestamp+Timeline.Duration)
 local outline=Instance.new("SelectionBox");outline.Name="Wireframe";outline.Adornee=part
 outline.SurfaceTransparency=1;outline.LineThickness=.035;outline.Parent=part
 part.Parent=folder
 game:GetService("Debris"):AddItem(part,Timeline.Duration+Config.DebugHitboxHold+1)
 return part
end
local function updateDebug(part,box,phase)
 if not part or not part.Parent then return end
 part.CFrame=box;part:SetAttribute("Phase",phase)
 part.Wireframe.Color3=debugColors[phase]
end
function M.TryCast(player)
 if not RunService:IsStudio() and (Config.AnimationId == "" or Config.AnimationIdOrientation ~= "r15-anatomical-v2") then return false,"animation-orientation-unverified" end
 local character=player.Character
 local root=character and character:FindFirstChild("HumanoidRootPart")
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if not root or not humanoid or humanoid.Health<=0 or player:GetAttribute("RunResultPending") or Damage.IsStunned(character) then return false,"unavailable" end
 if now()<(cooldowns[player] or 0) or casts[player] then return false,"cooldown" end
 local token={cancelled=false};casts[player]=token
 local inDungeon,room=player:GetAttribute("InDungeon"),player:GetAttribute("Room")
 local function sameContext()
  return player.Parent==Players and player.Character==character and character.Parent and root.Parent and humanoid.Health>0 and not player:GetAttribute("RunResultPending") and player:GetAttribute("InDungeon")==inDungeon and player:GetAttribute("Room")==room and not Damage.IsStunned(character)
 end
 local function valid() return casts[player]==token and sameContext() end
 local track=play(character,humanoid)
 if not track or not valid() then
  if track then track:Destroy() end
  if casts[player]==token then casts[player]=nil end
  return false,"animation-unavailable"
 end
 local timestamp=now()
 cooldowns[player]=timestamp+Config.Cooldown
 track:Play(Config.AnimationFade,1,Timeline.FrontSpeed)
 character:SetAttribute("TensikeiCastStartedAt",timestamp)
 character:SetAttribute("TensikeiParryUntil",timestamp+Timeline.ToElapsed(Config.ParryDuration))
 character:SetAttribute("TensikeiCastUntil",timestamp+Timeline.Duration)
 character:SetAttribute("TensikeiAnimationSpeed",Timeline.FrontSpeed)
 character:SetAttribute("TensikeiHitWindowStartsAt",timestamp+Timeline.ToElapsed(Config.Windup))
 character:SetAttribute("TensikeiHitWindowEndsAt",timestamp+Timeline.ToElapsed(Config.Windup+Config.HitWindow))
 local debugPart=makeDebugHitbox(player,timestamp)
 updateDebug(debugPart,hitboxCFrame(root),"Windup")
 local function impact(target)
  local amount,result=Damage.Apply(player,target,Config.Damage,{Direct=true})
  if result=="hit" or result=="pvp-floor" then
   Damage.Stun(target,Config.StunDuration)
   local targetCharacter=target.Parent
   local targetPlayer=Players:GetPlayerFromCharacter(targetCharacter)
   local targetRoom=targetPlayer and targetPlayer:GetAttribute("Room")
   local targetInDungeon=targetPlayer and targetPlayer:GetAttribute("InDungeon")
   task.delay(Config.DelayedDamageDelay,function()
    -- The delayed effect is independent of the shortened animation's cleanup.
    if not token.cancelled and sameContext() and target.Parent==targetCharacter and targetCharacter.Parent and target.Health>0 and (not targetPlayer or (targetPlayer.Character==targetCharacter and not targetPlayer:GetAttribute("RunResultPending") and targetPlayer:GetAttribute("Room")==targetRoom and targetPlayer:GetAttribute("InDungeon")==targetInDungeon)) then
     Damage.Apply(player,target,Config.DelayedDamage,{Direct=false})
    end
   end)
  end
  character:SetAttribute("TensikeiLastHitAt",now())
  character:SetAttribute("TensikeiLastHitResult",result)
  character:SetAttribute("TensikeiLastDamage",amount)
 end
 task.spawn(function()
  local hitStart=Timeline.ToElapsed(Config.Windup)
  local hitEnd=Timeline.ToElapsed(Config.Windup+Config.HitWindow)
  local speed=Timeline.FrontSpeed
  local resolved,contact=false,false
  local previousElapsed=-1
  local ok,err=xpcall(function()
   while valid() do
    local elapsed=now()-timestamp
    if elapsed>=Timeline.Duration then break end
    local wantedSpeed=Timeline.SpeedAt(elapsed)
    if speed~=wantedSpeed then
     -- Correct at the boundary so a late Heartbeat doesn't lengthen the fast half.
     track.TimePosition=Timeline.ToSource(elapsed);track:AdjustSpeed(wantedSpeed);speed=wantedSpeed
     character:SetAttribute("TensikeiAnimationSpeed",speed)
    end
    local box=hitboxCFrame(root)
    -- A low-frame-rate crossing still gets one authoritative contact sample.
    local sample=not resolved and elapsed>=hitStart and (elapsed<=hitEnd or previousElapsed<hitStart)
    local phase=elapsed<hitStart and "Windup" or (elapsed<=hitEnd and (contact and "Hit" or "Active") or "Recovery")
    if sample then phase="Active" end
    updateDebug(debugPart,box,phase)
    if sample then
     character:SetAttribute("TensikeiLastQueryCFrame",box)
     local target=targetFor(character,root,box)
     if target then
      resolved=true;contact=true;impact(target)
      updateDebug(debugPart,box,"Hit")
     end
    end
    if elapsed>hitEnd then resolved=true end
    previousElapsed=elapsed
    RunService.Heartbeat:Wait()
   end
  end,debug.traceback)
  token.cancelled=not ok or not valid()
  track:Stop(Config.AnimationFade);track:Destroy()
  if debugPart then
   if token.cancelled then debugPart:Destroy()
   else
    updateDebug(debugPart,debugPart.CFrame,"Recovery")
    task.delay(Config.DebugHitboxHold,function()debugPart:Destroy()end)
   end
  end
  if casts[player]==token then
   casts[player]=nil
   if character.Parent then
    character:SetAttribute("TensikeiParryUntil",nil);character:SetAttribute("TensikeiCastUntil",nil)
    character:SetAttribute("TensikeiAnimationSpeed",nil)
   end
  end
  if not ok then warn("[TENSIKEI] cast failed",err) end
 end)
 return true,Config.Cooldown
end
Players.PlayerRemoving:Connect(function(player) cooldowns[player] = nil; casts[player] = nil end)
return M
