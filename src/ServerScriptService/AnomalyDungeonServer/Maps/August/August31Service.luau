-- 8月31日 clock: 8/31 day -> evening -> night -> 8/32.
-- Server authoritative. The service owns the map's Lighting values only while the map is active
-- and restores them on Unbind, so switching back to an indoor map leaves no residue.
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local RS=game:GetService("ReplicatedStorage")
local Config=require(RS.AnomalyDungeon.Shared.Config.AugustConfig)
local Notice=RS:WaitForChild("AnomalyNotice")
local State=RS:WaitForChild("AnomalyState")

local Service={}
local world
local host
local phase=Config.PhaseOrder[1]
local fromPhase=phase
local elapsed=0
local blend=1
local lastReturn
local started=false

local function tell(player,text) Notice:FireClient(player,text) end

-- The place already has a Sky and an Atmosphere, so the sky is driven through the Atmosphere
-- rather than by swapping Skybox images. Both containers are borrowed and restored verbatim.
local LIGHT_PROPS={"Ambient","OutdoorAmbient","Brightness","FogColor","FogStart","FogEnd","ColorShift_Top","ColorShift_Bottom"}
local ATMOS_PROPS={"Color","Density","Haze","Glare"}
local atmos=Lighting:FindFirstChildOfClass("Atmosphere")

local baseline

local function capture()
	if baseline then return end
	baseline={Lighting={},Atmosphere={}}
	for _,name in ipairs(LIGHT_PROPS) do baseline.Lighting[name]=Lighting[name] end
	if atmos then for _,name in ipairs(ATMOS_PROPS) do baseline.Atmosphere[name]=atmos[name] end end
end

local function restore()
	if not baseline then return end
	for name,value in pairs(baseline.Lighting) do Lighting[name]=value end
	if atmos then for name,value in pairs(baseline.Atmosphere) do atmos[name]=value end end
	baseline=nil
end

-- Numeric and Color3 properties both interpolate; the rest are left at their captured value.
local function mix(target,source,from,to,t)
	for name,value in pairs(target) do
		local a,b=from[name],to[name]
		if typeof(a)=="Color3" and typeof(b)=="Color3" then
			source[name]=a:Lerp(b,t)
		elseif type(a)=="number" and type(b)=="number" then
			source[name]=a+(b-a)*t
		else
			source[name]=value
		end
	end
end

local function tintFor(group,phaseName)
	local entry=(Config.Tints[phaseName] or {})[group]
	if not entry then return nil end
	return entry.Color,entry.Weight
end

-- Paints the world for a blend between two phases. DAY holds the authored colours untouched.
local function apply()
	for group,entries in pairs(world.Tints) do
		local fromColor,fromWeight=tintFor(group,fromPhase)
		local toColor,toWeight=tintFor(group,phase)
		for _,entry in ipairs(entries) do
			local color=entry.Base
			if fromColor then color=color:Lerp(fromColor,fromWeight) end
			if toColor then color=color:Lerp(toColor,toWeight) end
			entry.Part.Color=color
		end
	end
	if not baseline then return end
	mix(baseline.Lighting,Lighting,Config.Lighting[fromPhase] or {},Config.Lighting[phase] or {},blend)
	if atmos then mix(baseline.Atmosphere,atmos,Config.Atmosphere[fromPhase] or {},Config.Atmosphere[phase] or {},blend) end
end

-- Anyone inside the map is on the clock; the valley does not advance while it is empty.
local function explorers()
	local inside={}
	for _,player in ipairs(Players:GetPlayers()) do
		if player:GetAttribute("InDungeon") then table.insert(inside,player) end
	end
	return inside
end

local function setReturn(available)
	if available==lastReturn then return end
	lastReturn=available
	if host and host.SetExitUnlocked then host.SetExitUnlocked(available) end
end

local function revealAug32()
	for _,body in ipairs(world.Aug32Parts) do
		if body.Parent then
			body.Transparency=body:GetAttribute("Aug32Transparency") or 0
			body.CanCollide=true
			body.CanTouch=true
			body.CanQuery=true
		end
	end
	world.Root:SetAttribute("Aug32Reveal",true)
