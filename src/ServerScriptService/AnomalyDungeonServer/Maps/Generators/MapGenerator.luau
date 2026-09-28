-- CLOSED STACKS: modular retail blockout. All dimensions are studs.
local MapDefinitions=require(game:GetService('ReplicatedStorage').AnomalyDungeon.Shared.Definitions.MapDefinitions)
local M={}
local C={wall=Color3.fromRGB(167,166,151),floor=Color3.fromRGB(118,119,111),blue=Color3.fromRGB(26,61,103),yellow=Color3.fromRGB(236,203,70),dark=Color3.fromRGB(47,52,57),cyan=Color3.fromRGB(80,218,202),violet=Color3.fromRGB(157,108,195)}
local function folder(n,p) local f=Instance.new('Folder'); f.Name=n; f.Parent=p; return f end
local function part(n,size,pos,col,p,mat)
 local b=Instance.new('Part'); b.Name=n; b.Anchored=true; b.Size=size; b.Position=pos; b.Color=col; b.Material=mat or Enum.Material.SmoothPlastic; b.TopSurface=Enum.SurfaceType.Smooth; b.BottomSurface=Enum.SurfaceType.Smooth; b.Parent=p; return b
end
local function textFace(b,text,face)
 local g=Instance.new('SurfaceGui'); g.Face=face or Enum.NormalId.Front; g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; g.PixelsPerStud=24; g.Parent=b
 local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.TextColor3=C.yellow; t.Font=Enum.Font.GothamBold; t.TextScaled=true; t.TextWrapped=true; t.Text=text; t.Parent=g
 local pad=Instance.new('UIPadding'); pad.PaddingTop=UDim.new(.08,0); pad.PaddingBottom=UDim.new(.08,0); pad.PaddingLeft=UDim.new(.04,0); pad.PaddingRight=UDim.new(.04,0); pad.Parent=t
end
local function sign(b,text,color)
 local g=Instance.new('BillboardGui'); g.Name='Sign'; g.Size=UDim2.fromOffset(250,58); g.StudsOffset=Vector3.new(0,4,0); g.MaxDistance=40; g.Parent=b
 local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(1,1); t.BackgroundColor3=C.dark; t.BackgroundTransparency=.15; t.TextColor3=color or C.yellow; t.TextSize=15; t.TextWrapped=true; t.Font=Enum.Font.GothamMedium; t.Text=text; t.Parent=g
end
local function prompt(b,action,name)
 local q=Instance.new('ProximityPrompt'); q.ActionText=action; q.ObjectText=name; q.HoldDuration=.35; q.MaxActivationDistance=10; q.RequiresLineOfSight=false; q.Parent=b; return q
