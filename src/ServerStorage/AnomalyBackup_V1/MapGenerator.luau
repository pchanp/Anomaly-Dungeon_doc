local M = {}
local C = {stone=Color3.fromRGB(51,59,70), floor=Color3.fromRGB(34,40,49), cyan=Color3.fromRGB(78,221,217), amber=Color3.fromRGB(246,185,87), violet=Color3.fromRGB(179,119,246)}
local function folder(n,p) local f=Instance.new('Folder'); f.Name=n; f.Parent=p; return f end
local function part(n,size,pos,col,p,material)
 local b=Instance.new('Part'); b.Name=n; b.Anchored=true; b.Size=size; b.Position=pos; b.Color=col; b.Material=material or Enum.Material.Concrete; b.Parent=p; return b
end
local function sign(p,text,col)
 local g=Instance.new('BillboardGui'); g.Name='Sign'; g.Size=UDim2.fromOffset(300,70); g.StudsOffset=Vector3.new(0,4,0); g.MaxDistance=75; g.Parent=p
 local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(1,1); t.BackgroundColor3=Color3.fromRGB(13,19,28); t.BackgroundTransparency=.2; t.TextColor3=col or C.cyan; t.Font=Enum.Font.GothamBold; t.TextSize=17; t.TextWrapped=true; t.Text=text; t.Parent=g
end
local function prompt(p,action,kind)
 local q=Instance.new('ProximityPrompt'); q.ActionText=action; q.ObjectText=kind; q.HoldDuration=.35; q.MaxActivationDistance=10; q.RequiresLineOfSight=false; q.Parent=p; return q
