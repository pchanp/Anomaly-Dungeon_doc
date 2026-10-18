-- Play-mode regression for these two movement fixtures; not a universal pose rule.
local results={}
local template=workspace.W05_HookPunch_R15_Preview
for _,spec in ipairs({{"SprintingForwardRoll_R15_v001",.2,.6},{"StandardRun_R15_v001",.2,.2}}) do
 for _,yaw in ipairs({0,math.pi/2}) do
  local rig=template:Clone();rig.Name="W05_MovementFacingProbe"
  for _,s in ipairs(rig:GetDescendants()) do if s:IsA("BaseScript") then s:Destroy() end end
  rig.HumanoidRootPart.Anchored=true
  rig:PivotTo(CFrame.new(-1800,20,90)*CFrame.Angles(0,yaw,0));rig.Parent=workspace
  local anim=Instance.new("Animation")
  anim.AnimationId=game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(game.ReplicatedStorage.AnomalyDungeon.Animations[spec[1]])
  local animator=rig.Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator",rig.Humanoid)
  local track=animator:LoadAnimation(anim);track.Priority=Enum.AnimationPriority.Action4;track:Play(0,1,0)
  local deadline=os.clock()+3
  while track.Length==0 and os.clock()<deadline do task.wait(.03) end
  assert(track.Length>0)
  track.TimePosition=spec[2];task.wait(.08)
  local up=rig.HumanoidRootPart.CFrame:VectorToObjectSpace(rig.LowerTorso.CFrame.UpVector)
  local result={clip=spec[1],yaw=yaw,firstForward=-up.Z,firstUp=up.Y}
  assert(-up.Z>spec[3],"Forward lean reversed")
  if string.find(spec[1],"Roll") then
   track.TimePosition=13/30;task.wait(.08)
   result.midUp=rig.HumanoidRootPart.CFrame:VectorToObjectSpace(rig.LowerTorso.CFrame.UpVector).Y
   assert(result.midUp<-.4,"No forward roll inversion")
  end
  track:Stop(0);track:Destroy();anim:Destroy();rig:Destroy()
  result.passed=true;table.insert(results,result)
 end
end
return results