end
-- Door letters: N=-Z, S=+Z, E=+X, W=-X. Adjacent spaces share 22-stud passages.
local specs={
 {'LOBBY','00 / CLOSED STACKS',0,160,80,64,1000,'',false},
 {'ENTRY','01 / DVD RENTAL',0,0,120,100,1000,'N',false},
 {'HALL','02 / INFORMATION',0,-132,140,112,1000,'NSEW',false},
 {'BOOKS','03 / BOOKS & MAGAZINES',-158,-132,120,112,1000,'EN',false},
 {'CISTERN','04 / CD & LISTENING',158,-132,120,112,1000,'WN',false},
 {'OBSERVATORY','06 / VHS ARCHIVE',-158,-266,120,112,1000,'SE',true},
 {'GAMES','05 / GAMES',158,-266,120,112,1000,'SW',false},
 {'REGISTER','07 / RETURNS & CASHIER',0,-266,140,112,1000,'NSEW',false},
 {'STAFF','08 / STAFF ONLY',0,-380,90,76,1000,'NS',true},
 {'WAREHOUSE','09 / STOCKROOM',0,-486,120,96,1000,'NS',true},
 {'EXTRACTION','B1 / PARKING',0,-666,160,128,976,'S',true},
 {'OUTSIDE','? / RETURN TO SENDER',-300,-266,64,64,1000,'',true},
}
function M.Build(seed,preview)
 local old=workspace:FindFirstChild('AnomalyDungeon'); if old then old:Destroy() end
 local root=Instance.new('Model'); root.Name='AnomalyDungeon'; root.Parent=workspace; root:SetAttribute('Seed',seed); root:SetAttribute('Theme','Closed media megastore'); root:SetAttribute('Version',2); root:SetAttribute('MapId',MapDefinitions.CLOSED_STACKS.Id); root:SetAttribute('MapDisplayName',MapDefinitions.CLOSED_STACKS.DisplayName)
 local rooms=folder('Rooms',root); local links=folder('Connections',root); local roofs=folder('Roofs',root)
 local result={Root=root,Rooms={},Prompts={},Seed=seed,KillY=940}; local by={}; local rng=Random.new(seed)
 local function roof(n,size,pos)
  local b=part(n,size,pos,Color3.fromRGB(101,105,103),roofs); b.Transparency=preview and 1 or 0; b:SetAttribute('PreviewHidden',true); return b
 end
 local function board(r,name,pos,size,text)
  local b=part(name,size,r.Center+pos,C.blue,r.Folders.Geometry); textFace(b,text); textFace(b,text,Enum.NormalId.Back); return b
 end
 local function localPart(r,n,size,pos,color,mat) return part(n,size,r.Center+pos,color,r.Folders.Geometry,mat) end
 for index,s in ipairs(specs) do
  local n,title,x,z,w,d,y,doors,dim=table.unpack(s)
  local model=Instance.new('Model'); model.Name=n; model.Parent=rooms
  local f={}; for _,key in {'Geometry','DoorPoints','EnemyPoints','AnomalyPoints','ItemPoints','GimmickPoints','SpecialPoints'} do f[key]=folder(key,model) end
  local r={Model=model,Center=Vector3.new(x,y,z),Width=w,Depth=d,Height=22,DisplayName=title,Folders=f}; by[n]=r; table.insert(result.Rooms,r)
  model:SetAttribute('Center',r.Center); model:SetAttribute('Width',w); model:SetAttribute('Depth',d); model:SetAttribute('DisplayName',title)
  localPart(r,'Floor',Vector3.new(w,2,d),Vector3.new(0,-1,0),dim and Color3.fromRGB(83,88,86) or C.floor,Enum.Material.Concrete)
  roof(n..'_Ceiling',Vector3.new(w,1,d),r.Center+Vector3.new(0,22.5,0))
  for _,side in {'N','S','E','W'} do
   local alongX=side=='N' or side=='S'; local span=alongX and w or d; local edge=(alongX and d or w)/2; local direction=(side=='S' or side=='E') and 1 or -1
   local function wallSegment(len,offset,height,yoff)
    local size=alongX and Vector3.new(len,height,2) or Vector3.new(2,height,len)
    local pos=alongX and Vector3.new(offset,yoff,direction*edge) or Vector3.new(direction*edge,yoff,offset)
    localPart(r,'Wall_'..side,size,pos,C.wall)
   end
   if string.find(doors,side,1,true) then
    local segment=(span-22)/2; wallSegment(segment,22/2+segment/2,22,11); wallSegment(segment,-22/2-segment/2,22,11); wallSegment(22,0,6,19)
    local pos=alongX and Vector3.new(0,3,direction*edge) or Vector3.new(direction*edge,3,0)
    local marker=part(side,Vector3.one,r.Center+pos,C.yellow,f.DoorPoints); marker.Transparency=1; marker.CanCollide=false
   else wallSegment(span,0,22,11) end
  end
  for ix=-1,1 do for iz=-1,1 do
   local lx=ix*(w/2-17); local lz=iz*(d/2-15); local on=not dim or rng:NextNumber()>.38
   local b=localPart(r,'Fluorescent',Vector3.new(12,.3,1.7),Vector3.new(lx,21,lz),on and Color3.fromRGB(229,237,218) or C.dark,on and Enum.Material.Neon or Enum.Material.SmoothPlastic)
   if on then local light=Instance.new('PointLight'); light.Color=Color3.fromRGB(222,232,211); light.Range=42; light.Brightness=dim and .65 or 1.4; light.Shadows=false; light.Parent=b end
  end end
  -- Front signage is part of the architecture, rather than a floating UI label.
  board(r,'SectionSign',Vector3.new(0,17,d/2-5),Vector3.new(math.min(w-10,52),5,.5),title)
  for _,sx in {-1,1} do for _,sz in {-1,1} do localPart(r,'Column',Vector3.new(3,22,3),Vector3.new(sx*(w/2-7),11,sz*(d/2-7)),C.wall) end end
  if not dim then
   for tx=-math.floor(w/24),math.floor(w/24) do localPart(r,'TileJoint',Vector3.new(.06,.025,d-2),Vector3.new(tx*12,.02,0),Color3.fromRGB(85,88,83)) end
   for tz=-math.floor(d/24),math.floor(d/24) do localPart(r,'TileJoint',Vector3.new(w-2,.025,.06),Vector3.new(0,.02,tz*12),Color3.fromRGB(85,88,83)) end
  end
 end
 local function connect(a,b)
  local A,B=by[a],by[b]; local delta=B.Center-A.Center; local alongX=math.abs(delta.X)>math.abs(delta.Z)
  local u=alongX and Vector3.new(math.sign(delta.X),0,0) or Vector3.new(0,0,math.sign(delta.Z))
  local start=A.Center+u*(alongX and A.Width/2 or A.Depth/2); local finish=B.Center-u*(alongX and B.Width/2 or B.Depth/2)
  local len=(finish-start).Magnitude; local mid=(start+finish)/2
  local f=folder(a..'_to_'..b,links)
  local floor=part('Walkway',Vector3.new(22,2,len+.5),mid-Vector3.new(0,1,0),C.floor,f,Enum.Material.Concrete); floor.CFrame=CFrame.lookAt(mid-Vector3.new(0,1,0),finish-Vector3.new(0,1,0))
  for _,side in {-1,1} do local rail=part('PassageWall',Vector3.new(2,22,len+.5),mid,C.wall,f); rail.CFrame=floor.CFrame*CFrame.new(side*12,12,0) end
  local ceiling=roof(a..'_PassageRoof',Vector3.new(26,1,len+.5),mid); ceiling.CFrame=floor.CFrame*CFrame.new(0,23.5,0)
  f:SetAttribute('From',a); f:SetAttribute('To',b)
 end
 for _,edge in {{'ENTRY','HALL'},{'HALL','BOOKS'},{'HALL','CISTERN'},{'HALL','REGISTER'},{'BOOKS','OBSERVATORY'},{'CISTERN','GAMES'},{'OBSERVATORY','REGISTER'},{'GAMES','REGISTER'},{'REGISTER','STAFF'},{'STAFF','WAREHOUSE'},{'WAREHOUSE','EXTRACTION'}} do connect(edge[1],edge[2]) end
 local function shelves(r,media)
  local shift=rng:NextInteger(0,1)*3
  for _,x in {-42,-24,24,42} do for _,z in {-27,27} do
   local sx=x; local sz=z+shift
   localPart(r,'ShelfBack',Vector3.new(2,9,26),Vector3.new(sx,4.5,sz),C.dark)
   for _,h in {1,3.5,6,8.5} do localPart(r,'Shelf',Vector3.new(6,.3,26),Vector3.new(sx,h,sz),Color3.fromRGB(128,128,113)) end
   localPart(r,'CategoryStrip',Vector3.new(6,.6,26),Vector3.new(sx,9,sz),C.blue)
   -- Sparse blocks communicate empty cases, without detailed individual products.
   if rng:NextNumber()>.28 then for _,side in {-1,1} do localPart(r,'EmptyCases',Vector3.new(1.6,1.6,13),Vector3.new(sx+side*1.7,4.5,sz-4),Color3.fromRGB(100,107,109)) end end
  end end
  board(r,'MediaHeader',Vector3.new(-33,12,10),Vector3.new(24,3,.5),media)
 end
 for _,n in {'ENTRY','BOOKS','CISTERN','GAMES','OBSERVATORY'} do shelves(by[n],n=='OBSERVATORY' and 'VHS / 返却期限 2004' or n=='ENTRY' and 'NEW RELEASE / 新作' or n=='BOOKS' and 'BOOKS / 雑誌・書籍' or n=='CISTERN' and 'CD / 試聴コーナー' or 'GAMES / 中古') end
 local function station(r,n,offset,color,text,action)
  local b=part(n,Vector3.new(5,4,3),r.Center+offset,color,r.Folders.GimmickPoints,Enum.Material.Metal); sign(b,text,color); result.Prompts[n]=prompt(b,action,n); return b
 end
 local lobby=by.LOBBY; result.Lobby=lobby.Center+Vector3.new(0,4,14); result.Entry=by.ENTRY.Center+Vector3.new(0,4,34)
 local spawn=Instance.new('SpawnLocation'); spawn.Name='LobbySpawn'; spawn.Anchored=true; spawn.Size=Vector3.new(8,.2,8); spawn.Position=lobby.Center+Vector3.new(0,.1,16); spawn.Neutral=true; spawn.Transparency=1; spawn.Parent=lobby.Folders.SpecialPoints
 station(lobby,'Enter',Vector3.new(0,2,-8),C.yellow,'CLOSED STACKS\n閉店後の探索を始める','店内に入る')
 station(lobby,'Reroll',Vector3.new(24,2,0),C.yellow,'売場の配置を再抽選\n全員ロビーのときのみ','棚の配置を再抽選')
 board(lobby,'MapBoard',Vector3.new(-23,8,-23),Vector3.new(28,12,.5),'店内案内\nDVD → 中央売場\n書籍・VHS ← → CD・ゲーム\nレジ → スタッフ → 倉庫 → B1')
 station(by.ENTRY,'Return',Vector3.new(-18,2,36),C.cyan,'店外へ戻る','帰還する')
 local hall=by.HALL; result.Hall=hall.Center
 for _,x in {-37,37} do localPart(hall,'FeatureTable',Vector3.new(24,3,18),Vector3.new(x,1.5,-27),C.wall) end
 board(hall,'WestGuide',Vector3.new(-40,14,0),Vector3.new(24,4,.5),'← BOOKS / VHS')
 board(hall,'EastGuide',Vector3.new(40,14,0),Vector3.new(24,4,.5),'CD / GAMES →')
 board(hall,'RearGuide',Vector3.new(0,15,-45),Vector3.new(30,4,.5),'返却・レジ ↑')
 station(hall,'Boss',Vector3.new(37,2,29),C.yellow,'会員ランキング端末\n今月の主役','ランキングに載る')
 local pool=part('HealingPool',Vector3.new(18,.3,18),by.CISTERN.Center+Vector3.new(0,.2,25),C.cyan,by.CISTERN.Folders.GimmickPoints,Enum.Material.Neon); pool.CanCollide=false; sign(pool,'漏水 / 1人で回復・2人以上で毒',C.cyan); result.Pool=pool
 local obs=by.OBSERVATORY
 local ob=part('Observer',Vector3.new(5,6,3),obs.Center+Vector3.new(0,3,-27),C.violet,obs.Folders.AnomalyPoints,Enum.Material.Neon); sign(ob,'返却されていない映像 / 近くにいると危険',C.violet); result.Observer=ob
 local gate=part('AnomalyGate',Vector3.new(1,12,14),obs.Center+Vector3.new(-58,6,0),C.violet,obs.Folders.SpecialPoints); sign(gate,'在庫にない通路 / 異常状態',C.violet); result.Prompts.Secret=prompt(gate,'境界を越える','棚の裏側')
 result.SecretSpawn=by.OUTSIDE.Center+Vector3.new(0,4,12); station(by.OUTSIDE,'AnomalyExit',Vector3.new(0,2,-8),C.violet,'出口ポータル','帰還する')
 local reg=by.REGISTER
 for _,x in {-40,40} do
  localPart(reg,'CheckoutCounter',Vector3.new(28,4,10),Vector3.new(x,2,8),C.blue)
  local screen=localPart(reg,'PoweredRegister',Vector3.new(4,3,.5),Vector3.new(x,5.5,8),C.cyan,Enum.Material.Neon); textFace(screen,'OPEN')
 end
 board(reg,'ReturnsGuide',Vector3.new(0,14,-42),Vector3.new(38,5,.5),'レンタル返却はこちら\n↓ STAFF ONLY / B1')
 localPart(reg,'ReturnBox',Vector3.new(10,6,8),Vector3.new(23,3,-38),C.blue); board(reg,'ReturnLabel',Vector3.new(23,7,-33),Vector3.new(12,3,.5),'返却 BOX')
 station(reg,'UnlockExit',Vector3.new(0,2,-28),C.yellow,'出口制御端末\n操作すると出口ポータルが起動','出口を起動する')
 for _,x in {-26,26} do localPart(by.STAFF,'Desk',Vector3.new(20,3,9),Vector3.new(x,1.5,-17),C.wall); localPart(by.STAFF,'Lockers',Vector3.new(10,13,6),Vector3.new(x,6.5,25),C.dark) end
 local stock=by.WAREHOUSE
 for _,x in {-42,-25,25,42} do for _,z in {-25,0,25} do localPart(stock,'StockCrate',Vector3.new(10,rng:NextInteger(5,11),14),Vector3.new(x,5,z),Color3.fromRGB(125,111,85)) end end
 board(stock,'BasementGuide',Vector3.new(0,15,-40),Vector3.new(32,5,.5),'返却受付 / B1\nこの先も営業中')
 local parking=by.EXTRACTION
 for _,x in {-55,55} do for z=-40,40,20 do localPart(parking,'ParkingStripe',Vector3.new(32,.035,.35),Vector3.new(x,.03,z),Color3.fromRGB(216,214,183)) end end
 for _,x in {-40,40} do localPart(parking,'BasementPillar',Vector3.new(6,22,6),Vector3.new(x,11,0),C.wall) end
 station(parking,'Extract',Vector3.new(0,2,-42),C.cyan,'非常口 / 地上へ帰還','脱出する')
 root:SetAttribute('Route','DVD → 中央売場 ↔ 書籍・VHS / CD・ゲーム → レジ → スタッフ → 倉庫 → 地下駐車場')
 root:SetAttribute('PreviewCeilingsHidden',preview==true); return result
end
return M
