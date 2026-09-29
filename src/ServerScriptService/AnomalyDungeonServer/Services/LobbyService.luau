-- 暫定の常設ロビー。都市ロビーとダンジョン入口ロビーは、生成ダンジンモデルとは別のRuntimeモデルとして
-- 作り直す。構造は機能検証用の最小ブロックで、最終アートでも2Dワールドマップでもない。
-- RunService とは依存を注入でつなぎ(requireの循環を避ける)。
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunConfig=require(ReplicatedStorage.AnomalyDungeon.Shared.Config.RunConfig)
local Config=require(ReplicatedStorage.AnomalyDungeon.Shared.Config.LobbyConfig)
local Service={}

local C={
	ground=Color3.fromRGB(96,98,104),
	pad=Color3.fromRGB(46,58,74),
	wall=Color3.fromRGB(150,152,158),
	cyan=Color3.fromRGB(80,218,202),
	yellow=Color3.fromRGB(236,203,70),
	dark=Color3.fromRGB(16,20,28),
}

local citySpawn, resultPad, entranceArrival, partyField, partySign, forcePrompt, cityBoard, entranceBoard

local function part(name,size,cf,color,parent,material)
	local body=Instance.new("Part")
	body.Name=name
	body.Size=size
	body.CFrame=cf
	body.Anchored=true
	body.Color=color
	body.Material=material or Enum.Material.SmoothPlastic
	body.TopSurface=Enum.SurfaceType.Smooth
	body.BottomSurface=Enum.SurfaceType.Smooth
	body.Parent=parent
	return body
end

local function board(parent,name,cf,text,color)
	local body=part(name,Vector3.new(46,14,1),cf,C.dark,parent,Enum.Material.Metal)
	local gui=Instance.new("SurfaceGui")
	gui.Name="Face"
	gui.Face=Enum.NormalId.Front
	gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud=20
	gui.Parent=body
	local label=Instance.new("TextLabel")
	label.Size=UDim2.fromScale(1,1)
	label.BackgroundTransparency=1
	label.TextColor3=color or C.cyan
	label.Font=Enum.Font.GothamBold
	label.TextScaled=true
	label.TextWrapped=true
	label.Text=text
	label.Parent=gui
	return body,label
end

local function promptPart(parent,name,cf,color,action,objectText,onTrigger)
	local body=part(name,Vector3.new(10,1,10),cf,color,parent,Enum.Material.Neon)
	local gui=Instance.new("BillboardGui")
	gui.Name="Sign"
	gui.Size=UDim2.fromOffset(300,72)
	gui.StudsOffset=Vector3.new(0,4,0)
	gui.MaxDistance=70
	gui.AlwaysOnTop=true
	gui.Parent=body
	local label=Instance.new("TextLabel")
	label.Size=UDim2.fromScale(1,1)
	label.BackgroundColor3=C.dark
	label.BackgroundTransparency=.15
	label.TextColor3=color
	label.Font=Enum.Font.GothamMedium
	label.TextSize=15
	label.TextWrapped=true
	label.Text=objectText
	label.Parent=gui
	local prompt=Instance.new("ProximityPrompt")
	prompt.ActionText=action
	prompt.ObjectText=objectText
	prompt.HoldDuration=.35
	prompt.MaxActivationDistance=12
	prompt.RequiresLineOfSight=false
	prompt.Parent=body
	prompt.Triggered:Connect(onTrigger)
	return body,prompt
end

