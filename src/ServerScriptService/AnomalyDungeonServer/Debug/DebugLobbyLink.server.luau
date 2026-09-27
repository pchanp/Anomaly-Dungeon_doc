local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local function promptPart(parent,name,cf,color,text,destination)
 local old=parent:FindFirstChild(name)
 if old then return end
 local p=Instance.new("Part")
 p.Name=name p.Size=Vector3.new(8,1,8) p.Anchored=true p.Material=Enum.Material.Neon p.Color=color p.CFrame=cf p.Parent=parent
 local gui=Instance.new("BillboardGui") gui.Size=UDim2.fromOffset(260,65) gui.StudsOffset=Vector3.new(0,4,0) gui.AlwaysOnTop=true gui.Parent=p
 local label=Instance.new("TextLabel") label.Size=UDim2.fromScale(1,1) label.BackgroundTransparency=.25 label.BackgroundColor3=Color3.fromRGB(10,15,22) label.TextColor3=Color3.new(1,1,1) label.TextScaled=true label.Font=Enum.Font.GothamBold label.Text=text label.Parent=gui
 local prompt=Instance.new("ProximityPrompt") prompt.ActionText="移動" prompt.ObjectText=text prompt.HoldDuration=.35 prompt.MaxActivationDistance=12 prompt.RequiresLineOfSight=false prompt.Parent=p
 prompt.Triggered:Connect(function(player) local char=player.Character local target=destination() if char and target then char:PivotTo(target) end end)
end
local function lobbyCF(debugFloor)
 for _,d in ipairs(Workspace:GetDescendants()) do if d:IsA("SpawnLocation") and not d:IsDescendantOf(debugFloor) then return d.CFrame+Vector3.new(0,4,0) end end
 local lobby=Workspace:FindFirstChild("Lobby",true) or Workspace:FindFirstChild("AnomalyDungeon")
 if lobby and lobby:IsA("Model") then return lobby:GetPivot()+Vector3.new(0,6,0) end
 return CFrame.new(0,10,0)
end
local function build(debugFloor)
 if not debugFloor:IsA("Model") then return end
 local floor=debugFloor:FindFirstChild("Floor")
 local floorCF=floor and floor.CFrame or debugFloor:GetPivot()
 local floorTop=floor and (floor.Position.Y+floor.Size.Y/2) or floorCF.Position.Y
 local debugCF=CFrame.new(floorCF.Position.X,floorTop+4,floorCF.Position.Z+30)
 local returnCF=CFrame.new(floorCF.Position.X,floorTop+.5,floorCF.Position.Z-18)
 promptPart(debugFloor,"ReturnToLobby",returnCF,Color3.fromRGB(70,200,255),"LOBBYへ戻る",function() return lobbyCF(debugFloor) end)
 local lobbyParent=Workspace:FindFirstChild("AnomalyDungeon") or Workspace
 local entryCF=lobbyCF(debugFloor)*CFrame.new(10,-3,0)
 promptPart(lobbyParent,"DebugFloorEntrance",entryCF,Color3.fromRGB(190,80,255),"DEBUG FLOOR",function() return debugCF end)
end
local current=Workspace:FindFirstChild("DebugFloor") or Workspace:FindFirstChild("Debug_Floor")
if current then task.defer(build,current) end
Workspace.ChildAdded:Connect(function(child) if child.Name=="DebugFloor" or child.Name=="Debug_Floor" then task.wait(.5) build(child) end end)