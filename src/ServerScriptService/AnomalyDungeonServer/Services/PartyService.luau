-- ダンジョン入口ロビーのパーティ受付。サーバー権威で、フィールド内の在圏だけを参加者として扱う。
-- 抽選は MapDrawService、遷移と終了通知は RunService、判定用の配置は LobbyService へ依存注入でつなぐ。
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunConfig=require(ReplicatedStorage.AnomalyDungeon.Shared.Config.RunConfig)
local Config=require(ReplicatedStorage.AnomalyDungeon.Shared.Config.LobbyConfig)
local MapDraw=require(script.Parent.MapDrawService)
local Service={}

local host,lobby
local order={}
local member=setmetatable({}, {__mode="k"})
local recruiting=false
local deadline=0
local fullNotified=setmetatable({}, {__mode="k"})
local busyNotified=setmetatable({}, {__mode="k"})
local TICK=0.25

local function tell(player,text) host.Tell(player,text) end
local function count() return #order end

local function add(player)
	if member[player] then return end
	if count()>=Config.PartyMax then
		if not fullNotified[player] then
			fullNotified[player]=true
			tell(player,string.format("パーティは上限 %d 人です。フィールドの外で待機してください。",Config.PartyMax))
		end
		return
	end
	member[player]=true
	table.insert(order,player)
	player:SetAttribute("LobbyState",RunConfig.LobbyParty)
	if recruiting then
		tell(player,string.format("パーティ受付に参加しました / %d 人 / 締め切りまで %d 秒",count(),math.max(0,math.ceil(deadline-os.clock()))))
	end
end

local function remove(player)
	if not member[player] then return end
	member[player]=nil
	fullNotified[player]=nil
	for index,other in ipairs(order) do
		if other==player then table.remove(order,index) break end
	end
	if player.Parent==Players then player:SetAttribute("LobbyState",RunConfig.LobbyEntrance) end
end

local function clear()
	for _,player in ipairs(order) do member[player]=nil end
	table.clear(order)
	recruiting=false
	deadline=0
end

local function refresh()
	local remaining=recruiting and math.max(0,deadline-os.clock()) or 0
	lobby.SetPartySign(string.format("PARTY FIELD\n参加者 %d / %d\n%s",count(),Config.PartyMax,
		recruiting and string.format("受付中 / 残り %d 秒",math.ceil(remaining)) or "受付していません"))
	lobby.SetBoards(host.GetRunState(),count(),remaining)
end

local function beginRecruit()
	if recruiting or count()==0 then return end
	recruiting=true
	deadline=os.clock()+Config.RecruitSeconds
	host.SetRunState(RunConfig.RunStateRecruiting)
	for _,player in ipairs(order) do
		tell(player,string.format("パーティ受付を開始します。%d 秒後に出発します。",Config.RecruitSeconds))
	end
end

-- reason は TIME_UP（30秒満了）か FORCE_CLOSE（デバッグ用強制締切スイッチ）。
local function depart(reason)
	recruiting=false
	deadline=0
	if count()==0 then
		clear()
		host.SetRunState(RunConfig.RunStateIdle)
		refresh()
		return
	end
	local party={}
	for _,player in ipairs(order) do table.insert(party,player) end
	host.SetRunState(RunConfig.RunStateDeparting)
	-- 抽選は候補と重みだけを入力とする。参加者・Quest・所持品・スキル構成は参照しない。
	local mapId=MapDraw.Draw()
	-- マップ生成は重いので、受付ループの実行予算と合算させない。同一スレッドで走らせると
	-- script timeout で中断された。clear と refresh は生成の完了を待たずに進める。
	task.spawn(function() host.StartRun(party,mapId,reason) end)
	clear()
	refresh()
end

local function syncField()
	local runState=host.GetRunState()
	if runState==RunConfig.RunStateIdle or runState==RunConfig.RunStateRecruiting then
		for _,player in ipairs(Players:GetPlayers()) do
			if lobby.IsInPartyField(player) then add(player) else remove(player) end
		end
		for player in pairs(member) do
			if player.Parent~=Players or not lobby.IsInPartyField(player) then remove(player) end
		end
	else
		-- 進行中Runへの途中参加は不可。フィールド内にいても参加はさせない。
		for _,player in ipairs(Players:GetPlayers()) do
			if lobby.IsInPartyField(player) and not busyNotified[player] then
				busyNotified[player]=true
				tell(player,"Run進行中です。このRunへの途中参加はできません。")
			end
		end
		for player in pairs(busyNotified) do
			if player.Parent~=Players or not lobby.IsInPartyField(player) then busyNotified[player]=nil end
		end
	end
end

function Service.Start(runHost,lobbyHost)
	host=runHost
	lobby=lobbyHost
	clear()
	host.SetRunState(RunConfig.RunStateIdle)

	local prompt=lobby.GetForceClosePrompt()
	if prompt then
		prompt.Triggered:Connect(function(player)
			if recruiting then
				tell(player,"受付を強制締切して出発します。")
				depart("FORCE_CLOSE")
			else
				tell(player,"現在パーティ受付していません。")
			end
		end)
	end

	Players.PlayerRemoving:Connect(function(player)
		remove(player)
		if count()==0 and (recruiting or host.GetRunState()==RunConfig.RunStateRecruiting) then
			clear()
			host.SetRunState(RunConfig.RunStateIdle)
		end
		refresh()
	end)

	task.spawn(function()
		while true do
			task.wait(TICK)
			syncField()
			local runState=host.GetRunState()
			if runState==RunConfig.RunStateIdle then
				beginRecruit()
			elseif recruiting and os.clock()>=deadline then
				depart("TIME_UP")
			elseif recruiting and count()==0 then
				clear()
				host.SetRunState(RunConfig.RunStateIdle)
			end
			refresh()
		end
	end)
	return Service
end

function Service.Reset()
	clear()
	fullNotified=setmetatable({}, {__mode="k"})
	busyNotified=setmetatable({}, {__mode="k"})
	if host then host.SetRunState(RunConfig.RunStateIdle) end
end

function Service.GetCount() return count() end
function Service.IsRecruiting() return recruiting end

return Service
