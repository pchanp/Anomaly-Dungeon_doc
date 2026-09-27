local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local shared=ReplicatedStorage:WaitForChild("GiantAnomalyShared")
local Config=require(ReplicatedStorage:WaitForChild("AnomalyDungeon"):WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("GiantConfig"))
local remotes=shared:WaitForChild("Remotes")
local giant=workspace:WaitForChild("Anomalies"):WaitForChild("GiantAnomaly")
-- Visual parts may be streamed out; replicated attributes drive the debug UI.
local staleBlur=Lighting:FindFirstChild("GiantAnomalyBlur");if staleBlur then staleBlur:Destroy() end
local color=Instance.new("ColorCorrectionEffect");color.Name="GiantAnomalyColor";color.Brightness=0;color.Contrast=0;color.Saturation=0;color.TintColor=Color3.new(1,1,1);color.Parent=Lighting
local gui=Instance.new("ScreenGui");gui.Name="GiantAnomalyDebug";gui.ResetOnSpawn=false;gui.Parent=player:WaitForChild("PlayerGui")
local panel=Instance.new("TextLabel");panel.Name="Panel";panel.Position=UDim2.fromOffset(18,155);panel.Size=UDim2.fromOffset(285,155);panel.BackgroundColor3=Color3.fromRGB(10,13,18);panel.BackgroundTransparency=.18;panel.BorderSizePixel=0;panel.TextColor3=Color3.fromRGB(215,245,240);panel.Font=Enum.Font.Code;panel.TextSize=16;panel.TextXAlignment=Enum.TextXAlignment.Left;panel.TextYAlignment=Enum.TextYAlignment.Top;panel.Text="GIANT ANOMALY";panel.Parent=gui
local shakeEnd=0;local shakeMagnitude=0
remotes.GiantStomp.OnClientEvent:Connect(function(position,radius,magnitude)
 local hrp=player.Character and player.Character:FindFirstChild("HumanoidRootPart");if not hrp then return end
 local distance=(hrp.Position-position).Magnitude;if distance>radius then return end
 local scale=1-distance/radius;shakeMagnitude=magnitude*scale;shakeEnd=time()+Config.CameraShakeDuration
 local sound=Instance.new("Sound");sound.SoundId=Config.StompSoundId;sound.Volume=math.clamp(scale*1.5,0,1.5);sound.PlaybackSpeed=.4;sound.Parent=hrp;sound:Play();Debris:AddItem(sound,3)
end)
RunService:BindToRenderStep("GiantAnomalyCameraShake",Enum.RenderPriority.Camera.Value+1,function()
 if time()<shakeEnd and workspace.CurrentCamera then local fade=(shakeEnd-time())/Config.CameraShakeDuration;local m=shakeMagnitude*fade;workspace.CurrentCamera.CFrame*=CFrame.new((math.random()-.5)*m,(math.random()-.5)*m,(math.random()-.5)*m*.35)*CFrame.Angles(0,0,(math.random()-.5)*m*.012) end
end)
UserInputService.InputBegan:Connect(function(input,processed) if not processed and input.KeyCode==Enum.KeyCode.F then remotes.UseGiantHeal:FireServer() end end)
local function update()
 local level=player:GetAttribute("AnomalyLevel") or 0;local normalized=level/Config.MaxAnomalyLevel
 color.Contrast=normalized*.18;color.Saturation=-normalized*.45;color.Brightness=-normalized*.07;color.TintColor=Color3.fromRGB(255,255-math.floor(normalized*55),255-math.floor(normalized*70))
 local distance=giant:GetAttribute("NearestPlayerDistance") or -1
 local activeField=nil;for _,field in ipairs(workspace:FindFirstChild("HealingFields") and workspace.HealingFields:GetChildren() or {}) do if field:GetAttribute("OwnerUserId")==player.UserId then activeField=field break end end
 local remaining=activeField and math.max(0,(activeField:GetAttribute("ExpiresAt") or 0)-workspace:GetServerTimeNow()) or 0
 panel.Text=string.format("GIANT ANOMALY\nState: %s\nDistance: %.1f\nAnomaly: %.0f%%\nCalm: %.0f / %.0f\n\nHEALING FIELD [F]\nActive: %s   Remaining: %.1f",giant:GetAttribute("State") or "?",distance,level,giant:GetAttribute("CalmMeter") or 0,Config.CalmRequired,activeField and "YES" or "NO",remaining)
end
player:GetAttributeChangedSignal("AnomalyLevel"):Connect(update);giant:GetAttributeChangedSignal("State"):Connect(update);giant:GetAttributeChangedSignal("CalmMeter"):Connect(update)
task.spawn(function() while task.wait(.1) do update() end end)
print("[GIANT CLIENT] ready")
