-- DebugMapSwitch: swaps the generated dungeon between registered map IDs.
-- Stands in for the Transition Portal until Party State is specified.
-- This is a debug path only: it never takes part in the party run draw, and it refuses to run
-- while a run is active so the generated world is not pulled out from under an exploring party.
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local RunService=require(script.Parent.Parent.Services.RunService)
local MapDefinitions=require(game:GetService("ReplicatedStorage").AnomalyDungeon.Shared.Definitions.MapDefinitions)

local ORIGIN=Vector3.new(1200,1000,0)
local SPACING=34

local function build()
 local floor=Workspace:WaitForChild("DebugFloor",20)
 if not floor then return end
 local deck=floor:FindFirstChild("Floor")
 if not deck then return end
 if deck:FindFirstChild("MapSwitchDeck") then return end

 local ids={}
 for id in pairs(MapDefinitions) do table.insert(ids,id) end
 table.sort(ids)

 local holder=Instance.new("Folder")
 holder.Name="MapSwitchDeck"
 holder.Parent=deck

 for index,id in ipairs(ids) do
  local def=MapDefinitions[id]
  local base=deck.Position+Vector3.new((index-((#ids+1)/2))*SPACING,2,64)
  local pad=Instance.new("Part")
  pad.Name="MapSwitch_"..id
  pad.Size=Vector3.new(14,1.5,14)
  pad.CFrame=CFrame.new(base)
  pad.Anchored=true
  pad.Material=Enum.Material.Metal
  pad.Color=Color3.fromRGB(80,218,202)
  pad.Parent=holder

  local gui=Instance.new("BillboardGui")
  gui.Name="Sign"
  gui.Size=UDim2.fromOffset(280,64)
  gui.StudsOffset=Vector3.new(0,5,0)
  gui.MaxDistance=70
  gui.AlwaysOnTop=true
  gui.Parent=pad
  local label=Instance.new("TextLabel")
  label.Size=UDim2.fromScale(1,1)
  label.BackgroundColor3=Color3.fromRGB(10,13,18)
  label.BackgroundTransparency=.2
  label.TextColor3=Color3.fromRGB(219,233,239)
  label.Font=Enum.Font.GothamBold
  label.TextSize=15
  label.TextWrapped=true
  label.Text=def.DisplayName.."\n"..id
  label.Parent=gui

  local prompt=Instance.new("ProximityPrompt")
  prompt.ActionText="マップを読み込む"
  prompt.ObjectText=def.DisplayName
  prompt.HoldDuration=.35
  prompt.MaxActivationDistance=12
  prompt.RequiresLineOfSight=false
  prompt.Parent=pad
  prompt.Triggered:Connect(function(player)
   if not player.Character then return end
   if RunService.GetRunState()~="IDLE" then
    RunService.Tell(player,"Run進行中です。マップ切替はRun終了後に利用できます。")
    return
   end
   RunService.Build(Random.new():NextInteger(1000,99999),id)
   if player.Character then player.Character:PivotTo(CFrame.new(base+Vector3.new(0,4,10))) end
   print("[MAP SWITCH] "..id.." loaded by "..player.Name)
  end)
 end
end

if Workspace:FindFirstChild("DebugFloor") then task.defer(build) end
Workspace.ChildAdded:Connect(function(child) if child.Name=="DebugFloor" then task.defer(build) end end)
