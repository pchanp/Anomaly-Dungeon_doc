-- SkillServer: server-authoritative skill execution
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Debris=game:GetService("Debris")
local TweenService=game:GetService("TweenService")
local skillEvent=RS:WaitForChild("SkillEvent")
local SKILL_CD={[1]=3,[2]=4,[3]=10}
local serverCd={}
local MAGIC_SPEED=95
local MAGIC_LIFETIME=5
local MAGIC_FIELD_TIME=1.35
local MAGIC_RADIUS=7
local function getChar(p)
 local c=p.Character
 if not c then return nil,nil end
 return c:FindFirstChild("HumanoidRootPart"),c:FindFirstChildOfClass("Humanoid")
end
local function sound(parent,id,volume,speed)
 local s=Instance.new("Sound") s.SoundId=id s.Volume=volume or .7 s.PlaybackSpeed=speed or 1 s.RollOffMaxDistance=75 s.Parent=parent s:Play() Debris:AddItem(s,4) return s
end
local function damageInRadius(player,pos,radius,hit)
 local params=OverlapParams.new() params.FilterType=Enum.RaycastFilterType.Exclude params.FilterDescendantsInstances={player.Character}
 for _,part in ipairs(workspace:GetPartBoundsInRadius(pos,radius,params)) do
  local char=part:FindFirstAncestorOfClass("Model") local hum=char and char:FindFirstChildOfClass("Humanoid")
  if hum and hum.Health>0 and not hit[hum] then hit[hum]=true if not char:GetAttribute("IsInvincible") then hum:TakeDamage(25) end end
 end
end
local function magicImpact(player,pos)
 local field=Instance.new("Part") field.Name="MagicBoltField" field.Shape=Enum.PartType.Ball field.Size=Vector3.new(2,2,2) field.Material=Enum.Material.ForceField field.Color=Color3.fromRGB(85,205,255) field.Transparency=.28 field.Anchored=true field.CanCollide=false field.CanTouch=false field.CanQuery=false field.CFrame=CFrame.new(pos) field.Parent=workspace
 local light=Instance.new("PointLight") light.Color=field.Color light.Range=22 light.Brightness=5 light.Parent=field
 local spark=Instance.new("Sparkles") spark.SparkleColor=Color3.fromRGB(180,245,255) spark.Parent=field
 sound(field,"rbxasset://sounds/impact_water.mp3",1.1,.72)
 TweenService:Create(field,TweenInfo.new(.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=Vector3.new(MAGIC_RADIUS*2,MAGIC_RADIUS*2,MAGIC_RADIUS*2),Transparency=.62}):Play()
 TweenService:Create(light,TweenInfo.new(MAGIC_FIELD_TIME),{Brightness=0,Range=4}):Play()
 local hit={} local finish=os.clock()+MAGIC_FIELD_TIME
 task.spawn(function() while field.Parent and os.clock()<finish do damageInRadius(player,pos,MAGIC_RADIUS,hit) task.wait(.12) end end)
 Debris:AddItem(field,MAGIC_FIELD_TIME)
end
local function magicBolt(player,root)
 local startCf=root.CFrame*CFrame.new(0,1,-3.5) local proj=Instance.new("Part") proj.Name="MagicBolt" proj.Shape=Enum.PartType.Ball proj.Size=Vector3.new(2.6,2.6,2.6) proj.Color=Color3.fromRGB(45,175,255) proj.Material=Enum.Material.Neon proj.Anchored=false proj.CanCollide=false proj.CanTouch=true proj.Massless=true proj.CFrame=startCf proj.Parent=workspace
 proj:SetNetworkOwner(nil)
 local shell=Instance.new("SelectionSphere") shell.Adornee=proj shell.Color3=Color3.fromRGB(170,240,255) shell.SurfaceTransparency=.45 shell.Parent=proj
 local light=Instance.new("PointLight") light.Color=Color3.fromRGB(70,195,255) light.Range=24 light.Brightness=4 light.Parent=proj
 local spark=Instance.new("Sparkles") spark.SparkleColor=Color3.fromRGB(190,245,255) spark.Parent=proj
 local a0=Instance.new("Attachment",proj) a0.Position=Vector3.new(0,0,1.2) local a1=Instance.new("Attachment",proj) a1.Position=Vector3.new(0,0,-1.2)
 local trail=Instance.new("Trail") trail.Attachment0=a0 trail.Attachment1=a1 trail.Lifetime=.35 trail.MinLength=.1 trail.LightEmission=1 trail.Color=ColorSequence.new(Color3.fromRGB(210,250,255),Color3.fromRGB(40,115,255)) trail.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.05),NumberSequenceKeypoint.new(1,1)}) trail.WidthScale=NumberSequence.new({NumberSequenceKeypoint.new(0,1.4),NumberSequenceKeypoint.new(1,0)}) trail.Parent=proj
 sound(proj,"rbxasset://sounds/impact_water.mp3",.9,1.35)
 proj.AssemblyLinearVelocity=root.CFrame.LookVector*MAGIC_SPEED
 local done=false local function impact() if done or not proj.Parent then return end done=true local pos=proj.Position proj:Destroy() magicImpact(player,pos) end
 proj.Touched:Connect(function(other) if other:IsDescendantOf(player.Character) then return end if other.CanCollide or other:FindFirstAncestorOfClass("Model") then impact() end end)
 task.delay(MAGIC_LIFETIME,impact)
end
local function roll(player,root)
 player:SetAttribute("IsInvincible",true) sound(root,"rbxasset://sounds/action_jump_land.mp3",.9,1.05)
 local char=player.Character if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p:SetAttribute("RollOrigTrans",p.Transparency) p.Transparency=math.min(p.Transparency+.3,1) end end end
 task.delay(.6,function() player:SetAttribute("IsInvincible",false) if char and char.Parent then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then local orig=p:GetAttribute("RollOrigTrans") if orig~=nil then p.Transparency=orig p:SetAttribute("RollOrigTrans",nil) end end end end end)
end
local function stealth(player,root,hum)
 player:SetAttribute("IsStealth",true) sound(root,"rbxasset://sounds/impact_water.mp3",.65,.58)
 local char=player.Character if char then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p:SetAttribute("StealthOrigTrans",p.Transparency) p.Transparency=math.max(p.Transparency,.6) end end end hum.WalkSpeed=30
 task.delay(5,function() player:SetAttribute("IsStealth",false) if char and char.Parent then for _,p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then local orig=p:GetAttribute("StealthOrigTrans") if orig~=nil then p.Transparency=orig p:SetAttribute("StealthOrigTrans",nil) end end end local h=char:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=20 end end end)
end
skillEvent.OnServerEvent:Connect(function(player,slot)
 if typeof(slot)~="number" then return end local root,hum=getChar(player) if not root or not hum or hum.Health<=0 then return end
 serverCd[player]=serverCd[player] or {} local now=os.clock() if serverCd[player][slot] and now<serverCd[player][slot] then return end serverCd[player][slot]=now+(SKILL_CD[slot] or 0)
 if slot==1 then magicBolt(player,root) elseif slot==2 then roll(player,root) elseif slot==3 then stealth(player,root,hum) end
end)
Players.PlayerRemoving:Connect(function(p) serverCd[p]=nil end)
print("[SKILL SERVER] ready enhanced")