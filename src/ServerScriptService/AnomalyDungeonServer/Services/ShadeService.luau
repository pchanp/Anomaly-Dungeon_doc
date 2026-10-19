local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local Config = require(game.ReplicatedStorage.AnomalyDungeon.Shared.Config.ShadeConfig)
local Damage = require(script.Parent.CombatDamage)
local M = {}
local active = {}
local function humanoidModel(part)
 local current = part
 while current and current ~= workspace do
  if current:IsA("Model") then
   local hum = current:FindFirstChildOfClass("Humanoid")
   if hum then return current,hum end
  end
  current = current.Parent
 end
end
local function segment(a,b,dir)
 local length = (b-a).Magnitude
 return CFrame.lookAt((a+b)*.5,(a+b)*.5+dir),Vector3.new(Config.HitboxSize.X,Config.HitboxSize.Y,Config.HitboxSize.Z+length)
end
local function debugPart(player,name,color)
 local override = workspace:GetAttribute("ShadeDebugHitboxes")
 if override == false or (override == nil and not Config.DebugEnabled) or (Config.DebugStudioOnly and not RunService:IsStudio()) then return end
 local folder = workspace:FindFirstChild("ShadeDebug")
 if not folder then folder=Instance.new("Folder");folder.Name="ShadeDebug";folder.Parent=workspace end
 local part=Instance.new("Part");part.Name=name;part.Anchored=true;part.Transparency=1
 part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part:SetAttribute("CasterUserId",player.UserId)
 local box=Instance.new("SelectionBox");box.Adornee=part;box.SurfaceTransparency=1;box.LineThickness=.035;box.Color3=color;box.Parent=part
 part.Parent=folder
 return part,box
