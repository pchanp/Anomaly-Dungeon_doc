local results={}
for _,yaw in ipairs({0,math.pi/2}) do
 local rig=workspace.W05_Shade_R15_Preview:Clone();rig.Name="W05_ShadeQA"
 rig.HumanoidRootPart.Anchored=true;rig:PivotTo(CFrame.new(-1570,20,85)*CFrame.Angles(0,yaw,0));rig.Parent=workspace
 local animation=Instance.new("Animation");animation.AnimationId=game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(game.ReplicatedStorage.AnomalyDungeon.Animations.Shade_R15_v002)
 local track=rig.Humanoid.Animator:LoadAnimation(animation);track.Priority=Enum.AnimationPriority.Action4;track:Play(0,1,0)
 local deadline=os.clock()+3;while track.Length==0 and os.clock()<deadline do task.wait(.03) end;assert(track.Length>0)
 track.TimePosition=0;task.wait(.08)
 local up=rig.HumanoidRootPart.CFrame:VectorToObjectSpace(rig.LowerTorso.CFrame.UpVector)
 local r={yaw=yaw,startUp=up.Y};assert(up.Y>.9,"Sideways initial body")
 track.TimePosition=.5;task.wait(.08)
 up=rig.HumanoidRootPart.CFrame:VectorToObjectSpace(rig.LowerTorso.CFrame.UpVector)
 r.dashForward=-up.Z;assert(r.dashForward>.6,"Reversed dash lean")
 track:Stop(0);track:Destroy();animation:Destroy();rig:Destroy();r.passed=true;table.insert(results,r)
end
return results
