-- Client-owned character physics; started only after the server accepts slot 2.
local RunService = game:GetService("RunService")
local Config = require(game.ReplicatedStorage.AnomalyDungeon.Shared.Config.RollConfig)
local M = {}
local cancel
function M.Start(player)
 if cancel then cancel() end
 local char = player.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root or not hum or hum.Health <= 0 then return end
 local dir = hum.MoveDirection
 if dir.Magnitude < .1 then dir = root.CFrame.LookVector end
 dir = Vector3.new(dir.X,0,dir.Z)
 if dir.Magnitude < .01 then return end
 dir = dir.Unit
 local start = root.Position
 local attachment = Instance.new("Attachment"); attachment.Name = "RollMovementAttachment"; attachment.Parent = root
 local velocity = Instance.new("LinearVelocity")
 velocity.Name = "RollMovementVelocity"; velocity.Attachment0 = attachment
 velocity.RelativeTo = Enum.ActuatorRelativeTo.World
 velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
 velocity.PrimaryTangentAxis = Vector3.xAxis; velocity.SecondaryTangentAxis = Vector3.zAxis
 velocity.ForceLimitsEnabled = false
 local speed = Config.Distance / Config.Duration
 velocity.PlaneVelocity = Vector2.new(dir.X,dir.Z) * speed
 velocity.Parent = root
 root.AssemblyLinearVelocity = dir * speed + Vector3.new(0,Config.InitialVerticalSpeed,0)
 local params = RaycastParams.new()
 params.FilterType = Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances = {char}
 params.RespectCanCollide = true; params.CollisionGroup = root.CollisionGroup
 local elapsed, connection, finished = 0, nil, false
 local function finish()
  if finished then return end
  finished = true
  if connection then connection:Disconnect() end
  velocity:Destroy(); attachment:Destroy()
  if root.Parent then
   local v = root.AssemblyLinearVelocity
   root.AssemblyLinearVelocity = Vector3.new(0,v.Y,0)
  end
  cancel = nil
 end
 cancel = finish
 connection = RunService.PreSimulation:Connect(function(dt)
  if player.Character ~= char or not root.Parent or hum.Health <= 0
   or player:GetAttribute("RunResultPending") == true
   or (char:GetAttribute("CombatStunnedUntil") or 0) > workspace:GetServerTimeNow() then finish(); return end
  local remaining = Config.Distance - (root.Position-start):Dot(dir)
  if elapsed >= Config.Duration or remaining <= .01 then finish(); return end
  local stepSpeed = math.min(speed, remaining/math.max(dt,.0001))
  if workspace:Blockcast(root.CFrame,root.Size,dir*(stepSpeed*dt+Config.WallClearance),params) then finish(); return end
  velocity.PlaneVelocity = Vector2.new(dir.X,dir.Z) * stepSpeed
  elapsed += dt
 end)
end
return M
