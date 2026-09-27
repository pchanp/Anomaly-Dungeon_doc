local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local Config=require(RS.AnomalyDungeon.Shared.Config.AnomalyConfig)
local Remotes=RS.AnomalyPrototype.Remotes
local ShowHUD=Remotes.ShowMiWHUD
local Feedback=Remotes.DevNullFeedback
local RunStarted=os.clock()
local eventCount=0
local root,miwModel,nullPart

local function part(parent,name,size,cf,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Parent=parent;return p
end
local function label(p,text,color)
 local g=Instance.new("BillboardGui");g.Size=UDim2.fromOffset(260,70);g.StudsOffset=Vector3.new(0,4,0);g.AlwaysOnTop=true;g.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=.2;t.BackgroundColor3=Color3.fromRGB(8,10,14);t.TextColor3=color or Color3.new(1,1,1);t.TextScaled=true;t.Font=Enum.Font.Code;t.Text=text;t.Parent=g
end
local function prompt(p,action,object)
 local q=Instance.new("ProximityPrompt");q.ActionText=action;q.ObjectText=object;q.HoldDuration=.35;q.MaxActivationDistance=12;q.RequiresLineOfSight=false;q.Parent=p;return q
end
local function aliveCount()
 local n=0;for _,plr in ipairs(Players:GetPlayers()) do local h=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid");if h and h.Health>0 then n+=1 end end;return n
end
local function runInfo()
 local flags={MiWAlive=miwModel and miwModel:GetAttribute("Alive") or false,MiWObserved=miwModel and miwModel:GetAttribute("Observed") or false,DevNullActive=nullPart~=nil}
 return {Players=#Players:GetPlayers(),Alive=aliveCount(),Elapsed=math.floor(os.clock()-RunStarted),Events=eventCount,Depth=workspace:GetAttribute("Depth") or workspace:GetAttribute("Stage") or 0,Flags=flags,Duration=Config.MiWHUDDuration}
end
local function restrict(plr,seconds)
 local untilTime=workspace:GetServerTimeNow()+seconds;plr:SetAttribute("ActionRestrictedUntil",untilTime)
 local h=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid");if not h then return end
 local old=h.WalkSpeed;h.WalkSpeed=math.min(old,Config.PoisonWalkSpeed)
 task.delay(seconds,function() if h.Parent and h.WalkSpeed<=Config.PoisonWalkSpeed then h.WalkSpeed=old end end)
end
local function gas(coffin,plr)
 eventCount+=1
 local emitter=Instance.new("ParticleEmitter");emitter.Color=ColorSequence.new(Color3.fromRGB(70,210,85),Color3.fromRGB(40,80,30));emitter.Rate=90;emitter.Lifetime=NumberRange.new(1.5,3);emitter.Speed=NumberRange.new(4,9);emitter.SpreadAngle=Vector2.new(180,180);emitter.Parent=coffin
 local s=Instance.new("Sound");s.SoundId="rbxasset://sounds/impact_water.mp3";s.Volume=.65;s.Parent=coffin;s:Play()
 local h=plr.Character and plr.Character:FindFirstChildOfClass("Humanoid");if h then h:TakeDamage(Config.PoisonDamage) end;restrict(plr,Config.PoisonRestrictionSeconds)
 task.delay(Config.PoisonRestrictionSeconds,function() if emitter.Parent then emitter.Enabled=false end end)
end
local function cat(parent,cf)
 local m=Instance.new("Model");m.Name="MiW";m:SetAttribute("AnomalyId","MIW");m:SetAttribute("DisplayName","MiW");m:SetAttribute("Active",true);m:SetAttribute("Alive",true);m.Parent=parent
 local body=part(m,"Body",Vector3.new(3.8,2,2),cf,Color3.fromRGB(26,26,30),Enum.Material.SmoothPlastic)
 local head=part(m,"Head",Vector3.new(2.2,2.2,2.1),cf*CFrame.new(2.5,.65,0),Color3.fromRGB(32,32,36))
 part(m,"EarL",Vector3.new(.65,1,.45),head.CFrame*CFrame.new(.2,1.35,-.65)*CFrame.Angles(0,0,.35),body.Color)
 part(m,"EarR",Vector3.new(.65,1,.45),head.CFrame*CFrame.new(.2,1.35,.65)*CFrame.Angles(0,0,-.35),body.Color)
 part(m,"EyeL",Vector3.new(.12,.35,.35),head.CFrame*CFrame.new(1.12,.3,-.55),Color3.fromRGB(90,255,220),Enum.Material.Neon)
 part(m,"EyeR",Vector3.new(.12,.35,.35),head.CFrame*CFrame.new(1.12,.3,.55),Color3.fromRGB(90,255,220),Enum.Material.Neon)
 for _,z in ipairs({-.65,.65}) do for _,x in ipairs({-.9,1}) do part(m,"Leg",Vector3.new(.55,1.4,.55),cf*CFrame.new(x,-1.55,z),body.Color) end end
 part(m,"Tail",Vector3.new(3,.35,.35),cf*CFrame.new(-3,.5,0)*CFrame.Angles(0,0,.35),body.Color)
 label(head,"MiW  [観測可能]",Color3.fromRGB(110,255,230));m.PrimaryPart=body
 local q=prompt(head,"観測する","MiW");q.Triggered:Connect(function(plr) if m:GetAttribute("Alive") then m:SetAttribute("Observed",true);ShowHUD:FireClient(plr,runInfo()) end end)
 return m
end
local function build(base)
 root=Instance.new("Model");root.Name="AnomalyPrototype";root.Parent=workspace:FindFirstChild("DebugFloor") or workspace
 local coffin=Instance.new("Model");coffin.Name="MiWCoffin";coffin:SetAttribute("AnomalyId","MIW");coffin:SetAttribute("Active",false);coffin.Parent=root
 local cf=base*CFrame.new(-18,2,0);local bottom=part(coffin,"Coffin",Vector3.new(10,2,5),cf,Color3.fromRGB(50,24,28),Enum.Material.WoodPlanks)
 local lid=part(coffin,"Lid",Vector3.new(10,.8,5),cf*CFrame.new(0,1.5,0),Color3.fromRGB(75,35,40),Enum.Material.WoodPlanks);label(lid,"MiW / SEALED",Color3.fromRGB(255,190,205))
 local opened=false;prompt(lid,"棺を開ける","MiW").Triggered:Connect(function(plr)
  if opened then return end;opened=true;eventCount+=1;coffin:SetAttribute("Active",true);lid.CFrame*=CFrame.new(0,2,-3)*CFrame.Angles(math.rad(-70),0,0)
  miwModel=cat(root,cf*CFrame.new(0,2,0))
  local poisonTriggered=math.random()<Config.PoisonGasChance
  if poisonTriggered then gas(bottom,plr) end
  if math.random()<Config.MiWDeathChance then miwModel:SetAttribute("Alive",false);miwModel:SetAttribute("Active",false);miwModel:PivotTo(miwModel:GetPivot()*CFrame.Angles(0,0,math.rad(90)));local h=miwModel:FindFirstChild("Head");if h then label(h,"MiW / DEAD",Color3.fromRGB(255,80,90));local q=h:FindFirstChildOfClass("ProximityPrompt");if q then q.Enabled=false end end end  for _,object in ipairs(coffin:GetDescendants()) do
   if object:IsA("BasePart") then object.Transparency=1;object.CanCollide=false;object.CanTouch=false;object.CanQuery=false elseif object:IsA("ProximityPrompt") then object.Enabled=false elseif object:IsA("BillboardGui") then object.Enabled=false end
  end
  if poisonTriggered then task.delay(Config.PoisonRestrictionSeconds+3,function() if coffin.Parent then coffin:Destroy() end end) else coffin:Destroy() end
 end)
 nullPart=part(root,"dev_null",Vector3.new(8,10,2),base*CFrame.new(18,6,0),Color3.fromRGB(3,3,5),Enum.Material.SmoothPlastic);nullPart:SetAttribute("AnomalyId","DEV_NULL");nullPart:SetAttribute("DisplayName","/dev/null");nullPart:SetAttribute("Active",true);label(nullPart,"/dev/null"..string.char(10).."何もしなければ安全",Color3.fromRGB(180,180,190))
 local light=Instance.new("PointLight");light.Color=Color3.fromRGB(85,30,130);light.Range=16;light.Brightness=2;light.Parent=nullPart
end
local debug=workspace:FindFirstChild("DebugFloor") or workspace:FindFirstChild("Debug_Floor") or workspace:WaitForChild("DebugFloor",10)
if not debug or not debug:IsA("Model") then warn("[ANOMALY PROTOTYPE] DebugFloor missing; prototype not built") return end
local floor=debug:WaitForChild("Floor",5)
if not floor or not floor:IsA("BasePart") then warn("[ANOMALY PROTOTYPE] DebugFloor.Floor missing; prototype not built") return end
local base=CFrame.new(floor.Position.X,floor.Position.Y,floor.Position.Z+50)
build(base)

local toolStates={}
task.spawn(function()
 while task.wait(Config.DevNullPollInterval) do
  for _,plr in ipairs(Players:GetPlayers()) do
   local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart");local near=hrp and nullPart and (hrp.Position-nullPart.Position).Magnitude<=Config.DevNullRadius or false
   if plr:GetAttribute("NearDevNull")~=near then plr:SetAttribute("NearDevNull",near) end
   toolStates[plr]=toolStates[plr] or {}
   local containers={plr:FindFirstChildOfClass("Backpack"),plr.Character}
   for _,c in ipairs(containers) do if c then for _,tool in ipairs(c:GetChildren()) do if tool:IsA("Tool") then if near then if toolStates[plr][tool]==nil then toolStates[plr][tool]=tool.Enabled end;tool.Enabled=false elseif toolStates[plr][tool]~=nil then tool.Enabled=toolStates[plr][tool];toolStates[plr][tool]=nil end end end end end
  end
 end
end)
Feedback.OnServerEvent:Connect(function(plr,kind)
 if not plr:GetAttribute("NearDevNull") then return end
 local now=workspace:GetServerTimeNow();plr:SetAttribute("NullifiedUntil",now+Config.DevNullDisableSeconds)
 if kind=="Skill" then plr:SetAttribute("SkillsDisabledUntil",now+Config.DevNullDisableSeconds) elseif kind=="Attack" or kind=="Item" then plr:SetAttribute("AttacksDisabledUntil",now+Config.DevNullDisableSeconds) end
 eventCount+=1;Feedback:FireClient(plr,kind,Config.DevNullDisableSeconds)
end)
Players.PlayerRemoving:Connect(function(p) toolStates[p]=nil end)