local function buildRoom(name,origin,size)
	local model=Instance.new("Model")
	model.Name=name
	model.Parent=Workspace
	model:SetAttribute("RuntimeLobby",true)
	model:SetAttribute("Version",1)

	local cx,cz=size.X/2,size.Z/2
	part("Ground",Vector3.new(size.X,2,size.Z),CFrame.new(origin+Vector3.new(0,-1,0)),C.ground,model,Enum.Material.Concrete)
	part("Ceiling",Vector3.new(size.X,1,size.Z),CFrame.new(origin+Vector3.new(0,30,0)),Color3.fromRGB(48,50,56),model)
	for _,side in ipairs({"N","S","E","W"}) do
		local alongX=(side=="N" or side=="S")
		local span=alongX and size.X or size.Z
		local edge=alongX and size.Z or size.X
		local direction=(side=="S" or side=="E") and 1 or -1
		local wallSize=alongX and Vector3.new(span,30,2) or Vector3.new(2,30,span)
		local offset=alongX and Vector3.new(0,15,direction*edge/2) or Vector3.new(direction*edge/2,15,0)
		part("Wall_"..side,wallSize,CFrame.new(origin+offset),C.wall,model)
	end
	for ix=-1,1 do for iz=-1,1 do
		local lamp=part("Lamp",Vector3.new(9,.3,1.6),CFrame.new(origin+Vector3.new(ix*cx*.55,28,iz*cz*.55)),Color3.fromRGB(238,242,228),model,Enum.Material.Neon)
		local light=Instance.new("PointLight")
		light.Color=Color3.fromRGB(228,236,220)
		light.Range=70
		light.Brightness=1.1
		light.Shadows=false
		light.Parent=lamp
	end end
	return model
end

local function buildCity()
	local model=buildRoom("CityLobby",Config.CityOrigin,Config.CitySize)
	local origin=Config.CityOrigin

	citySpawn=Instance.new("SpawnLocation")
	citySpawn.Name="CityLobbySpawn"
	citySpawn.Size=Vector3.new(8,.2,8)
	citySpawn.CFrame=CFrame.new(origin+Config.CitySpawnOffset)
	citySpawn.Anchored=true
	citySpawn.Neutral=true
	citySpawn.Transparency=.35
	citySpawn.Material=Enum.Material.Neon
	citySpawn.Color=C.cyan
	citySpawn.Parent=model

	resultPad=part("ResultPad",Vector3.new(22,.2,22),CFrame.new(origin+Config.CityResultPadOffset),Color3.fromRGB(120,132,150),model)
	resultPad.CanCollide=false

	_,cityBoard=board(model,"CityBoard",CFrame.new(origin+Config.CityBoardOffset),"ANOMALY DUNGEON\n都市ロビー\nダンジョン入口ロビーへ移動してパーティを組む",C.cyan)

	promptPart(model,"ToDungeonEntrance",CFrame.new(origin+Config.CityEntrancePadOffset),C.cyan,"ダンジョン入口ロビーへ","DUNGEON ENTRANCE",function(player)
		Service.Teleport(player,"Entrance")
		player:SetAttribute("LobbyState",RunConfig.LobbyEntrance)
	end)
end

local function buildEntrance()
	local model=buildRoom("DungeonEntranceLobby",Config.EntranceOrigin,Config.EntranceSize)
	local origin=Config.EntranceOrigin

	local arrival=part("Arrival",Vector3.new(22,.2,22),CFrame.new(origin+Config.EntranceArrivalOffset),Color3.fromRGB(120,132,150),model)
	arrival.CanCollide=false
	entranceArrival=arrival

	_,entranceBoard=board(model,"EntranceBoard",CFrame.new(origin+Config.EntranceBoardOffset),"DUNGEON ENTRANCE\nパーティ用フィールドへ立つと受付開始\n先着順 / 上限5人 / 30秒で出発",C.yellow)

	partyField=part("PartyField",Config.PartyFieldSize,CFrame.new(origin+Config.PartyFieldCenter),Color3.fromRGB(58,74,96),model,Enum.Material.Metal)
	partyField:SetAttribute("PartyField",true)
	local edgeColor=Color3.fromRGB(120,180,220)
	for _,side in ipairs({"N","S","E","W"}) do
		local alongX=(side=="N" or side=="S")
		local span=alongX and Config.PartyFieldSize.X or Config.PartyFieldSize.Z
		local offset=alongX and Vector3.new(0,.6,(side=="S" and 1 or -1)*Config.PartyFieldSize.Z/2) or Vector3.new((side=="E" and 1 or -1)*Config.PartyFieldSize.X/2,.6,0)
		part("PartyFieldEdge_"..side,alongX and Vector3.new(span,1,1) or Vector3.new(1,1,span),CFrame.new(origin+Config.PartyFieldCenter+offset),edgeColor,model,Enum.Material.Neon)
	end
	local fieldGui=Instance.new("BillboardGui")
	fieldGui.Name="Sign"
	fieldGui.Size=UDim2.fromOffset(340,110)
	fieldGui.StudsOffset=Vector3.new(0,8,0)
	fieldGui.MaxDistance=120
	fieldGui.AlwaysOnTop=true
	fieldGui.Parent=partyField
	partySign=Instance.new("TextLabel")
	partySign.Size=UDim2.fromScale(1,1)
	partySign.BackgroundColor3=C.dark
	partySign.BackgroundTransparency=.15
	partySign.TextColor3=C.yellow
	partySign.Font=Enum.Font.GothamBold
	partySign.TextSize=18
	partySign.TextWrapped=true
	partySign.Text="PARTY FIELD\n参加者 0 / "..Config.PartyMax.."\n受付していません"
	partySign.Parent=fieldGui

	local _,force=promptPart(model,"ForceClose",CFrame.new(origin+Config.ForceClosePadOffset),Color3.fromRGB(224,64,64),Config.ForceCloseAction,Config.ForceCloseObject,function() end)
	force:SetAttribute("DebugOnly",true)
	forcePrompt=force

	promptPart(model,"ToCityLobby",CFrame.new(origin+Config.EntranceReturnPadOffset),C.cyan,"都市ロビーへ戻る","CITY LOBBY",function(player)
		Service.Teleport(player,"City")
		player:SetAttribute("LobbyState",RunConfig.LobbyCity)
	end)
