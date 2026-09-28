-- Client Archive Selection: opens on a shelf query and reports the chosen entry.
local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local RS=game:GetService("ReplicatedStorage")
local p=Players.LocalPlayer
local Config=require(RS.AnomalyDungeon.Shared.Config.TsutayaConfig)
local Remotes=RS.AnomalyDungeon.Shared.TsutayaShared:WaitForChild("Remotes")
local OpenArchive=Remotes:WaitForChild("OpenArchive")
local ChooseArchive=Remotes:WaitForChild("ChooseArchive")
local CloseArchive=Remotes:WaitForChild("CloseArchive")

local gui=Instance.new("ScreenGui")
gui.Name="ArchiveSelectionGui"
gui.ResetOnSpawn=false
gui.Enabled=false
gui.Parent=p:WaitForChild("PlayerGui")

local panel=Instance.new("Frame")
panel.Name="Panel"
panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5)
panel.Size=UDim2.fromOffset(Config.UiWidth,0)
panel.BackgroundColor3=Color3.fromRGB(10,13,18)
panel.BackgroundTransparency=.12
panel.BorderSizePixel=0
panel.Parent=gui
local panelCorner=Instance.new("UICorner")
panelCorner.CornerRadius=UDim.new(0,8)
panelCorner.Parent=panel
local panelStroke=Instance.new("UIStroke")
panelStroke.Color=Color3.fromRGB(80,218,202)
panelStroke.Thickness=1
panelStroke.Transparency=.45
panelStroke.Parent=panel

local title=Instance.new("TextLabel")
title.Name="Title"
title.Size=UDim2.new(1,-24,0,30)
title.Position=UDim2.fromOffset(12,8)
title.BackgroundTransparency=1
title.TextColor3=Color3.fromRGB(80,218,202)
title.Font=Enum.Font.GothamBold
title.TextSize=17
title.TextXAlignment=Enum.TextXAlignment.Left
title.Text=Config.UiTitle
title.Parent=panel

local shelfLabel=Instance.new("TextLabel")
shelfLabel.Name="Shelf"
shelfLabel.Size=UDim2.new(1,-24,0,22)
shelfLabel.Position=UDim2.fromOffset(12,38)
shelfLabel.BackgroundTransparency=1
shelfLabel.TextColor3=Color3.fromRGB(190,200,206)
shelfLabel.Font=Enum.Font.Gotham
shelfLabel.TextSize=14
shelfLabel.TextXAlignment=Enum.TextXAlignment.Left
shelfLabel.Text=""
shelfLabel.Parent=panel

local list=Instance.new("ScrollingFrame")
list.Name="List"
list.Size=UDim2.new(1,-24,0,300)
list.Position=UDim2.fromOffset(12,64)
list.BackgroundTransparency=1
list.BorderSizePixel=0
list.ScrollBarThickness=4
list.CanvasSize=UDim2.new(0,0)
list.AutomaticCanvasSize=Enum.AutomaticSize.Y
list.Parent=panel

local layout=Instance.new("UIListLayout")
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Padding=UDim.new(0,4)
layout.Parent=list

local hint=Instance.new("TextLabel")
hint.Name="Hint"
hint.Size=UDim2.new(1,-24,0,26)
hint.Position=UDim2.new(0,12,1,-38)
hint.BackgroundTransparency=1
hint.TextColor3=Color3.fromRGB(140,150,158)
hint.Font=Enum.Font.Gotham
hint.TextSize=13
hint.TextXAlignment=Enum.TextXAlignment.Left
hint.Text=Config.UiBackText.."（背面 / B）"
hint.Parent=panel

local current
local function close()
	current=nil
	gui.Enabled=false
	CloseArchive:FireServer()
end

local function select(label)
	if not current then return end
	ChooseArchive:FireServer(current.Shelf,label)
	close()
end

local function render(shelf,entries)
	for _,child in ipairs(list:GetChildren()) do
		if child:IsA("GuiButton") then child:Destroy() end
	end
	shelfLabel.Text=shelf
	if #entries==0 then
		local empty=Instance.new("TextLabel")
		empty.Name="Empty"
		empty.Size=UDim2.new(1,0,0,40)
		empty.BackgroundTransparency=1
		empty.TextColor3=Color3.fromRGB(140,150,158)
		empty.Font=Enum.Font.Gotham
		empty.TextSize=14
		empty.TextXAlignment=Enum.TextXAlignment.Left
		empty.Text=Config.UiNoEntriesText
		empty.Parent=list
		return
	end
	for index,entry in ipairs(entries) do
		local row=Instance.new("TextButton")
		row.Name="Entry_"..index
		row.Size=UDim2.new(1,-4,0,Config.UiRowHeight-4)
		row.BackgroundColor3=Color3.fromRGB(24,30,38)
		row.BackgroundTransparency=.2
		row.BorderSizePixel=0
		row.TextColor3=Color3.fromRGB(219,233,239)
		row.Font=Enum.Font.Gotham
		row.TextSize=15
		row.TextXAlignment=Enum.TextXAlignment.Left
		row.Text=entry.Label
		row.LayoutOrder=index
		row.Parent=list
		local rowCorner=Instance.new("UICorner")
		rowCorner.CornerRadius=UDim.new(0,5)
		rowCorner.Parent=row
		local captured=entry.Label
		row.Activated:Connect(function() select(captured) end)
	end
end

OpenArchive.OnClientEvent:Connect(function(payload)
	current=payload
	gui.Enabled=true
	render(payload.Shelf,payload.Entries)
end)

UserInputService.InputBegan:Connect(function(input,processed)
	if not gui.Enabled then return end
	if processed then return end
	if input.KeyCode==Enum.KeyCode.B or input.KeyCode==Enum.KeyCode.ButtonB then close() end
end)

print("[ARCHIVE UI] ready")