end

local function updateBoards(dateLabel,text)
	for _,board in ipairs(world.DateBoards) do board.Text=text end
	world.Root:SetAttribute("MapPhase",phase)
	State:SetAttribute("MapPhase",phase)
	State:SetAttribute("DateLabel",dateLabel)
end

-- 8/32 is a state change of the same map: the return surfaces close, dangers rise, and every
-- explorer gets a Run Lifetime, so the only way out is the forced termination.
local function beginAug32()
	phase="AUG_32"
	fromPhase="NIGHT"
	elapsed=0
	blend=0
	-- Called directly rather than through setReturn: 8/32 must close the way out even when the
	-- cached flag already reads false.
	if host and host.SetExitUnlocked then host.SetExitUnlocked(false) end
	lastReturn=false
	revealAug32()
	-- Dangers rise with the date: RunService scales the shared Exposure rate by this factor.
	world.ExposureMultiplier=Config.Aug32ExposureMultiplier
	local spawn=world.Aug32Spawn or world.Lobby
	for _,player in ipairs(explorers()) do
		if player.Character then player.Character:PivotTo(CFrame.new(spawn)) end
		player:SetAttribute("RunLifetimeTicks",true)
		player:SetAttribute("RunLifetimeRemaining",Config.Aug32LifetimeSeconds)
		player:SetAttribute("PlayerRunState","EXPLORING")
		player:SetAttribute("QuestObjective","8月32日まで生き延びる")
		tell(player,Config.Notice.AUG_32)
	end
	updateBoards(Config.Aug32DateLabel,Config.Aug32DateLabel.."\n"..Config.DateBoardClock)
	State:SetAttribute("Aug32Active",true)
	apply()
end

local function advance()
	local nextPhase=Config.PhaseOrder[table.find(Config.PhaseOrder,phase)+1]
	if not nextPhase then
		beginAug32()
		return
	end
	fromPhase=phase
	phase=nextPhase
	elapsed=0
	blend=0
	updateBoards(Config.DateLabel,Config.DateLabel.."\n"..Config.DateBoardClock)
	for _,player in ipairs(explorers()) do
		if Config.Notice[phase] then tell(player,Config.Notice[phase]) end
	end
end

-- The return path opens for everyone at the evening. Using the quest terminal also opens it,
-- which is why the two are tracked separately instead of collapsing into one flag.
local function syncReturn()
	if phase=="AUG_32" then return end
	local evening=phase=="EVENING" or phase=="NIGHT"
	setReturn(evening or State:GetAttribute("ExitUnlocked")==true)
end

function Service.Bind(targetWorld,targetHost)
	Service.Unbind()
	-- Only the 8月31日 map runs this clock; every other map leaves the environment alone.
	if not targetWorld or targetWorld.Root:GetAttribute("MapId")~="AUGUST_31" then return end
	world=targetWorld
	host=targetHost
	phase=Config.PhaseOrder[1]
	fromPhase=phase
	elapsed=0
	blend=1
	lastReturn=nil
	started=false
	capture()
	world.ExposureMultiplier=1
	updateBoards(Config.DateLabel,Config.DateLabel.."\n"..Config.DateBoardClock)
	State:SetAttribute("Aug32Active",false)
	apply()
	setReturn(false)
end

-- Drops the borrowed Lighting values and forgets the map. Build() rebinds afterwards.
function Service.Unbind()
	if not world then return end
	restore()
	world=nil
	host=nil
end

function Service.GetPhase() return phase end

function Service.Tick(dt)
	if not world then return end
	-- The blend keeps running even when the valley empties, so a phase never freezes half-applied.
	if blend<1 then
		blend=math.min(1,blend+dt/(Config.PhaseBlendSeconds or 1))
		apply()
	end
	if phase=="AUG_32" then return end
	local inside=explorers()
	if #inside==0 then return end
	if Config.StartOnFirstEntry and not started then started=true end
	if not started then return end
	elapsed=elapsed+dt
	if elapsed>=(Config.PhaseSeconds[phase] or 0) then advance() end
	syncReturn()
end

return Service
