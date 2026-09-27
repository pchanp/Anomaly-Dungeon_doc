local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage:WaitForChild("AnomalyDungeon"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("RunConfig"))
local Notice=ReplicatedStorage:WaitForChild("AnomalyNotice")
local Service={}
local transformedPlayer

function Service.Setup(player)
	if player:GetAttribute("AnomalyExposure")==nil then player:SetAttribute("AnomalyExposure",Config.ExposureMin) end
	if player:GetAttribute("PlayerAnomalyState")==nil then player:SetAttribute("PlayerAnomalyState",Config.PlayerAnomalyNormal) end
	if player:GetAttribute("RunLifetimeRemaining")==nil then player:SetAttribute("RunLifetimeRemaining",Config.TransformedLifetimeSeconds) end
	if player:GetAttribute("RunLifetimeTicks")==nil then player:SetAttribute("RunLifetimeTicks",Config.NormalLifetimeTicks) end
end

function Service.Get(player) return player:GetAttribute("AnomalyExposure") or Config.ExposureMin end
function Service.IsTransformed(player) return player:GetAttribute("PlayerAnomalyState")==Config.PlayerAnomalyTransformed end

function Service.Set(player,value)
	Service.Setup(player)
	value=math.clamp(value,Config.ExposureMin,Config.ExposureMax)
	if value>=Config.TransformationThreshold and not Service.IsTransformed(player) then
		if not transformedPlayer then
			transformedPlayer=player
			player:SetAttribute("PlayerAnomalyState",Config.PlayerAnomalyTransformed)
			player:SetAttribute("PlayerRunState",Config.PlayerRunTransformed)
			player:SetAttribute("RunLifetimeRemaining",Config.TransformedLifetimeSeconds)
			player:SetAttribute("RunLifetimeTicks",true)
			Notice:FireClient(player,"世界があなたを認識しなくなった。VHS売場の境界へ。")
		else
			value=math.min(value,Config.TransformationThreshold-1)
		end
	end
	player:SetAttribute("AnomalyExposure",value)
	return value
end

function Service.Add(player,delta) return Service.Set(player,Service.Get(player)+delta) end
function Service.Reset(player)
	if transformedPlayer==player then transformedPlayer=nil end
	player:SetAttribute("AnomalyExposure",Config.ExposureMin)
	player:SetAttribute("PlayerAnomalyState",Config.PlayerAnomalyNormal)
	player:SetAttribute("RunLifetimeRemaining",Config.TransformedLifetimeSeconds)
	player:SetAttribute("RunLifetimeTicks",Config.NormalLifetimeTicks)
end
function Service.Release(player) if transformedPlayer==player then transformedPlayer=nil end end

return Service
