local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")
local shared=ReplicatedStorage:WaitForChild("GiantAnomalyShared")
local Config=require(ReplicatedStorage:WaitForChild("AnomalyDungeon"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("GiantConfig"))
local remotes=shared:WaitForChild("Remotes")
local Stomp=remotes:WaitForChild("GiantStomp")
local UseHeal=remotes:WaitForChild("UseGiantHeal")
local Controller=require(script.Parent:WaitForChild("GiantAnomalyController"))
local old=workspace:FindFirstChild("Anomalies") and workspace.Anomalies:FindFirstChild("GiantAnomaly")
if old then old:Destroy() end
local anomalies=workspace:FindFirstChild("Anomalies") or Instance.new("Folder");anomalies.Name="Anomalies";anomalies.Parent=workspace
local giant=Instance.new("Model");giant.Name="GiantAnomaly";giant.Parent=anomalies
local visual=Instance.new("Model");visual.Name="Model";visual.Parent=giant
local configFolder=Instance.new("Folder");configFolder.Name="Config";configFolder.Parent=giant
for k,v in pairs(Config) do if type(v)=="number" or type(v)=="string" or type(v)=="boolean" then configFolder:SetAttribute(k,v) end end
local debugFloor=workspace:FindFirstChild("DebugFloor") or workspace:WaitForChild("DebugFloor",10)
local floor=debugFloor and (debugFloor:FindFirstChild("Floor") or debugFloor:WaitForChild("Floor",10))
local origin=floor and (floor.Position+Vector3.new(0,13,70)) or Vector3.new(0,15,0)
local function make(name,size,offset,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size*.5;p.Anchored=true;p.CanCollide=false;p.Material=Enum.Material.Slate;p.Color=Color3.fromRGB(62,48,42);p.CFrame=CFrame.new(origin+offset*.5);if shape then p.Shape=shape end;p.Parent=visual;return p
end
local root=make("Root",Vector3.new(4,4,4),Vector3.new(0,-23,0));root.Transparency=1;giant.PrimaryPart=root
local light=Instance.new("PointLight");light.Color=Color3.fromRGB(150,55,45);light.Range=70;light.Brightness=2;light.Parent=root
Controller.Start(giant)
local fields=workspace:FindFirstChild("HealingFields") or Instance.new("Folder");fields.Name="HealingFields";fields.Parent=workspace
local cooldowns={}
local function setLevel(plr,value) plr:SetAttribute("AnomalyLevel",math.clamp(value,0,Config.MaxAnomalyLevel)) end
local function setupPlayer(plr) if plr:GetAttribute("AnomalyLevel")==nil then setLevel(plr,0) end end
Players.PlayerAdded:Connect(setupPlayer);for _,p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerRemoving:Connect(function(p) cooldowns[p]=nil end)
local function makeField(plr)
 local char=plr.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");if not hrp then return end
 local now=workspace:GetServerTimeNow();if now<(cooldowns[plr] or 0) then return end;cooldowns[plr]=now+Config.HealCooldown
 local field=Instance.new("Part");field.Name="GiantHealingField";field.Shape=Enum.PartType.Cylinder;field.Size=Vector3.new(.35,Config.HealRadius*2,Config.HealRadius*2);field.CFrame=CFrame.new(hrp.Position-Vector3.new(0,2.7,0))*CFrame.Angles(0,0,math.rad(90));field.Anchored=true;field.CanCollide=false;field.CanTouch=false;field.CanQuery=false;field.Material=Enum.Material.Neon;field.Color=Color3.fromRGB(85,245,195);field.Transparency=.35;field:SetAttribute("OwnerUserId",plr.UserId);field:SetAttribute("ExpiresAt",now+Config.HealDuration);field.Parent=fields
 local ring=Instance.new("SelectionSphere");ring.Adornee=field;ring.Color3=Color3.fromRGB(180,255,235);ring.SurfaceTransparency=.65;ring.Parent=field
 Debris:AddItem(field,Config.HealDuration+.2)
 task.spawn(function()
  local elapsed=0
  while field.Parent and elapsed<Config.HealDuration do
   local dt=task.wait(Config.UpdateInterval);elapsed+=dt
   for _,target in ipairs(Players:GetPlayers()) do
    local targetRoot=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot and (targetRoot.Position-field.Position).Magnitude<=Config.HealRadius then
     local level=target:GetAttribute("AnomalyLevel") or 0;setLevel(target,level-Config.AnomalyHealPerSecond*dt)
     if Controller.GetState(giant)=="ACTIVE" and (target:GetAttribute("AnomalyLevel") or 0)<=Config.CalmThreshold then
      local calm=math.min(Config.CalmRequired,(giant:GetAttribute("CalmMeter") or 0)+Config.CalmPerSecond*dt);giant:SetAttribute("CalmMeter",calm)
      if calm>=Config.CalmRequired then Controller.SetCalmed(giant,Config.CalmedDuration) end
     end
    end
   end
  end
 end)
end
UseHeal.OnServerEvent:Connect(makeField)
local stompClock=0
local roamTarget=root.Position
local roamNext=0
local random=Random.new()
while giant.Parent do
 local dt=task.wait(Config.UpdateInterval);local now=workspace:GetServerTimeNow();local nearest=math.huge
 for _,plr in ipairs(Players:GetPlayers()) do local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart");if hrp then nearest=math.min(nearest,(hrp.Position-root.Position).Magnitude) end end
 giant:SetAttribute("NearestPlayerDistance",nearest<math.huge and nearest or -1)
 local state=Controller.GetState(giant)
 if state=="CALMED" and now>=Controller.GetCalmedUntil(giant) then Controller.SetAggressive(giant);state=Controller.GetState(giant) end
 if state~="CALMED" and state~="CALMING" then
  local wanted=nearest<=Config.ActiveRadius and "ACTIVE" or nearest<=Config.ApproachRadius and "APPROACHING" or "IDLE"
  if wanted~=state then Controller.SetState(giant,wanted);state=wanted end
 end
 if state~="CALMING" and state~="CALMED" and floor then
  local flatDelta=Vector3.new(roamTarget.X-root.Position.X,0,roamTarget.Z-root.Position.Z)
  if now>=roamNext or flatDelta.Magnitude<2 then
   local margin=18
   local halfX=math.max(5,floor.Size.X*.5-margin)
   local halfZ=math.max(5,floor.Size.Z*.5-margin)
   roamTarget=Vector3.new(floor.Position.X+random:NextNumber(-halfX,halfX),root.Position.Y,floor.Position.Z+random:NextNumber(-halfZ,halfZ))
   roamNext=now+random:NextNumber(Config.RoamPauseMin,Config.RoamPauseMax)
   flatDelta=Vector3.new(roamTarget.X-root.Position.X,0,roamTarget.Z-root.Position.Z)
  end
  if flatDelta.Magnitude>.05 then giant:PivotTo(giant:GetPivot()+flatDelta.Unit*math.min(Config.RoamSpeed*dt,flatDelta.Magnitude)) end
 end
 if state=="ACTIVE" then
  stompClock+=dt
  if stompClock>=Config.StompInterval then stompClock=0;Stomp:FireAllClients(root.Position,Config.StompRadius,Config.CameraShakeMagnitude) end
  for _,plr in ipairs(Players:GetPlayers()) do local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart");if hrp and (hrp.Position-root.Position).Magnitude<=Config.AnomalyRadius then setLevel(plr,(plr:GetAttribute("AnomalyLevel") or 0)+Config.AnomalyIncreasePerSecond*dt) end end
 else stompClock=0 end
end
