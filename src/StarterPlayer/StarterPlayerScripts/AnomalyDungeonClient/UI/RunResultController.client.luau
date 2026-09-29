-- RunResultController: サーバーが確定した結果だけをそのまま表示するリザルト画面。
-- 成功/失敗、獲得物、喪失物、Quest達成状況、Credits変化は判定しない。判定済みの値だけを受ける。
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("AnomalyRunRemotes")
local Result=remotes:WaitForChild("Result")
local Request=remotes:WaitForChild("ResultRequest")

local gui=Instance.new("ScreenGui")
gui.Name="RunResult"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=false
gui.DisplayOrder=10
gui.Enabled=false
gui.Parent=player:WaitForChild("PlayerGui")

local shade=Instance.new("Frame")
shade.Name="Shade"
shade.Size=UDim2.fromScale(1,1)
shade.BackgroundColor3=Color3.fromRGB(6,9,14)
shade.BackgroundTransparency=.25
shade.BorderSizePixel=0
shade.Parent=gui

local panel=Instance.new("Frame")
panel.Name="Panel"
panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5)
panel.Size=UDim2.new(0,520,0,484)
panel.BackgroundColor3=Color3.fromRGB(14,19,27)
panel.BorderSizePixel=0
panel.Parent=shade
local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,12)
corner.Parent=panel
local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(70,84,104)
stroke.Thickness=2
stroke.Parent=panel

local title=Instance.new("TextLabel")
title.Name="Outcome"
title.Position=UDim2.fromOffset(24,18)
title.Size=UDim2.new(1,-48,0,40)
title.BackgroundTransparency=1
title.TextColor3=Color3.fromRGB(219,233,239)
title.Font=Enum.Font.GothamBold
title.TextSize=26
title.TextXAlignment=Enum.TextXAlignment.Left
title.Text="RESULT"
title.Parent=panel

local subtitle=Instance.new("TextLabel")
subtitle.Name="Map"
subtitle.Position=UDim2.fromOffset(24,58)
subtitle.Size=UDim2.new(1,-48,0,24)
subtitle.BackgroundTransparency=1
subtitle.TextColor3=Color3.fromRGB(150,166,180)
subtitle.Font=Enum.Font.GothamMedium
subtitle.TextSize=15
subtitle.TextXAlignment=Enum.TextXAlignment.Left
subtitle.Text=""
subtitle.Parent=panel

local function block(name,y,height,header)
	local frame=Instance.new("Frame")
	frame.Name=name
	frame.Position=UDim2.fromOffset(24,y)
	frame.Size=UDim2.new(1,-48,0,height)
	frame.BackgroundColor3=Color3.fromRGB(22,29,40)
	frame.BorderSizePixel=0
	frame.Parent=panel
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,8)
	c.Parent=frame
	local head=Instance.new("TextLabel")
	head.Name="Header"
	head.Position=UDim2.fromOffset(12,6)
	head.Size=UDim2.new(1,-24,0,20)
	head.BackgroundTransparency=1
	head.TextColor3=Color3.fromRGB(150,166,180)
	head.Font=Enum.Font.GothamBold
	head.TextSize=13
	head.TextXAlignment=Enum.TextXAlignment.Left
	head.Text=header
	head.Parent=frame
	local body=Instance.new("TextLabel")
	body.Name="Body"
	body.Position=UDim2.fromOffset(12,28)
	body.Size=UDim2.new(1,-24,1,-34)
	body.BackgroundTransparency=1
	body.TextColor3=Color3.fromRGB(226,236,240)
	body.Font=Enum.Font.GothamMedium
	body.TextSize=15
	body.TextWrapped=true
	body.TextXAlignment=Enum.TextXAlignment.Left
	body.TextYAlignment=Enum.TextYAlignment.Top
	body.Text=""
	body.Parent=frame
	return body
end

local questBody=block("Quests",90,96,"保有Questの達成状況")
local gainedBody=block("Gained",192,96,"獲得物")
local lostBody=block("Lost",294,96,"喪失物")

local footer=Instance.new("TextLabel")
footer.Name="Footer"
footer.Position=UDim2.fromOffset(24,394)
footer.Size=UDim2.new(1,-48,0,20)
footer.BackgroundTransparency=1
footer.TextColor3=Color3.fromRGB(150,166,180)
footer.Font=Enum.Font.GothamMedium
footer.TextSize=14
footer.TextXAlignment=Enum.TextXAlignment.Left
footer.Text=""
footer.Parent=panel

local button=Instance.new("TextButton")
button.Name="ReturnToCity"
button.AnchorPoint=Vector2.new(.5,0)
button.Position=UDim2.new(.5,0,0,416)
button.Size=UDim2.new(1,-48,0,44)
button.BackgroundColor3=Color3.fromRGB(80,218,202)
button.BorderSizePixel=0
button.TextColor3=Color3.fromRGB(8,16,20)
button.Font=Enum.Font.GothamBold
button.TextSize=17
button.Text="都市ロビーへ戻る"
button.Parent=panel
local bcorner=Instance.new("UICorner")
bcorner.CornerRadius=UDim.new(0,8)
bcorner.Parent=button

local QUEST_LABELS={COMPLETED="達成",FAILED="未達成"}
local function listText(list,emptyText)
	if type(list)~="table" or #list==0 then return emptyText end
	local lines={}
	for _,entry in ipairs(list) do table.insert(lines,tostring(entry.Name or entry.Id or "?")) end
	return table.concat(lines,"\n")
end

local showing=false

button.Activated:Connect(function()
	if not showing then return end
	showing=false
	gui.Enabled=false
	Request:FireServer()
end)

Result.OnClientEvent:Connect(function(data)
	if type(data)~="table" then return end
	showing=true
	gui.Enabled=true
	local success=data.Success==true
	title.Text=string.format("%s / %s",tostring(data.OutcomeLabel or "RESULT"),success and "成功" or "失敗")
	title.TextColor3=success and Color3.fromRGB(140,226,150) or Color3.fromRGB(236,120,120)
	subtitle.Text=string.format("探索先: %s（%s）",tostring(data.MapDisplayName or "?"),tostring(data.MapId or "?"))

	local questLines={}
	if type(data.Quests)=="table" then
		for _,quest in ipairs(data.Quests) do
			table.insert(questLines,string.format("[%s] %s",QUEST_LABELS[quest.State] or tostring(quest.State),tostring(quest.Objective or "?")))
		end
	end
	questBody.Text=(#questLines>0) and table.concat(questLines,"\n") or "Quest情報なし"
	gainedBody.Text=listText(data.Gained,"なし")
	lostBody.Text=listText(data.Lost,"なし")
	footer.Text=string.format("Credits %d → %d（%+d） / インベントリ %d・%d 枠 / Secure %d・%d 枠",
		data.CreditsBefore or 0,data.CreditsAfter or 0,data.CreditsDelta or 0,
		data.InventoryUsed or 0,data.InventoryCapacity or 0,
		data.SecureUsed or 0,data.SecureCapacity or 0)
end)

-- ResetOnSpawn=false なので、リザルト表示中に戦闘不能でリスポーンしても画面は保持される。
print("[RUN RESULT] ready")