end

function Service.Start()
	local existingCity=Workspace:FindFirstChild("CityLobby")
	local existingEntrance=Workspace:FindFirstChild("DungeonEntranceLobby")
	if existingCity then existingCity:Destroy() end
	if existingEntrance then existingEntrance:Destroy() end
	buildCity()
	buildEntrance()
	print("[LOBBY] city + dungeon entrance ready")
	return Service
end

function Service.GetCitySpawn() return citySpawn end
function Service.GetForceClosePrompt() return forcePrompt end

function Service.Teleport(player,where)
	if not player.Character then return false end
	local target
	if where=="City" then target=citySpawn.CFrame+Vector3.new(0,4,0)
	elseif where=="Result" then target=resultPad.CFrame+Vector3.new(0,4,0)
	else target=entranceArrival.CFrame+Vector3.new(0,4,0) end
	player.Character:PivotTo(target)
	return true
end

function Service.SendToCity(player)
	Service.Teleport(player,"City")
	player:SetAttribute("LobbyState",RunConfig.LobbyCity)
end

-- パーティ用フィールドの判定は箱のXZ寸法とY許容で行う。Touchイベントには依存しない。
function Service.IsInPartyField(player)
	local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local center=Config.EntranceOrigin+Config.PartyFieldCenter
	local half=Config.PartyFieldSize/2
	local delta=root.Position-center
	return math.abs(delta.X)<=half.X and math.abs(delta.Z)<=half.Z and math.abs(delta.Y)<=Config.PartyFieldYTolerance
end

function Service.SetPartySign(text)
	if partySign then partySign.Text=text end
end

function Service.SetBoards(runState,partyCount,recruitRemaining)
	-- 都市側看板は案内文を常時保つ。Run状態は行として足すだけなので、0.25秒ごとの更新でも
	-- 「入口ロビーへ移動する」手順が消えない。Run中は参加できない状態の通知にもなる。
	if cityBoard then
		cityBoard.Text="ANOMALY DUNGEON\n都市ロビー\nダンジョン入口ロビーへ移動してパーティを組む\nRun状態: "..tostring(runState or RunConfig.RunStateIdle)
	end
	if entranceBoard then
		local detail
		if recruitRemaining and recruitRemaining>0 then
			detail=string.format("参加者 %d / %d\n受付締切まで %d秒",partyCount or 0,Config.PartyMax,math.ceil(recruitRemaining))
		else
			detail=string.format("参加者 %d / %d\nRun状態: %s",partyCount or 0,Config.PartyMax,tostring(runState or RunConfig.RunStateIdle))
		end
		entranceBoard.Text="DUNGEON ENTRANCE\nパーティ用フィールドへ立つと受付開始\n"..detail
	end
end

return Service