end
function M.Build(seed)
 local old=workspace:FindFirstChild('AnomalyDungeon'); if old then old:Destroy() end
 local root=Instance.new('Model'); root.Name='AnomalyDungeon'; root.Parent=workspace; root:SetAttribute('Seed',seed)
 local rooms=folder('Rooms',root); local links=folder('Connections',root)
 local result={Root=root,Rooms={},Prompts={},Relics={},Seed=seed}
 local function room(name,x,z,index,accent,side)
  local m=Instance.new('Model'); m.Name=name; m.Parent=rooms; m:SetAttribute('RoomType',name); m:SetAttribute('Index',index)
  local f={}; for _,n in ipairs({'Geometry','DoorPoints','EnemyPoints','AnomalyPoints','ItemPoints','GimmickPoints','SpecialPoints'}) do f[n]=folder(n,m) end
  local center=Vector3.new(x,1000,z); m:SetAttribute('Center',center)
  part('Floor',Vector3.new(48,2,48),center-Vector3.new(0,1,0),C.floor,f.Geometry)
  for _,sz in ipairs({-1,1}) do
   for _,sx in ipairs({-1,1}) do part('DoorWall',Vector3.new(18,18,2),center+Vector3.new(sx*15,9,sz*24),C.stone,f.Geometry) end
   part('Lintel',Vector3.new(12,6,2),center+Vector3.new(0,15,sz*24),C.stone,f.Geometry)
   local d=part(sz==-1 and 'North' or 'South',Vector3.one,center+Vector3.new(0,3,sz*24),accent,f.DoorPoints); d.Transparency=1; d.CanCollide=false
  end
  part('WestWall',Vector3.new(2,18,48),center+Vector3.new(-24,9,0),C.stone,f.Geometry)
  if not side then part('EastWall',Vector3.new(2,18,48),center+Vector3.new(24,9,0),C.stone,f.Geometry)
  else for _,sz in ipairs({-1,1}) do part('EastWall',Vector3.new(2,18,18),center+Vector3.new(24,9,sz*15),C.stone,f.Geometry) end end
  for _,sx in ipairs({-1,1}) do for _,sz in ipairs({-1,1}) do
   part('Pillar',Vector3.new(3,19,3),center+Vector3.new(sx*21,9.5,sz*21),Color3.fromRGB(69,76,84),f.Geometry)
   local lamp=part('GuideLight',Vector3.new(1,5,1),center+Vector3.new(sx*20,10,sz*20),accent,f.Geometry,Enum.Material.Neon)
   local light=Instance.new('PointLight'); light.Color=accent; light.Range=28; light.Brightness=1.1; light.Parent=lamp
  end end
  local plate=part('RoomLabel',Vector3.new(10,.15,3),center+Vector3.new(0,.12,16),accent,f.Geometry); sign(plate,string.format('%02d / %s',index,name),accent)
  local r={Model=m,Center=center,Folders=f}; table.insert(result.Rooms,r); return r
 end
 local lobby=room('LOBBY',0,90,0,C.cyan); result.Lobby=Vector3.new(0,1004,96)
 local spawn=Instance.new('SpawnLocation'); spawn.Name='LobbySpawn'; spawn.Size=Vector3.new(8,.3,8); spawn.Position=Vector3.new(0,1000.2,98); spawn.Anchored=true; spawn.Neutral=true; spawn.Color=C.cyan; spawn.Material=Enum.Material.Neon; spawn.Parent=lobby.Folders.SpecialPoints
 local function station(r,n,offset,color,text,action)
  local b=part(n,Vector3.new(5,4,3),r.Center+offset,color,r.Folders.GimmickPoints,Enum.Material.Metal); sign(b,text,color); local q=prompt(b,action,n); result.Prompts[n]=q; return b
 end
 station(lobby,'Enter',Vector3.new(0,2,-10),C.cyan,'ANOMALY DUNGEON\n探索 → 遺物回収 → 帰還','探索を始める')
 station(lobby,'Reroll',Vector3.new(15,2,0),C.amber,'MAP SEED / '..seed..'\n全員ロビーで再構成','部屋を並べ替える')
 local names={'CISTERN','OBSERVATORY','HALL'}; local rng=Random.new(seed); for i=#names,2,-1 do local j=rng:NextInteger(1,i); names[i],names[j]=names[j],names[i] end
 local order={'ENTRY',names[1],names[2],names[3],'EXTRACTION'}
 for i,name in ipairs(order) do
  local r=room(name,0,-(i-1)*64,i,name=='OBSERVATORY' and C.violet or C.cyan,name=='OBSERVATORY')
  if i==1 then result.Entry=r.Center+Vector3.new(0,4,12); station(r,'Return',Vector3.new(-13,2,8),C.cyan,'RETREAT\n入口から帰還','帰還する') end
  if i<5 then
   local z=r.Center.Z-32; part('CorridorFloor',Vector3.new(12,2,16),Vector3.new(0,999,z),C.floor,links)
   for _,x in ipairs({-7,7}) do part('CorridorWall',Vector3.new(2,14,16),Vector3.new(x,1007,z),C.stone,links) end
  end
  if name=='CISTERN' then
   local pool=part('HealingPool',Vector3.new(18,.4,18),r.Center+Vector3.new(0,.25,0),C.cyan,r.Folders.GimmickPoints,Enum.Material.Neon); pool.CanCollide=false; pool:SetAttribute('Occupants',0); sign(pool,'泉 / 1人なら回復・2人以上で毒',C.cyan); result.Pool=pool
  elseif name=='OBSERVATORY' then
   local ob=part('Observer',Vector3.new(4,10,4),r.Center+Vector3.new(-8,5,0),C.violet,r.Folders.AnomalyPoints,Enum.Material.Neon); sign(ob,'観測体 / 近づくと SAN 低下',C.violet); result.Observer=ob
   local wall=part('AnomalyGate',Vector3.new(2,12,12),r.Center+Vector3.new(24,6,0),C.violet,r.Folders.SpecialPoints); wall.Transparency=.35
   sign(wall,'境界 / SAN 0 の存在だけが通れる',C.violet); result.Prompts.Secret=prompt(wall,'境界を越える','異常な壁')
   local secret=part('SecretPlatform',Vector3.new(30,2,30),r.Center+Vector3.new(51,-1,0),C.floor,r.Folders.Geometry)
   for _,dz in ipairs({-16,16}) do part('SecretWall',Vector3.new(32,12,2),r.Center+Vector3.new(51,6,dz),C.stone,r.Folders.Geometry) end
   part('SecretBack',Vector3.new(2,12,32),r.Center+Vector3.new(67,6,0),C.stone,r.Folders.Geometry)
   result.SecretSpawn=r.Center+Vector3.new(49,4,0)
   station(r,'AnomalyExit',Vector3.new(59,2,0),C.violet,'OUTSIDE / 異常出口','外側から帰還')
  elseif name=='HALL' then
   result.Hall=r.Center; station(r,'Boss',Vector3.new(0,2,0),C.amber,'何の意味もないボス認定装置','ボスになる')
  elseif name=='EXTRACTION' then station(r,'Extract',Vector3.new(0,2,0),C.cyan,'EXIT / 遺物を持ち帰る\n異常な存在は利用不可','脱出する') end
  if i>=2 and i<=4 then
   local b=part('Relic',Vector3.new(2,2,2),r.Center+Vector3.new(14,2,-10),C.amber,r.Folders.ItemPoints,Enum.Material.Neon); b.Shape=Enum.PartType.Ball; sign(b,'記録片 / 回収',C.amber); local q=prompt(b,'回収','記録片'); table.insert(result.Relics,{Prompt=q,Id=name})
  end
 end
 -- Seal unused exterior doorways; lobby is connected through the expedition prompt.
 for _,r in ipairs(result.Rooms) do
  if r.Model.Name=='LOBBY' or r.Model.Name=='ENTRY' then part('EndCapSouth',Vector3.new(12,12,2),r.Center+Vector3.new(0,6,24),C.stone,r.Folders.Geometry) end
  if r.Model.Name=='LOBBY' or r.Model.Name=='EXTRACTION' then part('EndCapNorth',Vector3.new(12,12,2),r.Center+Vector3.new(0,6,-24),C.stone,r.Folders.Geometry) end
 end
 root:SetAttribute('Route',table.concat(order,' → ')); return result
end
return M
