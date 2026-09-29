local RS=game:GetService("ReplicatedStorage")
local MapDefinitions=require(RS.AnomalyDungeon.Shared.Definitions.MapDefinitions)
local Config=require(RS.AnomalyDungeon.Shared.Config.AugustConfig)
local M={}
local DEFS=MapDefinitions.AUGUST_31

local C={
	grass=Color3.fromRGB(96,138,74),
	drygrass=Color3.fromRGB(146,148,84),
	dirt=Color3.fromRGB(126,104,76),
	soil=Color3.fromRGB(92,78,60),
	road=Color3.fromRGB(72,72,74),
	roadline=Color3.fromRGB(214,212,178),
	cedar=Color3.fromRGB(46,72,52),
	bark=Color3.fromRGB(78,60,44),
	rock=Color3.fromRGB(112,110,102),
	stone=Color3.fromRGB(138,136,128),
	concrete=Color3.fromRGB(158,156,148),
	wall=Color3.fromRGB(196,190,176),
	roof=Color3.fromRGB(84,80,88),
	water=Color3.fromRGB(70,132,158),
	mud=Color3.fromRGB(104,92,70),
	bright=Color3.fromRGB(240,232,196),
	yellow=Color3.fromRGB(236,203,70),
	cyan=Color3.fromRGB(80,218,202),
	violet=Color3.fromRGB(157,108,195),
	red=Color3.fromRGB(178,64,58),
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

local function sign(body,text,color,offsetY,width)
	local g=Instance.new("BillboardGui")
	g.Name="Sign"
	g.Size=UDim2.fromOffset(width or 230,58)
	g.StudsOffset=Vector3.new(0,offsetY or 3,0)
	g.MaxDistance=40
	g.Parent=body
	local t=Instance.new("TextLabel")
	t.Name="TextLabel"
	t.Size=UDim2.fromScale(1,1)
	t.BackgroundColor3=Color3.fromRGB(20,24,20)
	t.BackgroundTransparency=.2
	t.TextColor3=color or C.yellow
	t.TextSize=15
	t.TextWrapped=true
	t.Font=Enum.Font.GothamMedium
	t.Text=text
	t.Parent=g
	return t
end

local function textFace(body,text,face,color)
	local g=Instance.new("SurfaceGui")
	g.Name="Text"
	g.Face=face or Enum.NormalId.Front
	g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
	g.PixelsPerStud=26
	g.Parent=body
	local t=Instance.new("TextLabel")
	t.Name="TextLabel"
	t.Size=UDim2.fromScale(1,1)
	t.BackgroundTransparency=1
	t.TextColor3=color or C.yellow
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

-- Zones: name, display, x, y, z, width, depth, height.
-- Each zone is a flat terrace; the trails between them are the ramps, so the valley reads in layers.
local ZONES={
	{"LOBBY","00 / バス停 / 集合場所",0,1000,0,74,74,80},
	{"ROAD","01 / 県道沿い / 夕方の坂",0,1004,140,74,160,80},
	{"VILLAGE","02 / 山あいの集落 / 商店と公民館",0,1012,330,140,140,80},
	{"SHRINE","03 / 祠と石段",-150,1030,470,96,96,80},
	{"RICE","04 / 田んぼと用水路",190,1008,330,160,130,80},
	{"RIVER","05 / 橋と河原",180,1002,130,180,160,80},
	{"FOREST","06 / 杉林の林道",-200,1022,220,190,190,80},
	{"TUNNEL","07 / 県道トンネル",-360,1018,220,80,50,80},
	{"DAM","08 / ダム下 / 溜め池",-330,1044,40,170,130,80},
	{"APARTMENT","09 / 山上の団地 / 最終日",70,1036,-250,150,130,80},
}

-- Trail network. Every zone is reachable on foot; the tunnel is the only way past the ridge.
local TRAILS={
	{"LOBBY","ROAD"},{"ROAD","VILLAGE"},{"VILLAGE","SHRINE"},{"VILLAGE","RICE"},
	{"RICE","RIVER"},{"RIVER","LOBBY"},{"RIVER","DAM"},{"DAM","TUNNEL"},
	{"TUNNEL","FOREST"},{"FOREST","VILLAGE"},{"FOREST","DAM"},{"APARTMENT","LOBBY"},
}

-- Ridge ring. Kept outside every terrace so the valley reads as enclosed without blocking a path.
local RIDGES={
	Vector3.new(-560,1105,120),Vector3.new(-560,1105,420),Vector3.new(-300,1120,600),
	Vector3.new(90,1125,620),Vector3.new(420,1115,430),Vector3.new(430,1100,60),
	Vector3.new(360,1095,-240),Vector3.new(80,1090,-470),Vector3.new(-330,1090,-450),
	Vector3.new(-590,1090,-190),
}

function M.Build(seed)
	local old=workspace:FindFirstChild("AnomalyDungeon")
	if old then old:Destroy() end
	local rng=Random.new(seed or 0)
	local root=Instance.new("Model")
	root.Name="AnomalyDungeon"
	root.Parent=workspace
	root:SetAttribute("Seed",seed)
	root:SetAttribute("Theme",DEFS.DisplayName.." / 山あいの夏")
	root:SetAttribute("Version",1)
	root:SetAttribute("MapId",DEFS.Id)
	root:SetAttribute("MapDisplayName",DEFS.DisplayName)
	root:SetAttribute("Route","バス停 → 県道 → 集落 ↔ 杉林 → トンネル → ダム / 集落 → 祠 / 集落 → 田んぼ → 河原 → バス停 / 山上 → 団地")
	root:SetAttribute("MapPhase",Config.PhaseOrder[1])

	local rooms=folder("Rooms",root)
	local links=folder("Connections",root)
	local result={Root=root,Rooms={},Prompts={},Seed=seed,DateBoards={},Tints={},Aug32Parts={}}
	for _,group in ipairs(Config.TintGroups) do result.Tints[group]={} end
	local by={}

	-- Records a part so the service can re-tint it when the clock advances.
	local function tint(group,body)
		if body then table.insert(result.Tints[group],{Part=body,Base=body.Color}) end
		return body
	end

	-- Parts registered here stay hidden until the map turns into 8/32.
	local function revealLater(body)
		body:SetAttribute("Aug32Reveal",true)
		body:SetAttribute("Aug32Transparency",body.Transparency)
		body.Transparency=1
		body.CanCollide=false
		body.CanTouch=false
		body.CanQuery=false
		table.insert(result.Aug32Parts,body)
		return body
	end

	-- Reveals a whole folder of parts at once, so a built structure appears in one piece.
	local function revealFolderLater(holder)
		for _,desc in ipairs(holder:GetDescendants()) do
			if desc:IsA("BasePart") then revealLater(desc) end
		end
		return holder
	end

	for _,spec in ipairs(ZONES) do
		local name,display,x,y,z,width,depth,height=table.unpack(spec)
		local model=Instance.new("Model")
		model.Name=name
		model.Parent=rooms
		local f={}
		for _,key in ipairs({"Geometry","DoorPoints","EnemyPoints","AnomalyPoints","ItemPoints","GimmickPoints","SpecialPoints"}) do
			f[key]=folder(key,model)
		end
		local center=Vector3.new(x,y,z)
		local zone={Model=model,Center=center,Width=width,Depth=depth,Height=height,DisplayName=display,Folders=f}
		by[name]=zone
		table.insert(result.Rooms,zone)
		model:SetAttribute("Center",center)
		model:SetAttribute("Width",width)
		model:SetAttribute("Depth",depth)
		model:SetAttribute("DisplayName",display)

		local function localPart(n,size,offset,color,material,group)
			local body=part(n,size,center+offset,color,f.Geometry,material)
			if group then tint(group,body) end
			return body
		end

		-- Terraced ground: deep enough to read as a landform rather than a floating slab.
		localPart("Terrace",Vector3.new(width+30,60,depth+30),Vector3.new(0,-31,0),C.soil,Enum.Material.Ground,"Ground")
		local floorColor=(name=="RICE" or name=="RIVER" or name=="DAM") and C.drygrass or C.grass
		localPart("Ground",Vector3.new(width,2,depth),Vector3.new(0,-1,0),floorColor,Enum.Material.Grass,"Ground")

		-- Zone board plus a marker post: open ground otherwise loses all orientation cues.
		local board=localPart("ZoneSign",Vector3.new(math.min(width-16,46),5,.5),Vector3.new(0,7,depth/2-4),C.stone,Enum.Material.Concrete,"Structure")
		textFace(board,display)
		local post=localPart("ZonePost",Vector3.new(1.2,10,1.2),Vector3.new(-width/2+10,5,depth/2-14),C.stone,Enum.Material.Concrete,"Structure")
		sign(post,display,C.bright,6,180)
	end

	-- The valley base sits under every terrace, so gaps between zones read as slopes rather than holes.
	tint("Ground",part("ValleyBase",Vector3.new(1400,60,1240),Vector3.new(-60,958,140),Color3.fromRGB(86,104,66),links,Enum.Material.Grass))
	for _,peak in ipairs(RIDGES) do
		local body=part("Ridge",Vector3.new(240,110,240),peak,Color3.fromRGB(104,102,94),links,Enum.Material.Rock)
		body.CFrame=CFrame.new(peak)*CFrame.Angles(0,math.rad(rng:NextInteger(0,360)),0)*CFrame.Angles(math.rad(rng:NextInteger(2,8)),0,0)
		tint("Ground",body)
	end

	-- Trails: a sloped slab between two zone edges, wide enough to walk two abreast.
	-- Endpoints clamp onto the neighbour's span, so a trail never lands outside the terrace it targets.
	local function trail(a,b)
		local A,B=by[a],by[b]
		local delta=B.Center-A.Center
		local alongX=math.abs(delta.X)>math.abs(delta.Z)
		local function edge(zone,other)
			if alongX then
				local direction=math.sign(delta.X)
				local z=math.clamp(other.Center.Z,zone.Center.Z-zone.Depth/2+6,zone.Center.Z+zone.Depth/2-6)
				return zone.Center+Vector3.new(direction*zone.Width/2,0,z-zone.Center.Z)
			end
			local direction=math.sign(delta.Z)
			local x=math.clamp(other.Center.X,zone.Center.X-zone.Width/2+6,zone.Center.X+zone.Width/2-6)
			return zone.Center+Vector3.new(x-zone.Center.X,0,direction*zone.Depth/2)
		end
		local start=edge(A,B)
		local finish=edge(B,A)
		local length=(finish-start).Magnitude
		local mid=(start+finish)/2
		local f=folder(a.."_to_"..b,links)
		local body=part("Trail",Vector3.new(alongX and 20 or length+16,26,alongX and length+16 or 20),mid-Vector3.new(0,12,0),C.dirt,f,Enum.Material.Ground)
		body.CFrame=CFrame.lookAt(mid-Vector3.new(0,1,0),finish-Vector3.new(0,1,0))
		tint("Ground",body)
		f:SetAttribute("From",a)
		f:SetAttribute("To",b)
		return f
	end

	for _,edge in ipairs(TRAILS) do trail(edge[1],edge[2]) end

	-- Road surface and centre dashes follow the road zones.
	local function roadStrip(zone,length)
		local offset=Vector3.new(0,.15,0)
		tint("Road",part("Road",Vector3.new(20,1.2,length),zone.Center+offset,C.road,zone.Folders.Geometry,Enum.Material.Asphalt))
		for step=-length/2+6,length/2-6,14 do
			local dash=part("RoadLine",Vector3.new(.8,.08,8),zone.Center+offset+Vector3.new(0,.64,step),C.roadline,zone.Folders.Geometry)
			dash.CanCollide=false
			tint("Road",dash)
		end
	end

	roadStrip(by.LOBBY,74)
	roadStrip(by.ROAD,160)
	roadStrip(by.DAM,130)

	-- Power poles follow the road, giving the valley one readable direction.
	for z=72,240,32 do
		for _,side in ipairs({-1,1}) do
			tint("Structure",part("PowerPole",Vector3.new(1.4,30,1.4),Vector3.new(side*44,1004,z),C.stone,links,Enum.Material.Wood))
			tint("Structure",part("PowerArm",Vector3.new(14,1,1.4),Vector3.new(side*44,1034,z),C.stone,links,Enum.Material.Wood))
		end
	end

	-- LOBBY: bus stop on the shoulder. The evening return portal reuses this spot.
	local lobby=by.LOBBY
	local shelter=part("BusStop",Vector3.new(16,9,3),lobby.Center+Vector3.new(-18,4.5,-18),C.stone,lobby.Folders.Geometry,Enum.Material.Concrete)
	tint("Structure",shelter)
	tint("Structure",part("BusStopRoof",Vector3.new(18,1,9),shelter.Position+Vector3.new(0,5,3),C.roof,lobby.Folders.Geometry,Enum.Material.Slate))
	tint("Structure",part("Bench",Vector3.new(12,1.4,3),shelter.Position+Vector3.new(0,-3.2,0),C.roof,lobby.Folders.Geometry,Enum.Material.Wood))
	local busSign=part("BusSign",Vector3.new(1.4,11,1.4),lobby.Center+Vector3.new(-6,5.5,-18),C.red,lobby.Folders.Geometry,Enum.Material.Metal)
	tint("Structure",busSign)
	sign(busSign,"バス停 / 山あいの終点",C.bright,7,240)

	-- Date board: the only place the in-game date and phase are printed in world space.
	local function dateBoard(zone,offset)
		local body=part("DateBoard",Vector3.new(14,8,.6),zone.Center+offset,C.bright,zone.Folders.GimmickPoints,Enum.Material.Slate)
		table.insert(result.DateBoards,sign(body,Config.DateLabel.."\n"..Config.DateBoardClock,C.cyan,0,300))
		return body
	end
	dateBoard(lobby,Vector3.new(18,7,-18))
	dateBoard(by.VILLAGE,Vector3.new(34,9,52))

	-- RICE: flooded paddies, bunds between them, and the irrigation basin the pool sits in.
	local rice=by.RICE
	for row=1,2 do
		for column=1,3 do
			local x=190+(column-2)*44
			local z=296+(row-1)*52
			tint("Ground",part("Paddy",Vector3.new(38,1,22),rice.Center+Vector3.new(x-190,1,z-330),C.mud,rice.Folders.Geometry,Enum.Material.Ground))
			local water=part("PaddyWater",Vector3.new(36,.3,20),rice.Center+Vector3.new(x-190,2.1,z-330),C.water,rice.Folders.Geometry,Enum.Material.Glass)
			water.Transparency=.35
			water.CanCollide=false
			tint("Water",water)
		end
	end
	tint("Ground",part("PaddyBund",Vector3.new(150,2.4,4),rice.Center+Vector3.new(0,1.4,-4),C.soil,rice.Folders.Geometry,Enum.Material.Ground))
	for _,x in ipairs({168,212}) do
		tint("Ground",part("PaddyBund",Vector3.new(4,2.4,120),rice.Center+Vector3.new(x-190,1.4,0),C.soil,rice.Folders.Geometry,Enum.Material.Ground))
	end

	-- Shared building block: box body, gable roof, lit windows. Village and apartment reuse it.
	local function house(parent,position,size,roofColor,group)
		local body=part("House",size,position+Vector3.new(0,size.Y/2,0),C.wall,parent,Enum.Material.Concrete)
		tint("Structure",body)
		local pitch=Vector3.new(size.X+2,size.Y*.45,size.Z/2+1)
		local left=part("RoofLeft",pitch,position+Vector3.new(0,size.Y+pitch.Y/2,size.Z/4),roofColor,parent,Enum.Material.Slate)
		left.CFrame=CFrame.new(position+Vector3.new(0,size.Y+pitch.Y/2,size.Z/4))*CFrame.Angles(0,math.rad(-24),0)
		tint("Structure",left)
		local right=left:Clone()
		right.Name="RoofRight"
		right.CFrame=CFrame.new(position+Vector3.new(0,size.Y+pitch.Y/2,-size.Z/4))*CFrame.Angles(0,math.rad(24),0)
		right.Parent=parent
		tint("Structure",right)
		for level=1,math.max(1,math.floor(size.Y/10)) do
			for _,side in ipairs({-1,1}) do
				local window=part("Window",Vector3.new(5,4,.4),position+Vector3.new(side*size.X*.28,7+level*9,size.Z/2+.2),C.bright,parent,Enum.Material.Glass)
				window.Transparency=.4
				tint("Structure",window)
			end
		end
		return body
	end

	-- VILLAGE: shop street, community hall, vending machine, water tower.
	local village=by.VILLAGE
	for index=1,4 do
		house(village.Folders.Geometry,village.Center+Vector3.new(-46+(index-1)*30,0,-42),Vector3.new(22,14,20),index%2==0 and C.roof or Color3.fromRGB(96,72,64),"Structure")
	end
	house(village.Folders.Geometry,village.Center+Vector3.new(0,0,48),Vector3.new(40,20,28),C.roof,"Structure")
	local vending=part("Vending",Vector3.new(6,10,3),village.Center+Vector3.new(16,5,42),C.red,village.Folders.Geometry,Enum.Material.Metal)
	tint("Structure",vending)
	sign(vending,"自販機 / 冷えてます",C.bright,7,180)
	tint("Structure",part("WaterTank",Vector3.new(14,12,14),village.Center+Vector3.new(48,30,-12),C.stone,village.Folders.Geometry,Enum.Material.Metal))
	for _,x in ipairs({40,48,56}) do
		tint("Structure",part("TankLeg",Vector3.new(2,24,2),village.Center+Vector3.new(x,12,-12),C.stone,village.Folders.Geometry,Enum.Material.Metal))
	end

	-- SHRINE: terraced steps up the slope, a torii, and the main hall.
	local shrine=by.SHRINE
	for step=1,9 do
		tint("Structure",part("ShrineStep",Vector3.new(46-step*1.6,2.2,6),shrine.Center+Vector3.new(0,step*1.7,-34+step*3.4),C.stone,shrine.Folders.Geometry,Enum.Material.Slate))
	end
	local function torii(parent,position,color)
		local f=folder("Torii",parent)
		for _,side in ipairs({-1,1}) do
			tint("Structure",part("ToriiPost",Vector3.new(2.4,20,2.4),position+Vector3.new(side*10,10,0),color,f,Enum.Material.Wood))
		end
		tint("Structure",part("ToriiLintel",Vector3.new(28,2.4,3),position+Vector3.new(0,20,0),color,f,Enum.Material.Wood))
		tint("Structure",part("ToriiTie",Vector3.new(24,1.6,2.2),position+Vector3.new(0,16.6,0),color,f,Enum.Material.Wood))
		return f
	end
	torii(shrine.Folders.Geometry,shrine.Center+Vector3.new(0,19,-4),C.red)
	house(shrine.Folders.Geometry,shrine.Center+Vector3.new(0,6,22),Vector3.new(26,14,20),C.roof,"Structure")
	for _,side in ipairs({-1,1}) do
		tint("Structure",part("StoneLantern",Vector3.new(3,7,3),shrine.Center+Vector3.new(side*17,3.5,2),C.stone,shrine.Folders.Geometry,Enum.Material.Slate))
		tint("Structure",part("LanternLamp",Vector3.new(2.4,2.4,2.4),shrine.Center+Vector3.new(side*17,7.5,2),C.bright,shrine.Folders.Geometry,Enum.Material.Neon))
	end
	-- 8/32-only: a second gate standing halfway up the steps.
	revealFolderLater(torii(folder("SecondGate",shrine.Folders.SpecialPoints),shrine.Center+Vector3.new(0,10,-20),Color3.fromRGB(140,146,138)))

	-- RIVER: the channel, a bridge, and the stone lantern that acts as the Exposure source.
	local river=by.RIVER
	local channel=part("River",Vector3.new(34,1.4,170),river.Center,C.water,river.Folders.Geometry,Enum.Material.Glass)
	channel.Transparency=.4
	channel.CanCollide=false
	tint("Water",channel)
	for _,z in ipairs({-66,66}) do
		tint("Ground",part("RiverBank",Vector3.new(64,3,14),river.Center+Vector3.new(0,1,z),C.drygrass,river.Folders.Geometry,Enum.Material.Ground))
	end
	for _,x in ipairs({-19,19}) do
		tint("Structure",part("BridgePier",Vector3.new(4,12,4),river.Center+Vector3.new(x,6,0),C.stone,river.Folders.Geometry,Enum.Material.Slate))
	end
	tint("Structure",part("BridgeDeck",Vector3.new(48,2,14),river.Center+Vector3.new(0,13,0),C.stone,river.Folders.Geometry,Enum.Material.Slate))
	for _,x in ipairs({-23,23}) do
		tint("Structure",part("BridgeRail",Vector3.new(1.4,4,14),river.Center+Vector3.new(x,16,0),C.stone,river.Folders.Geometry,Enum.Material.Slate))
	end

	-- FOREST: cedar rows either side of a single forest road, thick enough to break sightlines.
	local forest=by.FOREST
	local function cedar(position,height,parent)
		tint("Foliage",part("CedarCanopy",Vector3.new(height*.34,height*.5,height*.34),position+Vector3.new(0,height*.62,0),C.cedar,parent,Enum.Material.Grass))
		tint("Foliage",part("CedarCanopy",Vector3.new(height*.22,height*.4,height*.22),position+Vector3.new(0,height*1.02,0),C.cedar,parent,Enum.Material.Grass))
		tint("Structure",part("CedarTrunk",Vector3.new(2.6,height,2.6),position+Vector3.new(0,height/2,0),C.bark,parent,Enum.Material.Wood))
	end
	tint("Ground",part("ForestRoad",Vector3.new(16,1.2,forest.Depth-16),forest.Center+Vector3.new(0,1,0),C.dirt,forest.Folders.Geometry,Enum.Material.Ground))
	for _=1,70 do
		local x=rng:NextNumber(-forest.Width/2+8,forest.Width/2-8)
		local z=rng:NextNumber(-forest.Depth/2+8,forest.Depth/2-8)
		if math.abs(x)>14 then cedar(forest.Center+Vector3.new(x,0,z),rng:NextNumber(26,40),forest.Folders.Geometry) end
	end
	for _=1,30 do
		local x=rng:NextNumber(-forest.Width/2+8,forest.Width/2-8)
		local z=rng:NextNumber(-forest.Depth/2+8,forest.Depth/2-8)
		tint("Foliage",part("Bush",Vector3.new(6,4,6),forest.Center+Vector3.new(x,2,z),C.cedar,forest.Folders.Geometry,Enum.Material.Grass))
	end

	-- TUNNEL: the only covered stretch. Dark, narrow, and the map's natural blind spot.
	-- The bore sits on the east edge so the dam trail and the forest trail both open into it.
	local tunnel=by.TUNNEL
	tint("Ground",part("TunnelFloor",Vector3.new(20,1.4,52),tunnel.Center+Vector3.new(30,0,0),C.rock,tunnel.Folders.Geometry,Enum.Material.Rock))
	tint("Ground",part("TunnelMass",Vector3.new(60,60,52),tunnel.Center+Vector3.new(-10,28,0),C.rock,tunnel.Folders.Geometry,Enum.Material.Rock))
	for step=0,3 do
		local z=tunnel.Center.Z-19+step*13
		local lid=part("TunnelRoof",Vector3.new(40,12,14),Vector3.new(tunnel.Center.X+30,tunnel.Center.Y+36,z),C.rock,tunnel.Folders.Geometry,Enum.Material.Rock)
		tint("Ground",lid)
		if step%2==0 then
			local bulb=part("TunnelLamp",Vector3.new(2,.6,2),Vector3.new(tunnel.Center.X+30,tunnel.Center.Y+29,z),C.bright,tunnel.Folders.GimmickPoints,Enum.Material.Neon)
			bulb.CanCollide=false
			local light=Instance.new("PointLight")
			light.Color=Color3.fromRGB(232,222,190)
			light.Range=48
			light.Brightness=.8
			light.Shadows=false
			light.Parent=bulb
		end
	end

	-- DAM: concrete wall across the valley, reservoir behind it, spillway on the east flank.
	local dam=by.DAM
	local reservoir=part("Reservoir",Vector3.new(160,1.4,34),dam.Center+Vector3.new(0,22,70),C.water,dam.Folders.Geometry,Enum.Material.Glass)
	reservoir.Transparency=.4
	reservoir.CanCollide=false
	tint("Water",reservoir)
	tint("Structure",part("DamWall",Vector3.new(170,50,12),dam.Center+Vector3.new(0,2,84),C.concrete,dam.Folders.Geometry,Enum.Material.Concrete))
	for _,x in ipairs({-78,78}) do
		tint("Structure",part("DamButtress",Vector3.new(10,44,22),dam.Center+Vector3.new(x,0,68),C.concrete,dam.Folders.Geometry,Enum.Material.Concrete))
		tint("Structure",part("DamRail",Vector3.new(1.4,4,160),dam.Center+Vector3.new(x,27,80),C.stone,dam.Folders.Geometry,Enum.Material.Slate))
	end
	tint("Structure",part("Spillway",Vector3.new(22,3,60),dam.Center+Vector3.new(58,-6,10),C.concrete,dam.Folders.Geometry,Enum.Material.Concrete))

	-- APARTMENT: the block on the hill. 8/32 puts every explorer here.
	local apartment=by.APARTMENT
	local block=house(apartment.Folders.Geometry,apartment.Center+Vector3.new(0,0,-30),Vector3.new(44,30,20),C.concrete,"Structure")
	textFace(block,"団地 / 最終日")
	for level=1,3 do
		for _,side in ipairs({-1,1}) do
			tint("Structure",part("BalconyRow",Vector3.new(24,1.4,6),apartment.Center+Vector3.new(side*28,7+level*9,-19),C.concrete,apartment.Folders.Geometry,Enum.Material.Concrete))
		end
	end
	tint("Structure",part("DormStairBlock",Vector3.new(10,26,14),apartment.Center+Vector3.new(0,0,4),C.stone,apartment.Folders.Geometry,Enum.Material.Concrete))
	-- 8/32-only: a duplicate lower wing in front of the block, with the same 団地 signage.
	local wingHolder=folder("Wing",apartment.Folders.SpecialPoints)
	local wing=house(wingHolder,apartment.Center+Vector3.new(6,0,26),Vector3.new(34,22,18),C.concrete,"Structure")
	textFace(wing,"団地 / 最終日")
	revealFolderLater(wingHolder)

	-- Spawn, lobby and entry follow the same contract as the existing maps.
	local spawn=Instance.new("SpawnLocation")
	spawn.Name="LobbySpawn"
	spawn.Anchored=true
	spawn.Size=Vector3.new(8,.2,8)
	spawn.Position=lobby.Center+Vector3.new(0,.1,24)
	spawn.Neutral=true
	spawn.Transparency=1
	spawn.Parent=lobby.Folders.SpecialPoints

	result.Lobby=lobby.Center+Vector3.new(0,4,24)
	result.Entry=by.ROAD.Center+Vector3.new(0,4,-40)
	result.Aug32Spawn=apartment.Center+Config.Aug32SpawnOffset
	result.SecretSpawn=forest.Center+Vector3.new(0,4,-70)
	result.KillY=960

	local function station(zone,name,offset,color,text,action,object)
		local body=part(name,Vector3.new(5,4,3),zone.Center+offset,color,zone.Folders.GimmickPoints,Enum.Material.Metal)
		sign(body,text,color)
		result.Prompts[name]=prompt(body,action,object or name)
		return body
	end

	-- Enter and Reroll match the existing maps, so the debug floor keeps working.
	station(lobby,"Enter",Vector3.new(0,2,-14),C.yellow,"8月31日\n夏休みの探索を始める","谷に入る","最終日")
	station(lobby,"Reroll",Vector3.new(24,2,14),C.yellow,"谷の構成を再抽選\n誰も探索していないときのみ","谷を再抽選","再抽選")
	-- The quest terminal. Operating it completes the request; the evening unlocks the return either way.
	station(village,"UnlockExit",Vector3.new(-30,2,52),C.yellow,"夏休み最終日\n帰還は夕方のバス停","最終日を確認する","掲示板")
	station(village,"Boss",Vector3.new(-46,2,44),C.yellow,"夏休みイベント\n思い出を撮る","思い出に載る","イベント")
	-- Return surfaces appear at the evening; the apartment is the last place on the hill.
	station(lobby,"Return",Vector3.new(-18,2,10),C.cyan,"バス停 / 最終の便","帰還する","バス停")
	station(apartment,"Extract",Vector3.new(0,2,50),C.cyan,"団地の管理室 / 最終日","脱出する","管理室")
	station(dam,"AnomalyExit",Vector3.new(-58,2,10),C.violet,"溜め池の底 / 異常状態の出口","帰還する","底")

	-- Observer: standing near it replays a record, which feeds the shared Exposure rule.
	local lanternPart=part("Observer",Vector3.new(5,6,3),river.Center+Vector3.new(-58,3,-40),C.violet,river.Folders.AnomalyPoints,Enum.Material.Neon)
	sign(lanternPart,"河原の石灯籠 / 近づくと記録が再生される",C.violet)
	result.Observer=lanternPart
	-- Pool: the irrigation basin. RunService keeps the 1-person heal / 2-person poison rule.
	local pool=part("HealingPool",Vector3.new(18,.3,18),rice.Center+Vector3.new(0,.2,-38),C.cyan,rice.Folders.GimmickPoints,Enum.Material.Neon)
	pool.CanCollide=false
	sign(pool,"泉 / 1人で回復・2人以上で毒",C.cyan)
	result.Pool=pool

	-- Secret: a hollow behind the shrine wall, only reachable in a transformed state.
	local hollow=part("Secret",Vector3.new(1,10,14),shrine.Center+Vector3.new(-44,5,10),C.violet,shrine.Folders.SpecialPoints)
	sign(hollow,"石垣の裏 / 異常状態",C.violet)
	result.Prompts.Secret=prompt(hollow,"境界を越える","石垣の裏")

	-- Ambience. Placeholder asset; the map owns one looping sound for the whole valley.
	local ambience=Instance.new("Sound")
	ambience.Name="Ambience"
	ambience.SoundId=Config.AmbienceId
	ambience.Volume=Config.AmbienceVolume
	ambience.Looped=true
	ambience.RollOffMaxDistance=Config.AmbienceRange
	ambience.Parent=root
	ambience:Play()
	result.Ambience=ambience

	return result
end

return M
