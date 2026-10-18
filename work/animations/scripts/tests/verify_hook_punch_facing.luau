-- Play-mode integration regression for this Hook Punch fixture's initial guard.
-- Both fists are in front of their shoulders in the source animation at t=0.
-- Other motions need their own semantic probes; this is not a universal pose rule.
return function(template, sequence, yaw)
 local rig = template:Clone()
 rig.Name = "W05_FacingRegressionProbe"
 for _,object in ipairs(rig:GetDescendants()) do if object:IsA("BaseScript") then object:Destroy() end end
 rig.HumanoidRootPart.Anchored = true
 rig:PivotTo(CFrame.new(-1600,20,80)*CFrame.Angles(0,yaw or 0,0))
 rig.Parent = workspace
 local animation, track
 local ok,result = pcall(function()
  local animator=rig.Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator",rig.Humanoid)
  animation=Instance.new("Animation")
  animation.AnimationId=game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(sequence)
  track=animator:LoadAnimation(animation)
  track.Priority=Enum.AnimationPriority.Action4
  track:Play(0,1,0)
  local deadline=os.clock()+5
  while track.Length==0 and os.clock()<deadline do task.wait(.03) end
  assert(track.Length>0,"Clip did not load")
  track.TimePosition=0
  task.wait(.1)
  local forward=rig.HumanoidRootPart.CFrame.LookVector
  local left=forward:Dot(rig.LeftHand.Position-rig.LeftUpperArm.Position)
  local right=forward:Dot(rig.RightHand.Position-rig.RightUpperArm.Position)
  return {leftForward=left,rightForward=right,passed=left>.02 and right>.02,yaw=yaw or 0}
 end)
 if track then track:Stop(0);track:Destroy() end
 if animation then animation:Destroy() end
 rig:Destroy()
 assert(ok,result)
 return result
end
