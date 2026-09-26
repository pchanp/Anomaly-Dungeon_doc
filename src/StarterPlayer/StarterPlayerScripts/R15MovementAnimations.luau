local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local assets = ReplicatedStorage:WaitForChild("MovementAnimations")
local SPRINT_SPEED = 24
local character, humanoid, animator, baseSpeed
local tracks, connections = {}, {}
local shiftHeld, rollToken = false, 0

local function attrTrue(name)
    return (character and character:GetAttribute(name) == true)
        or (humanoid and humanoid:GetAttribute(name) == true)
        or player:GetAttribute(name) == true
end
local function rolling() return attrTrue("IsInvincible") or attrTrue("IsRolling") or attrTrue("Rolling") end
local function sneaking() return attrTrue("IsStealth") or attrTrue("IsSneaking") or attrTrue("Sneaking") end
local function stopTrack(name, fade)
    local t = tracks[name]; if t and t.IsPlaying then t:Stop(fade or 0.15) end
end
local function setSprintSpeed()
    if not humanoid then return end
    if shiftHeld and not rolling() and not sneaking() then
        humanoid.WalkSpeed = math.max(baseSpeed or 16, SPRINT_SPEED)
    elseif not sneaking() and not rolling() and humanoid.WalkSpeed >= SPRINT_SPEED then
        humanoid.WalkSpeed = baseSpeed or 16
    end
end
local function playRollTuck()
    rollToken += 1
    local token = rollToken
    local motors = {}
    local function motor(part, name)
        local p = character and character:FindFirstChild(part)
        return p and p:FindFirstChild(name)
    end
    motors.Waist = motor("LowerTorso", "Waist")
    motors.LeftShoulder = motor("UpperTorso", "LeftShoulder")
    motors.RightShoulder = motor("UpperTorso", "RightShoulder")
    motors.LeftHip = motor("LowerTorso", "LeftHip")
    motors.RightHip = motor("LowerTorso", "RightHip")
    local started = os.clock()
    while character and humanoid and humanoid.Health > 0 and token == rollToken and os.clock() - started < 0.62 do
        local p = math.clamp((os.clock() - started) / 0.62, 0, 1)
        local weight = math.sin(p * math.pi)
        if motors.Waist then motors.Waist.Transform = CFrame.Angles(math.rad(-42 * weight), 0, 0) end
        if motors.LeftShoulder then motors.LeftShoulder.Transform = CFrame.Angles(math.rad(-105 * weight), math.rad(-18 * weight), 0) end
        if motors.RightShoulder then motors.RightShoulder.Transform = CFrame.Angles(math.rad(-105 * weight), math.rad(18 * weight), 0) end
        if motors.LeftHip then motors.LeftHip.Transform = CFrame.Angles(math.rad(72 * weight), 0, math.rad(-10 * weight)) end
        if motors.RightHip then motors.RightHip.Transform = CFrame.Angles(math.rad(72 * weight), 0, math.rad(10 * weight)) end
        RunService.PreSimulation:Wait()
    end
    for _, m in pairs(motors) do if m then m.Transform = CFrame.identity end end
end
local lastRolling = false
local function update()
    if not humanoid or humanoid.Health <= 0 then return end
    local isRolling, isSneaking = rolling(), sneaking()
    local moving = humanoid.MoveDirection.Magnitude > 0.05
    if isRolling and not lastRolling then task.spawn(playRollTuck) end
    lastRolling = isRolling
    setSprintSpeed()
    if isRolling then
        stopTrack("Sprint", 0.06); stopTrack("Sneak", 0.06)
    elseif isSneaking then
        stopTrack("Sprint", 0.12)
        local t = tracks.Sneak
        if t and moving and not t.IsPlaying then t:Play(0.15, 1, 0.92) elseif t and not moving then stopTrack("Sneak", 0.15) end
    elseif shiftHeld and moving and humanoid.FloorMaterial ~= Enum.Material.Air then
        stopTrack("Sneak", 0.12)
        local t = tracks.Sprint; if t and not t.IsPlaying then t:Play(0.15, 1, 1.05) end
    else
        stopTrack("Sprint", 0.18); stopTrack("Sneak", 0.18)
    end
end
local function disconnectAll()
    rollToken += 1
    for _, c in ipairs(connections) do c:Disconnect() end
    table.clear(connections)
    for _, t in pairs(tracks) do t:Stop(0) end
    table.clear(tracks)
end
local function bindCharacter(char)
    disconnectAll(); character = char; humanoid = char:WaitForChild("Humanoid"); baseSpeed = humanoid.WalkSpeed
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then warn("[MovementAnimations] R15 only") return end
    animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    for _, name in ipairs({"Sprint", "Sneak"}) do
        local a = assets:FindFirstChild(name)
        if a then local ok,t=pcall(function() return animator:LoadAnimation(a) end); if ok then tracks[name]=t; t.Priority=Enum.AnimationPriority.Action; t.Looped=true end end
    end
    for _, target in ipairs({character, humanoid, player}) do
        for _, attr in ipairs({"IsInvincible","IsRolling","Rolling","IsStealth","IsSneaking","Sneaking"}) do
            table.insert(connections, target:GetAttributeChangedSignal(attr):Connect(update))
        end
    end
    table.insert(connections, humanoid.Running:Connect(update))
    table.insert(connections, humanoid.Died:Connect(disconnectAll))
    update()
end
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift) then shiftHeld=true; update() end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then shiftHeld=false; update() end
end)
player.CharacterAdded:Connect(bindCharacter)
if player.Character then task.defer(bindCharacter, player.Character) end
