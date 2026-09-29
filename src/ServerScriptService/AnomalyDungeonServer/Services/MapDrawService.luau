-- 正式Runのマップ抽選。候補配列と重みだけを入力とし、プレイヤー状態を一切参照しない。
-- 将来、マップコンポーネント・所持品・スキル構成による重み付けは Config.Weights 側だけで拡張する。
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Config=require(ReplicatedStorage.AnomalyDungeon.Shared.Config.MapDrawConfig)
local MapDefinitions=require(ReplicatedStorage.AnomalyDungeon.Shared.Definitions.MapDefinitions)
local Service={}

function Service.GetCandidates() return table.clone(Config.Candidates) end

function Service.GetWeights()
	local weights={}
	local total=0
	for _,id in ipairs(Config.Candidates) do
		local weight=Config.Weights[id] or 0
		weights[id]=weight
		total+=weight
	end
	return weights,total
end

-- 等確率の完全ランダム。すべての重みが同値なら候補数に比例した一様分布になる。
function Service.Draw()
	local _,total=Service.GetWeights()
	if total<=0 then return Config.Candidates[1] end
	local roll=Random.new():NextNumber(0,total)
	local acc=0
	for _,id in ipairs(Config.Candidates) do
		acc+=(Config.Weights[id] or 0)
		if roll<acc then return id end
	end
	return Config.Candidates[#Config.Candidates]
end

function Service.IsCandidate(mapId)
	for _,id in ipairs(Config.Candidates) do if id==mapId then return true end end
	return false
end

function Service.GetDisplayName(mapId) return (MapDefinitions[mapId] or {}).DisplayName or mapId end

return Service
