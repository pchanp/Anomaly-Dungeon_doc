local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local assets = ReplicatedStorage:WaitForChild("MovementAnimations")
local character, humanoid, animator
local tracks = {}
local shiftHeld = false
local rolling = false
local sneaking = false
local connections = {}

local function attrTrue(name)
    return (character and character:GetAttribute(name) == true)
        or (humanoid and humanoid:GetAttribute(name) == true)
        or player:GetAttribute(name) == true
end

local function stop(name, fade)
    local track = tracks[name]
    if track and track.IsPlaying then track:Stop(fade or 0.15) end
end

local function updateLocomotion()
    if not humanoid or humanoid.Health <= 0 then return end
    rolling = attrTrue("IsInvincible") or attrTrue("IsRolling") or attrTrue("Rolling")
    sneaking = attrTrue("IsStealth") or attrTrue("IsSneaking") or attrTrue("Sneaking")
    local moving = humanoid.MoveDirection.Magnitude > 0.05
    if rolling then
        stop("Sprint", 0.08); stop("Sneak", 0.08)
        if tracks.Roll and not tracks.Roll.IsPlaying then tracks.Roll:Play(0.06, 1, 1.05) end
    elseif sneaking then
        stop("Sprint", 0.12); stop("Roll", 0.08)
        if tracks.Sneak then
            if moving and not tracks.Sneak.IsPlaying then tracks.Sneak:Play(0.18, 1, 1) end
            if not moving then stop("Sneak", 0.18) end
        end
    elseif shiftHeld and moving and humanoid.FloorMaterial ~= Enum.Material.Air then
        stop("Sneak", 0.12); stop("Roll", 0.08)
        if tracks.Sprint and not tracks.Sprint.IsPlaying then tracks.Sprint:Play(0.16, 1, 1.12) end
    else
        stop("Sprint", 0.18); stop("Sneak", 0.18)
    end
end

local function disconnectAll()
    for _, c in ipairs(connections) do c:Disconnect() end
    table.clear(connections)
    for _, track in pairs(tracks) do track:Stop(0) end
    table.clear(tracks)
end

local function bindCharacter(char)
    disconnectAll()
    character = char
    humanoid = char:WaitForChild("Humanoid")
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        warn("[MovementAnimations] R15 only; current rig skipped")
        return
    end
    animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
    for _, name in ipairs({"Sprint", "Roll", "Sneak"}) do
        local animation = assets:FindFirstChild(name)
        if animation and animation:IsA("Animation") then
            local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
            if ok then
                tracks[name] = track
                track.Priority = name == "Roll" and Enum.AnimationPriority.Action4 or Enum.AnimationPriority.Action
                track.Looped = name ~= "Roll"
            else
                warn("[MovementAnimations] Failed to load", name, track)
            end
        end
    end
    for _, target in ipairs({character, humanoid, player}) do
        for _, attr in ipairs({"IsInvincible", "IsRolling", "Rolling", "IsStealth", "IsSneaking", "Sneaking"}) do
            table.insert(connections, target:GetAttributeChangedSignal(attr):Connect(updateLocomotion))
        end
    end
    table.insert(connections, humanoid.Running:Connect(updateLocomotion))
    table.insert(connections, humanoid.Died:Connect(function() disconnectAll() end))
    updateLocomotion()
end

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift) then
        shiftHeld = true; updateLocomotion()
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        shiftHeld = false; updateLocomotion()
    end
end)
player.CharacterAdded:Connect(bindCharacter)
if player.Character then task.defer(bindCharacter, player.Character) end