end
function M.Start(player,root,hum)
 if active[player] or root.Anchored then return false end
 local char=player.Character
 local look=root.CFrame.LookVector
 local dir=Vector3.new(look.X,0,look.Z)
 if dir.Magnitude<.01 then return false end
 dir=dir.Unit
 local start=root.Position;local previous=start;local rotation=root.CFrame.Rotation
 local inDungeon,room=player:GetAttribute("InDungeon"),player:GetAttribute("RoomId")
 local oldAutoRotate=hum.AutoRotate
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Exclude;overlap.FilterDescendantsInstances={char}
 local wall=RaycastParams.new();wall.FilterType=Enum.RaycastFilterType.Exclude;wall.RespectCanCollide=true;wall.IgnoreWater=true;wall.CollisionGroup=root.CollisionGroup
 local excluded={char};wall.FilterDescendantsInstances=excluded
 local function wallCast(from,delta)
  if delta.Magnitude<.00001 then return end
  for _=1,64 do
   local result=workspace:Blockcast(CFrame.new(from)*rotation,root.Size,delta,wall)
   if not result then return end
   local model=humanoidModel(result.Instance)
   if not model then return result end
   table.insert(excluded,model);wall.FilterDescendantsInstances=excluded
  end
  -- A crowded path must not bypass a possible wall behind the crowd.
  return {Distance=0}
 end
 local frame,frameBox=debugPart(player,"ShadeHitbox",Color3.fromRGB(255,170,40))
 local route=debugPart(player,"ShadePath",Color3.fromRGB(160,110,255))
 local function updateDebug(part,cf,size)
  if part then part.CFrame=cf;part.Size=size end
 end
 local firstCf,firstSize=segment(start,start,dir)
 updateDebug(frame,firstCf,firstSize);updateDebug(route,firstCf,firstSize)
 local hit={};local hitCount=0
 local connection,finished
 local state={};active[player]=state
 local function finish(reason)
  if finished then return end;finished=true
  if connection then connection:Disconnect() end
  active[player]=nil
  player:SetAttribute("ShadeDashing",false)
  if char.Parent then char:SetAttribute("ShadeDashEndReason",reason) end
  if root.Parent then
   root.Anchored=false
   root.AssemblyLinearVelocity=Vector3.zero
   local can=root:CanSetNetworkOwnership()
   if can then root:SetNetworkOwnershipAuto() end
  end
  if hum.Parent and hum.AutoRotate==false then hum.AutoRotate=oldAutoRotate end
  for _,part in ipairs({frame,route}) do
   if part then
    if reason=="complete" or reason=="wall" then Debris:AddItem(part,Config.DebugHold) else part:Destroy() end
   end
  end
 end
 state.Cancel=finish
 hum.AutoRotate=false
 -- Brief kinematic dash: fixes height for .3s, lets the path pass characters,
 -- and stops at the server's swept world collision instead of client impulses.
 root.AssemblyLinearVelocity=Vector3.zero;root.Anchored=true
 player:SetAttribute("ShadeDashing",true)
 char:SetAttribute("ShadeDashStartedAt",workspace:GetServerTimeNow())
 char:SetAttribute("ShadeDashDistance",0);char:SetAttribute("ShadeHitCount",0)
 local started=os.clock()
 connection=RunService.PreSimulation:Connect(function(dt)
  if player.Character~=char or not root.Parent or hum.Health<=0 or Damage.IsStunned(char)
   or player:GetAttribute("RunResultPending") or player:GetAttribute("InDungeon")~=inDungeon or player:GetAttribute("RoomId")~=room then finish("cancelled");return end
  local travelled=(previous-start):Dot(dir)
  local remaining=Config.Distance-travelled
  if remaining<=.001 then finish("complete");return end
  -- Avoid a stale anchored cast after a stalled simulation.
  if os.clock()-started>Config.Duration+1 then finish("timeout");return end
  local distance=math.min(Config.Distance/Config.Duration*dt,remaining)
  local obstruction=wallCast(previous,dir*(distance+Config.WallClearance))
  if obstruction then distance=math.min(distance,math.max(0,obstruction.Distance-Config.WallClearance)) end
  local nextPosition=previous+dir*distance
  local cf,size=segment(previous,nextPosition,dir)
  char:SetAttribute("ShadeLastQueryCFrame",cf);char:SetAttribute("ShadeLastQuerySize",size)
  updateDebug(frame,cf,size)
  local wholeCf,wholeSize=segment(start,nextPosition,dir);updateDebug(route,wholeCf,wholeSize)
  root.CFrame=CFrame.new(nextPosition)*rotation
  for _,part in ipairs(workspace:GetPartBoundsInBox(cf,size,overlap)) do
   local model,target=humanoidModel(part)
   if target and model~=char and target.Health>0 and not hit[target] then
    local targetRoot=model:FindFirstChild("HumanoidRootPart")
    if targetRoot then
     local t=math.clamp((targetRoot.Position-previous):Dot(dir),0,distance)
     local point=previous+dir*t
     local delta=targetRoot.Position-point
     local los=RaycastParams.new();los.FilterType=Enum.RaycastFilterType.Exclude
     los.FilterDescendantsInstances={char,model};los.RespectCanCollide=true;los.IgnoreWater=true
     local blocked=delta.Magnitude>.001 and workspace:Raycast(point,delta,los)
     if not blocked then
      hit[target]=true
      local dealt,status=Damage.Apply(player,target,Config.Damage,{Direct=true})
      if status=="hit" and dealt>0 then
       Damage.Stun(target,Config.StunDuration);hitCount+=1
       char:SetAttribute("ShadeHitCount",hitCount);char:SetAttribute("ShadeLastDamage",dealt)
       if frameBox then frameBox.Color3=Color3.fromRGB(80,255,140) end
      end
     end
    end
   end
  end
  previous=nextPosition
  char:SetAttribute("ShadeDashDistance",(previous-start).Magnitude)
  if obstruction then finish("wall") elseif (previous-start).Magnitude>=Config.Distance-.001 then finish("complete") end
 end)
 return true
end
return M
