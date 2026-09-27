local ServerStorage=game:GetService("ServerStorage")
local RunService=game:GetService("RunService")
local template=ServerStorage:WaitForChild("GiantAnomalyAssets"):WaitForChild("GiantVisual")
local function attach(giant)
 local visual=giant:WaitForChild("Model",15) local root=visual and visual:WaitForChild("Root",15) if not root then warn("[GIANT VISUAL] root missing") return end
 local prior=visual:FindFirstChild("ImportedGiant") if prior then prior:Destroy() end
 local imported=template:Clone() imported.Name="ImportedGiant" local mesh=imported:FindFirstChildWhichIsA("MeshPart",true) if not mesh then warn("[GIANT VISUAL] mesh missing") return end
 for _,d in ipairs(imported:GetDescendants()) do if d:IsA("BasePart") then d.Anchored=true d.CanCollide=false d.CanTouch=false d.CanQuery=false d.Massless=true d.Color=Color3.new(1,1,1) d.Transparency=0 end end
 imported.Parent=visual root.Transparency=1 root.CanCollide=false
 local connection connection=RunService.Heartbeat:Connect(function() if not giant.Parent or not imported.Parent then connection:Disconnect() return end mesh.CFrame=root.CFrame*CFrame.new(0,mesh.Size.Y/2,0) end)
 giant:SetAttribute("ImportedVisualActive",true) giant:SetAttribute("ImportedVisualHeight",mesh.Size.Y) giant:SetAttribute("WalkAnimationActive",true) giant:SetAttribute("WalkAnimationMode","ClientKeyframeSequence24FPS")
 print("[GIANT VISUAL] textured skinned model attached",math.round(mesh.Size.Y*100)/100)
end
local anomalies=workspace:WaitForChild("Anomalies",20) if not anomalies then return end local existing=anomalies:FindFirstChild("GiantAnomaly") if existing then task.spawn(attach,existing) end anomalies.ChildAdded:Connect(function(child) if child.Name=="GiantAnomaly" then task.spawn(attach,child) end end)