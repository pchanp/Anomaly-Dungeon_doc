local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local CAS=game:GetService("ContextActionService")
local player=Players.LocalPlayer
local remotes=RS:WaitForChild("AnomalyPrototype"):WaitForChild("Remotes")
local show=remotes:WaitForChild("ShowMiWHUD")
local feedback=remotes:WaitForChild("DevNullFeedback")
local gui=Instance.new("ScreenGui")
gui.Name="AnomalyPrototypeHUD"
gui.ResetOnSpawn=false
gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("TextLabel")
panel.Name="MiWObservation"
panel.Size=UDim2.fromOffset(430,250)
panel.Position=UDim2.new(.5,-215,.12,0)
panel.BackgroundColor3=Color3.fromRGB(5,12,16)
panel.BackgroundTransparency=.08
panel.TextColor3=Color3.fromRGB(145,255,205)
panel.Font=Enum.Font.Code
panel.TextSize=20
panel.TextXAlignment=Enum.TextXAlignment.Left
panel.TextYAlignment=Enum.TextYAlignment.Top
panel.TextWrapped=true
panel.Visible=false
panel.Parent=gui
local notice=Instance.new("TextLabel")
notice.Size=UDim2.fromOffset(440,90)
notice.Position=UDim2.new(.5,-220,.72,0)
notice.BackgroundColor3=Color3.fromRGB(15,0,22)
notice.TextColor3=Color3.fromRGB(225,150,255)
notice.Font=Enum.Font.GothamBold
notice.TextSize=22
notice.TextWrapped=true
notice.Visible=false
notice.Parent=gui
local token=0
show.OnClientEvent:Connect(function(data)
 token=token+1
 local mine=token
 local flags=data.flags or {}
 local nl=string.char(10)
 panel.Text=table.concat({"[ MiW OBSERVATION ]","PLAYERS "..tostring(data.players),"ALIVE "..tostring(data.alive),"RUN TIME "..tostring(data.elapsed).."s","EVENTS "..tostring(data.events),"DEPTH/STAGE "..tostring(data.depth),"MIW_ALIVE "..tostring(flags.MiWAlive),"DEV_NULL "..tostring(flags.DevNullActive),"POISON_GAS "..tostring(flags.PoisonGas)},nl)
 panel.Visible=true
 task.delay(tonumber(data.duration) or 10,function()
  if token==mine then panel.Visible=false end
 end)
end)
feedback.OnClientEvent:Connect(function(kind,seconds)
 notice.Text="/dev/null"..string.char(10)..tostring(kind).." nullified for "..tostring(seconds).."s"
 notice.Visible=true
 task.delay(2.5,function() notice.Visible=false end)
end)
local function gate(_,state,input)
 if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
 local now=workspace:GetServerTimeNow()
 if (player:GetAttribute("ActionRestrictedUntil") or 0)>now then return Enum.ContextActionResult.Sink end
 if not player:GetAttribute("NearDevNull") then return Enum.ContextActionResult.Pass end
 local key=input.KeyCode
 local skill=key==Enum.KeyCode.One or key==Enum.KeyCode.Two or key==Enum.KeyCode.Three or key==Enum.KeyCode.Four or key==Enum.KeyCode.Q or key==Enum.KeyCode.E
 feedback:FireServer(skill and "Skill" or "Attack")
 return Enum.ContextActionResult.Sink
end
CAS:BindActionAtPriority("AnomalyPrototypeGate",gate,false,5000,Enum.UserInputType.MouseButton1,Enum.KeyCode.ButtonR2,Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Q,Enum.KeyCode.E)
