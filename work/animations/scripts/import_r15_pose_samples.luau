-- Studio Command Bar/plugin helper. Invoke with JSONDecoded pose samples.
-- Keep raw FBX import as evidence. This produces standard R15 part-space poses.
return function(data, parent, name, rig)
 assert(data.version == 2 and #data.frames > 1, "Re-export with anatomical v2; legacy poses may face backwards")
 local orientation = data.orientation
 assert(orientation and orientation.profile == "r15-anatomical-v2", "Missing verified orientation profile")
 local function vector(values) return Vector3.new(table.unpack(values)) end
 assert((vector(orientation.forward)-Vector3.new(0,0,-1)).Magnitude<.00001,"Forward must be Roblox -Z")
 assert((vector(orientation.right)-Vector3.new(1,0,0)).Magnitude<.00001,"Right must be Roblox +X")
 assert((vector(orientation.up)-Vector3.new(0,1,0)).Magnitude<.00001,"Up must be Roblox +Y")
 assert(not parent:FindFirstChild(name), "Choose a new output version")
 if rig then
  for _,joint in ipairs(rig:GetDescendants()) do
   local a,b
   if joint:IsA("Motor6D") then a,b=joint.C0,joint.C1
   elseif joint:IsA("AnimationConstraint") then a,b=joint.Attachment0.CFrame,joint.Attachment1.CFrame end
   if a then
    local _,aa=a:ToAxisAngle(); local _,ba=b:ToAxisAngle()
    assert(math.abs(aa)<.0001 and math.abs(ba)<.0001,"Nonstandard attachment rotation")
   end
  end
 end
 local sequence = Instance.new("KeyframeSequence")
 sequence.Name = name; sequence.Loop = false; sequence.Priority = Enum.AnimationPriority.Action
 sequence:SetAttribute("ImportAdapter","rest-corrected-part-space-v2")
 sequence:SetAttribute("OrientationProfile", orientation.profile)
 local previous = -1
 for index,frame in ipairs(data.frames) do
  assert(frame.time > previous, "Non-increasing sample times"); previous=frame.time
  local key = Instance.new("Keyframe"); key.Time = frame.time
  local poses = {}
  local root = Instance.new("Pose"); root.Name="HumanoidRootPart"; root.Parent=key
  poses.HumanoidRootPart=root
  local count = 0
  for bone,values in pairs(frame.poses) do
   assert(#values == 12, "Invalid CFrame")
   for _,value in ipairs(values) do assert(type(value)=="number" and value==value and math.abs(value)<math.huge,"Non-finite CFrame") end
   local pose=Instance.new("Pose"); pose.Name=bone; pose.CFrame=CFrame.new(table.unpack(values)); pose.EasingStyle=Enum.PoseEasingStyle.Linear
   poses[bone]=pose; count+=1
  end
  assert(count==15,"Expected 15 R15 body poses")
  for bone in pairs(frame.poses) do
   assert(poses[data.parents[bone]],"Missing parent pose")
   poses[bone].Parent=poses[data.parents[bone]]
  end
  key.Parent=sequence
  if index%13==0 then task.wait() end
 end
 sequence.Parent=parent
 return sequence
end
