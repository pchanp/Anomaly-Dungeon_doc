-- TSUTAYA: abandoned rental shop blockout. All dimensions are studs.
-- Narrow aisles, tall stacks and drop ceilings keep sightlines short on purpose.
local RS=game:GetService("ReplicatedStorage")
local MapDefinitions=require(RS.AnomalyDungeon.Shared.Definitions.MapDefinitions)
local Config=require(RS.AnomalyDungeon.Shared.Config.TsutayaConfig)
local Archive=require(script.Parent.TsutayaArchiveService)
local M={}
local DEFS=MapDefinitions.TSUTAYA

local C={
	wall=Color3.fromRGB(122,118,104),
	floor=Color3.fromRGB(96,92,84),
	shelfframe=Color3.fromRGB(64,58,50),
	shelfboard=Color3.fromRGB(118,110,96),
	blue=Color3.fromRGB(26,61,103),
	yellow=Color3.fromRGB(236,203,70),
	dark=Color3.fromRGB(34,36,40),
	cyan=Color3.fromRGB(80,218,202),
	violet=Color3.fromRGB(157,108,195),
	rust=Color3.fromRGB(122,68,48),
}

local function folder(name,parent)
	local f=Instance.new("Folder")
	f.Name=name
	f.Parent=parent
	return f
end

local function part(name,size,position,color,parent,material)
	local b=Instance.new("Part")
	b.Name=name
	b.Size=size
	b.Position=position
	b.Color=color
	b.Material=material or Enum.Material.SmoothPlastic
	b.TopSurface=Enum.SurfaceType.Smooth
	b.BottomSurface=Enum.SurfaceType.Smooth
	b.Anchored=true
	b.Parent=parent
	return b
end

local function textFace(body,text,face)
	local g=Instance.new("SurfaceGui")
	g.Name="Text"
	g.Face=face or Enum.NormalId.Front
	g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud=28
	g.Parent=body
	local t=Instance.new("TextLabel")
	t.Size=UDim2.fromScale(1,1)
	t.BackgroundTransparency=1
	t.TextColor3=C.yellow
	t.Font=Enum.Font.GothamBold
	t.TextScaled=true
	t.TextWrapped=true
	t.Text=text
	t.Parent=g
	local pad=Instance.new("UIPadding")
	pad.PaddingTop=UDim.new(.08,0)
	pad.PaddingBottom=UDim.new(.08,0)
	pad.PaddingLeft=UDim.new(.04,0)
	pad.PaddingRight=UDim.new(.04,0)
	pad.Parent=t
end

local function sign(body,text,color)
	local g=Instance.new("BillboardGui")
	g.Name="Sign"
	g.Size=UDim2.fromOffset(230,58)
	g.StudsOffset=Vector3.new(0,3,0)
	g.MaxDistance=30
	g.Parent=body
	local t=Instance.new("TextLabel")
	t.Size=UDim2.fromScale(1,1)
	t.BackgroundColor3=C.dark
	t.BackgroundTransparency=.18
	t.TextColor3=color or C.yellow
	t.TextSize=14
	t.TextWrapped=true
	t.Font=Enum.Font.GothamMedium
	t.Text=text
	t.Parent=g
	return t
end

local function prompt(body,action,object,hold,maxDistance)
	local q=Instance.new("ProximityPrompt")
	q.ActionText=action
	q.ObjectText=object
	q.HoldDuration=hold or .35
	q.MaxActivationDistance=maxDistance or 10
	q.RequiresLineOfSight=false
	q.Parent=body
	return q
end

-- Room specs: name, display, x, z, width, depth, height.
-- No door letters live here. Openings are derived from LINKS below, so a hand typed wall
-- letter can never seal a corridor that a link already promised.
-- Aisles are 22 wide with double-sided stacks, so a room reads as corridors rather than an open floor.
local ROOMS={
	{"FRONT","01 / 店頭 / 営業終了",0,190,120,64,20},
	{"VHS","02 / VHS 試写室",-190,190,104,96,20},
	{"DVD","03 / DVD / セル",190,190,104,96,20},
	{"CD","04 / CD 試聴コーナー",-190,20,104,96,20},
	{"BROADCAST","05 / 社内放送室",0,20,160,72,18},
	{"TAPE","06 / テープ保管庫",190,20,104,96,20},
	{"BACKROOM","B1 / 返却作業場",0,-130,140,80,18},
}

