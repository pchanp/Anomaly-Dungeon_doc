local ServerStorage=game:GetService("ServerStorage")
local assets=ServerStorage:WaitForChild("AnomalyAssets",10)
if not assets then warn("[MIW VISUAL] AnomalyAssets missing") return end
local template=assets:WaitForChild("MiWSittingRig",10)
if not template then warn("[MIW VISUAL] sitting rig missing; procedural fallback retained") return end
local function attach(miw)
 if assets:GetAttribute("UseSittingMiW")~=true or miw:FindFirstChild("MiWSittingVisual") then return end
 local miwCF,miwSize=miw:GetBoundingBox()
 local rig=template:Clone()
 rig.Name="MiWSittingVisual"
 local _,rigSize=rig:GetBoundingBox()
 rig.Parent=miw
 local floorY=miwCF.Position.Y-miwSize.Y/2
 local targetPos=Vector3.new(miwCF.Position.X,floorY+rigSize.Y/2,miwCF.Position.Z)
 local yaw=math.rad(tonumber(assets:GetAttribute("SittingYawDegrees")) or 180)
 rig:PivotTo(CFrame.new(targetPos)*miwCF.Rotation*CFrame.Angles(0,yaw,0))
 for _,child in ipairs(miw:GetChildren()) do if child:IsA("BasePart") then child.Transparency=1 end end
 miw:SetAttribute("ImportedVisualActive",true)
 miw:SetAttribute("MiWVisualPose","Sitting")
 print("[MIW VISUAL] sitting rig attached")
end
local function consider(obj)
 if obj:IsA("Model") and obj.Name=="MiW" and obj.Parent and obj.Parent.Name=="AnomalyPrototype" then task.defer(attach,obj) end
end
workspace.DescendantAdded:Connect(consider)
for _,obj in ipairs(workspace:GetDescendants()) do consider(obj) end
