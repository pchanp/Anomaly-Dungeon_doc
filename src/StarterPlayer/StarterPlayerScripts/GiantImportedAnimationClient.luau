local ReplicatedStorage=game:GetService("ReplicatedStorage")
local RunService=game:GetService("RunService")
local clip=ReplicatedStorage:WaitForChild("GiantAnomalyAssets"):WaitForChild("GiantAnomaly_StompWalk")
local FPS,DURATION=24,2
local function animate(giant)
 local model=giant:WaitForChild("Model",15) local imported=model and model:WaitForChild("ImportedGiant",15) if not imported then return end while imported.Parent and not imported:FindFirstChildWhichIsA("MeshPart",true) do imported.DescendantAdded:Wait() end if not imported.Parent then return end
 local bones={} for _,d in ipairs(imported:GetDescendants()) do if d:IsA("Bone") then bones[d.Name]=d end end
 local keyframes=clip:GetKeyframes() table.sort(keyframes,function(a,b)return a.Time<b.Time end) local samples={}
 for i,kf in ipairs(keyframes) do local sample={time=kf.Time,poses={}} for _,pose in ipairs(kf:GetDescendants()) do if pose:IsA("Pose") and bones[pose.Name] then sample.poses[pose.Name]=pose.CFrame end end samples[i]=sample end
 local started=workspace:GetServerTimeNow() local connection connection=RunService.RenderStepped:Connect(function() if not giant.Parent or not imported.Parent then connection:Disconnect() return end local t=(workspace:GetServerTimeNow()-started)%DURATION local index=math.clamp(math.floor(t*FPS)+1,1,#samples-1) local a,b=samples[index],samples[index+1] local alpha=math.clamp((t-a.time)/math.max(b.time-a.time,1/FPS),0,1) for name,cf in pairs(a.poses) do local bone=bones[name] if bone then bone.Transform=cf:Lerp(b.poses[name] or cf,alpha) end end giant:SetAttribute("WalkAnimationTime",t) end)
 print("[GIANT ANIMATION CLIENT] playing",#samples,"bones",(function() local n=0 for _ in pairs(bones) do n+=1 end return n end)())
end
local anomalies=workspace:WaitForChild("Anomalies",20) if not anomalies then return end local existing=anomalies:FindFirstChild("GiantAnomaly") if existing then task.spawn(animate,existing) end anomalies.ChildAdded:Connect(function(child) if child.Name=="GiantAnomaly" then task.spawn(animate,child) end end)