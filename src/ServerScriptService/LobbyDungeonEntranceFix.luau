local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local Manager=require(script.Parent.AnomalyPrototype.DungeonManager)
local debounce={}
local function bind(root)
 local rooms=root:WaitForChild("Rooms",10)
 local lobby=rooms and rooms:WaitForChild("LOBBY",10)
 local gimmicks=lobby and lobby:WaitForChild("GimmickPoints",10)
 local enter=gimmicks and gimmicks:WaitForChild("Enter",10)
 if not enter or enter:GetAttribute("TouchEntryBound") then return end
 enter:SetAttribute("TouchEntryBound",true)
 enter.Touched:Connect(function(hit)
  local character=hit:FindFirstAncestorOfClass("Model")
  local player=character and Players:GetPlayerFromCharacter(character)
  if not player or debounce[player] then return end
  debounce[player]=true
  Manager.Enter(player)
  task.delay(1,function() debounce[player]=nil end)
 end)
 print("[LOBBY LINK] entrance prompt + touch fallback ready")
end
local current=Workspace:FindFirstChild("AnomalyDungeon")
if current then task.defer(bind,current) end
Workspace.ChildAdded:Connect(function(child) if child.Name=="AnomalyDungeon" then task.defer(bind,child) end end)
Players.PlayerRemoving:Connect(function(player) debounce[player]=nil end)