-- The single description of how the blockout connects. LINKS is the only place a passage is
-- declared: each end's wall opening and the walkway between the two ends are both read from it.
-- Rooms share a row or a column on purpose, so every link runs straight and never bends
-- through a room it is not supposed to touch.
local LINKS={
	{"FRONT","VHS"},
	{"FRONT","DVD"},
	{"VHS","CD"},
	{"DVD","TAPE"},
	{"CD","BROADCAST"},
	{"TAPE","BROADCAST"},
	{"BROADCAST","BACKROOM"},
}

local AISLE=22
local RAIL=AISLE/2+1

local SPEC={}
for _,spec in ipairs(ROOMS) do SPEC[spec[1]]=spec end

-- Which wall a link opens on each end. Door letters: N=-Z, S=+Z, E=+X, W=-X.
local function linkSides(aName,bName)
	local a,b=SPEC[aName],SPEC[bName]
	local dx,dz=b[3]-a[3],b[4]-a[4]
	if math.abs(dx)>math.abs(dz) then
		local east=dx>0
		return "X",east and "E" or "W",east and "W" or "E"
	end
	local south=dz>0
	return "Z",south and "S" or "N",south and "N" or "S"
end

local openings={}
for _,spec in ipairs(ROOMS) do openings[spec[1]]={} end
for _,edge in ipairs(LINKS) do
	local _,sideA,sideB=linkSides(edge[1],edge[2])
	openings[edge[1]][sideA]=(openings[edge[1]][sideA] or 0)+1
	openings[edge[2]][sideB]=(openings[edge[2]][sideB] or 0)+1
end

-- Structural self check. A walled off room or a corridor nobody walks is invisible in the
-- editor and only surfaces as a dead run, so the build says so instead of failing quietly.
local function auditLayout()
	for index=1,#ROOMS do
		local a=ROOMS[index]
		for side,count in pairs(openings[a[1]]) do
			if count>1 then
				warn(("[%s] room %s has %d links on wall %s; only one gap gets carved"):format(DEFS.Id,a[1],count,side))
			end
		end
		for other=index+1,#ROOMS do
			local b=ROOMS[other]
			local overlapX=math.abs(a[3]-b[3])<(a[5]+b[5])/2
			local overlapZ=math.abs(a[4]-b[4])<(a[6]+b[6])/2
			if overlapX and overlapZ then
				warn(("[%s] rooms %s and %s overlap"):format(DEFS.Id,a[1],b[1]))
			end
		end
	end
	local neighbours={}
	for _,spec in ipairs(ROOMS) do neighbours[spec[1]]={} end
	for _,edge in ipairs(LINKS) do
		table.insert(neighbours[edge[1]],edge[2])
		table.insert(neighbours[edge[2]],edge[1])
	end
	local origin=ROOMS[1][1]
	local seen,queue={[origin]=true},{origin}
	while #queue>0 do
		local current=table.remove(queue)
		for _,next_room in ipairs(neighbours[current]) do
			if not seen[next_room] then
				seen[next_room]=true
				table.insert(queue,next_room)
			end
		end
	end
	for _,spec in ipairs(ROOMS) do
		if not seen[spec[1]] then
			warn(("[%s] room %s has no passage from %s"):format(DEFS.Id,spec[1],origin))
		end
	end
end

