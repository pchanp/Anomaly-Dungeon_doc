local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local AnimationTracks = require(script.Parent.MovementAnimationTracks)
local AnimationConfig = require(ReplicatedStorage.AnomalyDungeon.Shared.Config.MovementAnimationConfig)
local SPRINT_SPEED = 24
local character, humanoid, animator, baseSpeed
local tracks, connections = {}, {}
local shiftHeld = false

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
local function playRoll()
    local track = tracks.Roll
    if track then
        track:Play(AnimationConfig.Roll.Fade, 1, AnimationConfig.Roll.Duration / AnimationConfig.Roll.ActionDuration)
    end
end
local lastRolling = false
local function update()
    if not humanoid or humanoid.Health <= 0 then return end
    local isRolling, isSneaking = rolling(), sneaking()
    local moving = humanoid.MoveDirection.Magnitude > 0.05
    local stunned = (character:GetAttribute("CombatStunnedUntil") or 0) > workspace:GetServerTimeNow()
    if stunned or player:GetAttribute("RunResultPending") == true then
        for name in pairs(tracks) do stopTrack(name, 0.06) end
        lastRolling = isRolling
        return
    end
    if isRolling and not lastRolling then playRoll() end
    if not isRolling then stopTrack("Roll", 0.06) end
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
        local t = tracks.Sprint; if t and not t.IsPlaying then t:Play(AnimationConfig.Sprint.Fade, 1, AnimationConfig.Sprint.Speed) end
    else
        stopTrack("Sprint", 0.18); stopTrack("Sneak", 0.18)
    end
end
local function disconnectAll()
    lastRolling = false
    for _, c in ipairs(connections) do c:Disconnect() end
    table.clear(connections)
    for _, t in pairs(tracks) do t:Stop(0) end
    table.clear(tracks)
end
local function bindCharacter(char)
    disconnectAll(); character = char; humanoid = char:WaitForChild("Humanoid"); baseSpeed = humanoid.WalkSpeed
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then warn("[MovementAnimations] R15 only") return end
    animator = humanoid:WaitForChild("Animator")
    for _, name in ipairs({"Sprint", "Roll", "Sneak"}) do
        tracks[name] = AnimationTracks.Load(animator, name)
    end
    for _, target in ipairs({character, humanoid, player}) do
        for _, attr in ipairs({"IsInvincible","IsRolling","Rolling","IsStealth","IsSneaking","Sneaking","CombatStunnedUntil","RunResultPending"}) do
            table.insert(connections, target:GetAttributeChangedSignal(attr):Connect(update))
        end
    end
    table.insert(connections, RunService.Heartbeat:Connect(update))
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
