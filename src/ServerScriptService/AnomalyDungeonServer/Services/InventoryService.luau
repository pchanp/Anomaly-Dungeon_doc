-- Inventory／Secure Slot のサーバー権威データ境界。正式なLootもアイテムシステムもまだ無いため、
-- ここで扱うのは枠数と結果分類だけ。アイテムはデバッグ付与経路でしか作らない。
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunConfig=require(ReplicatedStorage.AnomalyDungeon.Shared.Config.RunConfig)
local Service={}
local items={}

local function secureCapacity(player)
	local value=player:GetAttribute("SecureSlotCapacity")
	if type(value)~="number" then return RunConfig.SecureSlots end
	return math.clamp(math.floor(value),0,RunConfig.InventorySlots)
end

local function countSecure(list)
	local total=0
	for _,item in ipairs(list) do if item.Secure then total+=1 end end
	return total
end

local function sync(player)
	local list=items[player] or {}
	player:SetAttribute("InventoryUsed",#list)
	player:SetAttribute("SecureUsed",countSecure(list))
	player:SetAttribute("InventoryCapacity",RunConfig.InventorySlots)
	player:SetAttribute("SecureSlotCapacity",secureCapacity(player))
end

function Service.Setup(player)
	if items[player]==nil then items[player]={} end
	sync(player)
end

function Service.List(player)
	local out={}
	for _,item in ipairs(items[player] or {}) do
		table.insert(out,{Id=item.Id,Name=item.Name,Secure=item.Secure})
	end
	return out
end

-- 枠が溢れた場合は付与しない。自動廃棄や容量の創作は行わない。
function Service.Grant(player,id,name,secure)
	Service.Setup(player)
	local list=items[player]
	if #list>=RunConfig.InventorySlots then return false,"InventoryFull" end
	if secure and countSecure(list)>=secureCapacity(player) then return false,"SecureFull" end
	table.insert(list,{Id=id,Name=name,Secure=secure==true})
	sync(player)
	return true
end

function Service.Remove(player,id)
	local list=items[player]
	if not list then return false end
	for index,item in ipairs(list) do
		if item.Id==id then table.remove(list,index) sync(player) return true end
	end
	return false
end

-- 成功なら所持中の全持ち帰り対象を獲得物にする。失敗ならSecure Slot内だけを残し、残りを失う。
-- 判定と実際の破棄はここで行い、リザルト画面は分類結果を受け取るだけ。
function Service.Settle(player,success)
	local kept,gained,lost={},{},{}
	for _,item in ipairs(items[player] or {}) do
		local entry={Id=item.Id,Name=item.Name,Secure=item.Secure}
		if success or item.Secure then
			table.insert(kept,item)
			table.insert(gained,entry)
		else
			table.insert(lost,entry)
		end
	end
	items[player]=kept
	sync(player)
	return gained,lost
end

-- デバッグ専用の付与経路。正式な取得源は未実装なので、ここ以外からアイテムを作らない。
function Service.DebugGrant(player)
	local normal=Service.Grant(player,"DEBUG_ITEM","デバッグアイテム（通常枠）",false)
	local secure=Service.Grant(player,"DEBUG_SECURE_ITEM","デバッグアイテム（Secure Slot）",true)
	return normal,secure
end

function Service.Release(player) items[player]=nil end

Players.PlayerRemoving:Connect(function(player) Service.Release(player) end)

return Service