function M.Build(seed)
	local old=workspace:FindFirstChild("AnomalyDungeon")
	if old then old:Destroy() end
	local rng=Random.new(seed or 0)
	local root=Instance.new("Model")
	root.Name="AnomalyDungeon"
	root.Parent=workspace
	root:SetAttribute("Seed",seed)
	root:SetAttribute("Theme","Abandoned rental archive")
	root:SetAttribute("Version",1)
	root:SetAttribute("MapId",DEFS.Id)
	root:SetAttribute("MapDisplayName",DEFS.DisplayName)
	root:SetAttribute("Route","店頭 → VHS / DVD ↔ CD / テープ → 社内放送室 → 返却作業場")

	local rooms=folder("Rooms",root)
	local links=folder("Connections",root)
	local roofs=folder("Roofs",root)
	local result={Root=root,Rooms={},Prompts={},Seed=seed,KillY=940}
	local by={}

	for _,spec in ipairs(ROOMS) do
		local name,display,x,z,width,depth,height=table.unpack(spec)
		local model=Instance.new("Model")
		model.Name=name
		model.Parent=rooms
		local f={}
		for _,key in ipairs({"Geometry","DoorPoints","EnemyPoints","AnomalyPoints","ItemPoints","GimmickPoints","SpecialPoints"}) do
			f[key]=folder(key,model)
		end
		local center=Vector3.new(x,1000,z)
		local room={Model=model,Center=center,Width=width,Depth=depth,Height=height,DisplayName=display,Folders=f}
		by[name]=room
		table.insert(result.Rooms,room)
		model:SetAttribute("Center",center)
		model:SetAttribute("Width",width)
		model:SetAttribute("Depth",depth)
		model:SetAttribute("DisplayName",display)

		local function localPart(n,size,offset,color,material)
			return part(n,size,center+offset,color,f.Geometry,material)
		end

		localPart("Floor",Vector3.new(width,2,depth),Vector3.new(0,-1,0),C.floor,Enum.Material.Concrete)
		local ceiling=part(name.."_Ceiling",Vector3.new(width,1,depth),center+Vector3.new(0,height+.5,0),Color3.fromRGB(52,50,47),roofs)
		ceiling:SetAttribute("PreviewHidden",true)

		-- Full perimeter walls keep each room enclosed; sightlines stop at the doorway.
		for _,side in ipairs({"N","S","E","W"}) do
			local alongX=side=="N" or side=="S"
			local span=alongX and width or depth
			local edge=(alongX and depth or width)/2
			local direction=(side=="S" or side=="E") and 1 or -1
			local function wallSegment(len,offset,yoff)
				local size=alongX and Vector3.new(len,height,2) or Vector3.new(2,height,len)
				local pos=alongX and Vector3.new(offset,yoff,direction*edge) or Vector3.new(direction*edge,yoff,offset)
				localPart("Wall_"..side,size,pos,C.wall)
			end
			if openings[name][side] then
				local segment=(span-AISLE)/2
				wallSegment(segment,AISLE/2+segment/2,height/2)
				wallSegment(segment,-AISLE/2-segment/2,height/2)
				wallSegment(AISLE,0,height-1.5)
				local pos=alongX and Vector3.new(0,2,direction*edge) or Vector3.new(direction*edge,2,0)
				local marker=part(side,Vector3.one,center+pos,C.yellow,f.DoorPoints)
				marker.Transparency=1
				marker.CanCollide=false
			else
				wallSegment(span,0,height/2)
			end
		end

		-- Uneven strip lighting: broken tubes read as a dead store.
		for index=-1,1 do
			for _,along in ipairs({"X","Z"}) do
				local on=rng:NextNumber()>.35
				local size=along=="X" and Vector3.new(14,.3,1.2) or Vector3.new(1.2,.3,14)
				local offset=along=="X" and Vector3.new(index*(width/3),height-.6,0) or Vector3.new(0,height-.6,index*(depth/3))
				local b=localPart("Strip",size,offset,on and Color3.fromRGB(214,222,206) or C.dark,on and Enum.Material.Neon or Enum.Material.SmoothPlastic)
				if on then
					local light=Instance.new("PointLight")
					light.Color=Color3.fromRGB(206,216,198)
					light.Range=30
					light.Brightness=.7
					light.Shadows=false
					light.Parent=b
				end
			end
		end

		-- Structural columns split long rooms into bays.
		local bays=math.max(1,math.floor(width/60))
		for bay=1,bays do
			local offset=(bay-(bays+1)/2)*(width/(bays+1))
			for _,zoff in ipairs({-(depth/2-9),depth/2-9}) do
				localPart("Column",Vector3.new(3.4,height,3.4),Vector3.new(offset,height/2,zoff),C.wall)
			end
		end

		local signboard=localPart("SectionSign",Vector3.new(math.min(width-12,54),5,.5),Vector3.new(0,height-4,depth/2-5),C.blue)
		textFace(signboard,display)

		-- Abandoned fixtures. They break long rooms into bays so sightlines stop short.
		-- Checkout lanes for the front, returns handling for the back room.
		if name=="FRONT" then
			for lane=1,3 do
				local x=(lane-2)*(width/4)
				localPart("CheckoutLane",Vector3.new(14,4.5,9),Vector3.new(x,2.25,depth/2-16),C.blue)
				localPart("LanePost",Vector3.new(3,7,3),Vector3.new(x+9,3.5,depth/2-24),C.wall)
			end
		elseif name=="BACKROOM" then
			for rack=1,3 do
				local x=(rack-2)*(width/4)
				localPart("ReturnsRack",Vector3.new(20,8,7),Vector3.new(x,4,depth/2-18),C.rust,Enum.Material.Metal)
			end
			localPart("SortingTable",Vector3.new(26,3.5,12),Vector3.new(0,1.75,-8),C.wall)
		elseif name=="BROADCAST" then
			localPart("Console",Vector3.new(16,4,7),Vector3.new(0,2,-8),C.dark,Enum.Material.Metal)
			for _,side in ipairs({-1,1}) do
				localPart("Rack",Vector3.new(5,9,6),Vector3.new(side*(width/2-14),4.5,10),C.dark)
			end
		end
	end

	-- Reads the axis from the same helper the wall openings came from, so a walkway can
	-- never be laid along an axis the carved gap is not on.
	local function connect(aName,bName)
		local A,B=by[aName],by[bName]
		local delta=B.Center-A.Center
		local alongX=linkSides(aName,bName)=="X"
		local unit=alongX and Vector3.new(math.sign(delta.X),0,0) or Vector3.new(0,0,math.sign(delta.Z))
		local start=A.Center+unit*(alongX and A.Width/2 or A.Depth/2)
		local finish=B.Center-unit*(alongX and B.Width/2 or B.Depth/2)
		local len=(finish-start).Magnitude
		local mid=(start+finish)/2
		local f=folder(aName.."_to_"..bName,links)
		local floor=part("Walkway",Vector3.new(AISLE,2,len+.5),mid-Vector3.new(0,1,0),C.floor,f,Enum.Material.Concrete)
		floor.CFrame=CFrame.lookAt(mid-Vector3.new(0,1,0),finish-Vector3.new(0,1,0))
		for _,side in ipairs({-1,1}) do
			local rail=part("PassageWall",Vector3.new(2,18,len+.5),mid,C.wall,f)
			rail.CFrame=floor.CFrame*CFrame.new(side*RAIL,9,0)
		end
		local lid=part("PassageRoof",Vector3.new(AISLE+4,1,len+.5),mid,Color3.fromRGB(52,50,47),f)
		lid.CFrame=floor.CFrame*CFrame.new(0,19.5,0)
		f:SetAttribute("From",aName)
		f:SetAttribute("To",bName)
	end

	for _,edge in ipairs(LINKS) do
		connect(edge[1],edge[2])
	end

	auditLayout()

	-- Archive shelves: double-sided stacks with a dead aisle between rows.
	local function stackRow(room,name,offset,alongX,rows)
		local dir=alongX and Vector3.new(0,0,1) or Vector3.new(1,0,0)
		for row=1,(rows or 2) do
			local shift=(row-1)*((alongX and room.Width or room.Depth)/(rows+1))
			local spine=offset+dir*shift
			local length=alongX and room.Width-24 or room.Depth-24
			local size=alongX and Vector3.new(length,9,2.4) or Vector3.new(2.4,9,length)
			part(name,size,room.Center+spine+Vector3.new(0,4.5,0),C.shelfframe,room.Folders.AnomalyPoints)
			local boardSize=alongX and Vector3.new(length,.4,4.2) or Vector3.new(4.2,.4,length)
			for _,level in ipairs({2.4,4.6,6.8,9}) do
				part("ShelfBoard",boardSize,room.Center+spine+Vector3.new(0,level,0),C.shelfboard,room.Folders.AnomalyPoints)
			end
		end
	end

	stackRow(by.VHS,"VhsStack",Vector3.new(0,0,-8),true,3)
	stackRow(by.DVD,"DvdStack",Vector3.new(0,0,-8),true,3)
	stackRow(by.CD,"CdStack",Vector3.new(0,0,4),true,2)
	stackRow(by.TAPE,"TapeStack",Vector3.new(0,0,-4),true,3)

	-- Loose stock on the floor breaks the grid so the aisles do not read as corridors.
	for _,name in ipairs({"VHS","DVD","CD","TAPE"}) do
		local room=by[name]
		for _=1,4 do
			local x=rng:NextNumber(-(room.Width/2-12),room.Width/2-12)
			local z=rng:NextNumber(-(room.Depth/2-12),room.Depth/2-12)
			part("FallenCase",Vector3.new(4,1.6,3),room.Center+Vector3.new(x,0.8,z),C.rust,room.Folders.ItemPoints)
		end
	end

	-- Lobby, entry and exit follow the same contract as the existing map.
	local front=by.FRONT
	result.Lobby=front.Center+Vector3.new(0,4,10)
	result.Entry=by.VHS.Center+Vector3.new(0,4,40)
	local spawn=Instance.new("SpawnLocation")
	spawn.Name="LobbySpawn"
	spawn.Anchored=true
	spawn.Size=Vector3.new(8,.2,8)
	spawn.Position=front.Center+Vector3.new(0,.1,12)
	spawn.Neutral=true
	spawn.Transparency=1
	spawn.Parent=front.Folders.SpecialPoints

	local function station(room,name,offset,color,text,action)
		local body=part(name,Vector3.new(5,4,3),room.Center+offset,color,room.Folders.GimmickPoints,Enum.Material.Metal)
		sign(body,text,color)
		result.Prompts[name]=prompt(body,action,name)
		return body
	end

	-- No "Enter" prompt here. The entrance reception owns entry, so a direct prompt could only
	-- duplicate M.Enter and bypass the field check it already guards.
	station(front,"Reroll",Vector3.new(-32,2,10),C.yellow,"棚の構成を再抽選\n全員ロビーのときのみ","棚の構成を再抽選")
	station(by.VHS,"Return",Vector3.new(-32,2,42),C.cyan,"店外へ戻る","帰還する")
	station(by.BACKROOM,"UnlockExit",Vector3.new(0,2,-26),C.yellow,"出口制御端末\n操作すると出口ポータルが起動","出口を起動する")
	station(by.BACKROOM,"Extract",Vector3.new(36,2,-26),C.cyan,"非常口 / 地上へ帰還","脱出する")

	-- Observer and pool reuse the existing Anomaly Exposure and healing rules.
	local obs=part("Observer",Vector3.new(5,6,3),by.BROADCAST.Center+Vector3.new(30,3,-24),C.violet,by.BROADCAST.Folders.AnomalyPoints,Enum.Material.Neon)
	sign(obs,"再生中の記録 / 近くにいると危険",C.violet)
	result.Observer=obs
	local pool=part("HealingPool",Vector3.new(18,.3,18),by.CD.Center+Vector3.new(0,.2,-34),C.cyan,by.CD.Folders.GimmickPoints,Enum.Material.Neon)
	pool.CanCollide=false
	sign(pool,"漏水 / 1人で回復・2人以上で毒",C.cyan)
	result.Pool=pool

	local gate=part("AnomalyGate",Vector3.new(1,10,14),by.VHS.Center+Vector3.new(-44,5,0),C.violet,by.VHS.Folders.SpecialPoints)
	sign(gate,"在庫にない通路 / 異常状態",C.violet)
	result.Prompts.Secret=prompt(gate,"境界を越える","棚の裏側")
	result.SecretSpawn=by.TAPE.Center+Vector3.new(0,4,-40)
	station(by.TAPE,"AnomalyExit",Vector3.new(0,2,-38),C.violet,"出口ポータル","帰還する")

	local boss=part("Ranking",Vector3.new(4,5,2),by.FRONT.Center+Vector3.new(-40,2.5,-20),C.yellow,by.FRONT.Folders.GimmickPoints,Enum.Material.Metal)
	sign(boss,"会員ランキング端末\n今月のActing")
	result.Prompts.Boss=prompt(boss,"ランキングに載る","ランキング")

	-- Archive shelves the player can browse.
	local SHELF_KINDS={
		{room="VHS",kind="VHS",label="VHS 棚 A",offset=Vector3.new(-30,4.5,-8)},
		{room="VHS",kind="VHS",label="VHS 棚 B",offset=Vector3.new(30,4.5,-8)},
		{room="DVD",kind="DVD",label="DVD 棚 A",offset=Vector3.new(-30,4.5,-8)},
		{room="TAPE",kind="TAPE",label="テープ棚",offset=Vector3.new(-30,4.5,-4)},
		{room="CD",kind="CD",label="CD 棚",offset=Vector3.new(30,4.5,4)},
	}
	for _,spec in ipairs(SHELF_KINDS) do
		local room=by[spec.room]
		local body=part("ArchiveShelf",Vector3.new(10,6,2.2),room.Center+spec.offset,C.shelfframe,room.Folders.ItemPoints)
		local label=sign(body,spec.kind.." / アーカイブ",C.cyan)
		local q=prompt(body,"棚を調べる",Config.UiOptionObjectText,Config.ShelfHoldDuration,Config.ShelfPromptDistance)
		result.Shelves=result.Shelves or {}
		result.Shelves[spec.label]={Label=spec.label,Kind=spec.kind,Part=body,Prompt=q,Room=room}
		q.Triggered:Connect(function(player)
			if not player:GetAttribute("InDungeon") then return end
			Archive.QueryShelf(player,spec.label)
		end)
	end

	-- CRTs. The broadcast room holds the switcher; the others hold dead sets.
	local CRT_PLACEMENT={
		{room="BROADCAST",offset=Vector3.new(-32,2.6,-26)},
		{room="FRONT",offset=Vector3.new(40,2.6,20)},
		{room="BACKROOM",offset=Vector3.new(-44,2.6,10)},
		{room="DVD",offset=Vector3.new(0,2.6,34)},
	}
	for _,spec in ipairs(CRT_PLACEMENT) do
		local room=by[spec.room]
		local model=Instance.new("Model")
		model.Name="CRT"
		model.Parent=room.Folders.GimmickPoints
		local body=part("Body",Vector3.new(6,4.2,3.4),room.Center+spec.offset,C.dark,model,Enum.Material.Metal)
		local screen=part("Screen",Vector3.new(4.6,3,.2),body.Position+Vector3.new(0,.2,-1.8),Color3.fromRGB(28,30,34),model,Enum.Material.Neon)
		screen.CanCollide=false
		local spinner=part("Spinner",Vector3.new(4.6,.5,.2),screen.Position,Color3.fromRGB(200,220,215),model,Enum.Material.Neon)
		spinner.CanCollide=false
		spinner.Transparency=1
		local gui=Instance.new("SurfaceGui")
		gui.Name="Text"
		gui.Face=Enum.NormalId.Front
		gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud=30
		gui.Parent=screen
		local label=Instance.new("TextLabel")
		label.Size=UDim2.fromScale(1,1)
		label.BackgroundTransparency=1
		label.TextColor3=Color3.fromRGB(190,200,206)
		label.Font=Enum.Font.Code
		label.TextScaled=true
		label.Text="?"
		label.Parent=gui
		local tone=Instance.new("Sound")
		tone.Name="StaticTone"
		tone.SoundId=Config.CrtStaticToneId
		tone.Volume=Config.CrtStaticVolume or .25
		tone.Looped=true
		tone.RollOffMaxDistance=40
		tone.Parent=screen
		tone:Play()
		local q=prompt(body,"チャンネルを変える","店内放送",Config.CrtStaticHoldDuration,Config.CrtPromptDistance)
		Archive.AttachCrt(model)
	end

	-- Listening stations: personal preview, separate from the shared broadcast.
	local bgm=Instance.new("Sound")
	bgm.Name="SharedBgm"
	bgm.SoundId=Config.SharedBgmId
	bgm.Volume=Config.SharedBgmVolume
	bgm.Looped=true
	bgm.RollOffMaxDistance=Config.SharedBgmRange
	bgm.Parent=root
	result.Bgm=bgm

	local STATIONS={
		{room="CD",offset=Vector3.new(-32,1.5,28),track="盤面 03 / 再生不可"},
		{room="CD",offset=Vector3.new(0,1.5,28),track="試聴盤面 07 / 逆再生が混じる"},
		{room="BROADCAST",offset=Vector3.new(30,1.5,-8),track="社内放送 / 営業終了-loop"},
	}
	for index,spec in ipairs(STATIONS) do
		local room=by[spec.room]
		local model=Instance.new("Model")
		model.Name="ListeningStation"
		model.Parent=room.Folders.GimmickPoints
		model:SetAttribute("Track",spec.track)
		local unit=part("Unit",Vector3.new(4,2.6,3),room.Center+spec.offset,C.dark,model,Enum.Material.Metal)
		local deck=part("Deck",Vector3.new(3.2,.3,2.2),unit.Position+Vector3.new(0,1.4,0),C.cyan,model,Enum.Material.Neon)
		deck.CanCollide=false
		sign(unit,"試聴機\n"..spec.track,C.cyan)
		local q=prompt(unit,"試聴する","試聴機",Config.ListenHoldDuration,Config.ListenPromptDistance)
		Archive.AttachStation(model)
	end

	-- Return / lobby markers used by RunService.
	result.ReturnPoint=by.VHS.Center+Vector3.new(-32,4,42)
	result.KillY=940
	return result
end

return M
