-- DebugInventoryTerminal: テスト用の安全なデバッグ付与経路。
-- 正式なアイテム取得源は未実装なので、ここ以外からアイテムを作らない。付与されるのはデバッグアイテム
-- だけなので、Secure Slotの保持/喪失とリザルト分類を検証できる。
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Inventory=require(script.Parent.Parent.Services.InventoryService)
local notice=ReplicatedStorage:WaitForChild("AnomalyNotice")

local function tell(player,text) notice:FireClient(player,text) end

local function build(lobby)
	if lobby:FindFirstChild("DebugInventory") then return end
	local pad=Instance.new("Part")
	pad.Name="DebugInventory"
	pad.Size=Vector3.new(6,4,4)
	pad.CFrame=lobby.CityLobbySpawn.CFrame+Vector3.new(14,0,6)
	pad.Anchored=true
	pad.Material=Enum.Material.Metal
	pad.Color=Color3.fromRGB(190,80,255)
	pad.Parent=lobby
	local gui=Instance.new("BillboardGui")
	gui.Size=UDim2.fromOffset(300,72)
	gui.StudsOffset=Vector3.new(0,4,0)
	gui.AlwaysOnTop=true
	gui.Parent=pad
	local label=Instance.new("TextLabel")
	label.Size=UDim2.fromScale(1,1)
	label.BackgroundColor3=Color3.fromRGB(10,15,22)
	label.BackgroundTransparency=.2
	label.TextColor3=Color3.fromRGB(214,180,255)
	label.Font=Enum.Font.GothamBold
	label.TextSize=15
	label.TextWrapped=true
	label.Text="DEBUG ITEM GRANT\n通常枠1個 + Secure Slot 1個"
	label.Parent=gui
	local prompt=Instance.new("ProximityPrompt")
	prompt.ActionText="付与する"
	prompt.ObjectText="DEBUG アイテム付与"
	prompt.HoldDuration=.35
	prompt.MaxActivationDistance=12
	prompt.RequiresLineOfSight=false
	prompt.Parent=pad
	prompt.Triggered:Connect(function(player)
		local normal,secure=Inventory.DebugGrant(player)
		if normal and secure then
			tell(player,string.format("デバッグアイテムを追加しました / 所持 %d・%d 枠 / Secure %d・%d 枠",
				player:GetAttribute("InventoryUsed") or 0,player:GetAttribute("InventoryCapacity") or 0,
				player:GetAttribute("SecureUsed") or 0,player:GetAttribute("SecureSlotCapacity") or 0))
		else
			tell(player,"枠が満杯のため付与できませんでした。")
		end
	end)
	print("[DEBUG] inventory terminal ready")
end

local function tryBuild()
	local lobby=Workspace:FindFirstChild("CityLobby")
	local spawn=lobby and lobby:FindFirstChild("CityLobbySpawn")
	if lobby and spawn then build(lobby) end
end

task.defer(tryBuild)
Workspace.ChildAdded:Connect(function(child) if child.Name=="CityLobby" then task.defer(tryBuild) end end)
