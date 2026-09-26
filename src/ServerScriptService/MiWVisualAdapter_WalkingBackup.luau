local RunService=game:GetService("RunService")
local ServerStorage=game:GetService("ServerStorage")
local KeyframeSequenceProvider=game:GetService("KeyframeSequenceProvider")
local assets=ServerStorage:WaitForChild("AnomalyAssets",10)
if not assets then warn("[MIW VISUAL] AnomalyAssets missing") return end
local template=assets:WaitForChild("MiWWalkingRig",10)
local keyframes=assets:WaitForChild("MiWWalk",10)
if not template or not keyframes then warn("[MIW VISUAL] rig or animation missing") return end
local function animationId()
 local configured=assets:GetAttribute("WalkAnimationId")
 if typeof(configured)=="string" and configured~="" then
  if string.match(configured,"^rbxassetid://") then return configured end
  return "rbxassetid://"..configured
 end
 if RunService:IsStudio() then
  local ok,id=pcall(function() return KeyframeSequenceProvider:RegisterKeyframeSequence(keyframes) end)
  if ok then return id end
  warn("[MIW VISUAL] Studio animation registration failed: "..tostring(id))
 end
 return nil
end
local function attach(miw)
 if assets:GetAttribute("UseImportedMiW")~=true or miw:FindFirstChild("MiWAnimatedVisual") then return end
 local id=animationId()
 if not id and not RunService:IsStudio() then warn("[MIW VISUAL] WalkAnimationId is empty; procedural fallback retained") return end
 local rig=template:Clone()
 rig.Name="MiWAnimatedVisual"
 rig.Parent=miw
 rig:PivotTo(miw:GetPivot())
 local controller=rig:FindFirstChildOfClass("AnimationController") or Instance.new("AnimationController",rig)
 local animator=controller:FindFirstChildOfClass("Animator") or Instance.new("Animator",controller)
 if id then
  local animation=Instance.new("Animation") animation.Name="Walk" animation.AnimationId=id animation.Parent=rig
  local ok,track=pcall(function() return animator:LoadAnimation(animation) end)
  if not ok then rig:Destroy() warn("[MIW VISUAL] load failed; procedural fallback retained: "..tostring(track)) return end
  track.Looped=true track.Priority=Enum.AnimationPriority.Movement track:Play(0.15)
 end
 for _,child in ipairs(miw:GetChildren()) do if child:IsA("BasePart") then child.Transparency=1 end end
 miw:SetAttribute("ImportedVisualActive",true)
 print("[MIW VISUAL] imported rig attached")
end
local function consider(obj)
 if obj:IsA("Model") and obj.Name=="MiW" and obj.Parent and obj.Parent.Name=="AnomalyPrototype" then task.defer(attach,obj) end
end
workspace.DescendantAdded:Connect(consider)
for _,obj in ipairs(workspace:GetDescendants()) do consider(obj) end