-- 編集画面のモデルを正本として、Runごとにコピーと参照を作る。
local Workspace=game:GetService("Workspace")
local ServerStorage=game:GetService("ServerStorage")
local RunService=game:GetService("RunService")
local Config=require(game:GetService("ReplicatedStorage").AnomalyDungeon.Shared.Config.AugustConfig)
local M={}
local VECTOR_KEYS={"Lobby","Entry","Aug32Spawn","SecretSpawn"}
local INSTANCE_KEYS={"Observer","Pool","Ambience"}

local function objectValue(name,value,parent)
 local ref=Instance.new("ObjectValue");ref.Name=name;ref.Value=value;ref.Parent=parent
end
local function marker(name,position,parent)
 local p=Instance.new("Part");p.Name=name;p.Size=Vector3.one;p.Position=position
 p.Anchored=true;p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent
 return p
end
-- 明示的な初回変換のみ。既存の編集内容を上書きしない。
function M.Bake(world,parent)
 assert(not RunService:IsRunning(),"Bake is Edit-only")
 local root=world.Root
 assert(root:GetAttribute("MapId")=="AUGUST_31","Wrong map")
 assert(not root:FindFirstChild("_MapBindings"),"Already baked")
 local bindings=Instance.new("Folder");bindings.Name="_MapBindings";bindings.Parent=root
 for _,key in VECTOR_KEYS do marker(key,assert(world[key],key),bindings) end
 for _,key in INSTANCE_KEYS do objectValue(key,assert(world[key],key),bindings) end
 local prompts=Instance.new("Folder");prompts.Name="Prompts";prompts.Parent=bindings
 for name,value in world.Prompts do objectValue(name,value,prompts) end
 local boards=Instance.new("Folder");boards.Name="DateBoards";boards.Parent=bindings
 for i,value in world.DateBoards do objectValue(tostring(i),value,boards) end
 for group,entries in world.Tints do
  for _,entry in entries do entry.Part:SetAttribute("MapTintGroup",group) end
 end
 for _,p in world.GroundTiles do p:SetAttribute("MapGroundTile",true) end
 for _,r in world.Rooms do
  marker("ZoneCenter",r.Center,r.Model)
  r.Model:SetAttribute("Height",r.Height)
 end
 for _,x in root:GetDescendants() do
  if x:IsA("Sound") then x:Stop() end
  if x:IsA("SpawnLocation") then x.Enabled=false end
 end
 root:SetAttribute("KillY",world.KillY)
 root:SetAttribute("AuthoringSchema",1)
 root:SetAttribute("AuthoredSeed",world.Seed)
 root.Name="AUGUST_31";root.Parent=parent
 return root
end

local function decode(root,seed)
 assert(root:GetAttribute("AuthoringSchema")==1,"Unsupported authored map schema")
 local b=assert(root:FindFirstChild("_MapBindings"),"Missing _MapBindings")
 local world={Root=root,Seed=seed,KillY=assert(root:GetAttribute("KillY")),Rooms={},Prompts={},DateBoards={},Tints={},Aug32Parts={},GroundTiles={}}
 for _,group in Config.TintGroups do world.Tints[group]={} end
 for _,key in VECTOR_KEYS do
  local p=assert(b:FindFirstChild(key),"Missing marker "..key);world[key]=p.Position
 end
 for _,key in INSTANCE_KEYS do
  local ref=assert(b:FindFirstChild(key),"Missing reference "..key)
  assert(ref.Value and ref.Value:IsDescendantOf(root),"Broken reference "..key);world[key]=ref.Value
 end
 for _,ref in b.Prompts:GetChildren() do
  assert(ref.Value and ref.Value:IsA("ProximityPrompt") and ref.Value:IsDescendantOf(root),"Broken prompt "..ref.Name)
  world.Prompts[ref.Name]=ref.Value
 end
 assert(world.Prompts.UnlockExit,"Missing UnlockExit")
 for _,ref in b.DateBoards:GetChildren() do
  assert(ref.Value and ref.Value:IsA("TextLabel") and ref.Value:IsDescendantOf(root),"Broken date board")
  table.insert(world.DateBoards,ref.Value)
 end
 for _,model in root.Rooms:GetChildren() do
  local center=assert(model:FindFirstChild("ZoneCenter"),"Missing ZoneCenter "..model.Name)
  local folders={} for _,f in model:GetChildren() do if f:IsA("Folder") then folders[f.Name]=f end end
  table.insert(world.Rooms,{Model=model,Center=center.Position,Width=assert(model:GetAttribute("Width")),Depth=assert(model:GetAttribute("Depth")),Height=assert(model:GetAttribute("Height")),DisplayName=assert(model:GetAttribute("DisplayName")),Folders=folders})
 end
 for _,x in root:GetDescendants() do
  if x:IsA("BasePart") then
   local group=x:GetAttribute("MapTintGroup")
   if group then assert(world.Tints[group],"Unknown tint group "..group);table.insert(world.Tints[group],{Part=x,Base=x.Color}) end
   if x:GetAttribute("Aug32Reveal")==true then table.insert(world.Aug32Parts,x) end
   if x:GetAttribute("MapGroundTile")==true then table.insert(world.GroundTiles,x) end
  end
 end
 return world
end
function M.Validate(root) return decode(root,root:GetAttribute("AuthoredSeed")) end
-- Play時だけ編集用モデルを非表示の保管場所へ移す。StopでEditの状態に戻る。
function M.Initialize()
 assert(RunService:IsRunning(),"Initialize is runtime-only")
 local folder=Workspace:FindFirstChild("MapAuthoring")
 if not folder then return end
 assert(not ServerStorage:FindFirstChild("MapAuthoring"),"Duplicate MapAuthoring")
 local baseline=folder:FindFirstChild("_EditorLightingBaseline")
 if baseline then
  local lighting=game:GetService("Lighting")
  for key,value in baseline:GetAttributes() do lighting[key]=value end
  local a=baseline:FindFirstChild("Atmosphere");local target=lighting:FindFirstChildOfClass("Atmosphere")
  if a and target then for key,value in a:GetAttributes() do target[key]=value end end
 end
 folder.Parent=ServerStorage
end
function M.Build(seed)
 M.Initialize()
 local folder=assert(ServerStorage:FindFirstChild("MapAuthoring"),"Bake AUGUST_31 in Edit first")
 local template=assert(folder:FindFirstChild("AUGUST_31"),"Missing authored AUGUST_31")
 local root=template:Clone()
 local ok,world=pcall(decode,root,seed)
 if not ok then root:Destroy();error(world) end
 local old=Workspace:FindFirstChild("AnomalyDungeon");if old then old:Destroy() end
 root.Name="AnomalyDungeon";root:SetAttribute("Seed",seed);root:SetAttribute("MapPhase","DAY");root:SetAttribute("Aug32Reveal",nil)
 root.Parent=Workspace
 world.Ambience:Play()
 return world
end
return M
