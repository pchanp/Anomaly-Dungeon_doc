-- SkillServer: サーバー側スキル実行・検証
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local Debris = game:GetService('Debris')

local skillEvent = RS:WaitForChild('SkillEvent')

-- サーバー側クールダウン（チート防止）
local SKILL_CD = {[1] = 3, [2] = 4, [3] = 10}
local serverCd = {} -- [player] = {[slot] = endTime}

local function getChar(p)
  local c = p.Character
  if not c then return nil, nil end
  return c:FindFirstChild('HumanoidRootPart'), c:FindFirstChildOfClass('Humanoid')
end

-- ============================================================
-- スキル1: 遠距離攻撃魔法 (Magic Bolt)
-- ============================================================
local function magicBolt(player, root)
  local startCf = root.CFrame * CFrame.new(0, 1, -3)
  local proj = Instance.new('Part')
  proj.Name = 'MagicBolt'
  proj.Shape = Enum.PartType.Ball
  proj.Size = Vector3.new(2, 2, 2)
  proj.Color = Color3.fromRGB(80, 180, 255)
  proj.Material = Enum.Material.Neon
  proj.Anchored = false
  proj.CanCollide = false
  proj.CFrame = startCf
  proj.Parent = workspace

  local light = Instance.new('PointLight')
  light.Color = Color3.fromRGB(80, 180, 255)
  light.Range = 15
  light.Brightness = 2
  light.Parent = proj

  local dir = root.CFrame.LookVector
  proj.AssemblyLinearVelocity = dir * 80

  local hitDebounce = {}
  proj.Touched:Connect(function(other)
    local char = other.Parent
    if char == player.Character then return end
    if hitDebounce[char] then return end
    local hum = char and char:FindFirstChildOfClass('Humanoid')
    if hum and hum.Health > 0 then
      hitDebounce[char] = true
      if not char:GetAttribute('IsInvincible') then
        hum:TakeDamage(25)
      end
      proj:Destroy()
    end
  end)

  Debris:AddItem(proj, 4)
end

-- ============================================================
-- スキル2: 無敵ローリング (Roll)
-- ============================================================
local function roll(player, root, hum)
  player:SetAttribute('IsInvincible', true)
  local char = player.Character
  if char then
    for _, p in ipairs(char:GetDescendants()) do
      if p:IsA('BasePart') and p.Name ~= 'HumanoidRootPart' then
        p:SetAttribute('RollOrigTrans', p.Transparency)
        p.Transparency = math.min(p.Transparency + 0.3, 1)
      end
    end
  end

  task.delay(0.6, function()
    player:SetAttribute('IsInvincible', false)
    if char and char.Parent then
      for _, p in ipairs(char:GetDescendants()) do
        if p:IsA('BasePart') and p.Name ~= 'HumanoidRootPart' then
          local orig = p:GetAttribute('RollOrigTrans')
          if orig then
            p.Transparency = orig
            p:SetAttribute('RollOrigTrans', nil)
          end
        end
      end
    end
  end)
end

-- ============================================================
-- スキル3: 隠密移動 (Stealth)
-- ============================================================
local function stealth(player, root, hum)
  player:SetAttribute('IsStealth', true)
  local char = player.Character
  if char then
    for _, p in ipairs(char:GetDescendants()) do
      if p:IsA('BasePart') and p.Name ~= 'HumanoidRootPart' then
        p:SetAttribute('StealthOrigTrans', p.Transparency)
        p.Transparency = math.max(p.Transparency, 0.6)
      end
    end
  end
  hum.WalkSpeed = 30

  task.delay(5, function()
    player:SetAttribute('IsStealth', false)
    if char and char.Parent then
      for _, p in ipairs(char:GetDescendants()) do
        if p:IsA('BasePart') and p.Name ~= 'HumanoidRootPart' then
          local orig = p:GetAttribute('StealthOrigTrans')
          if orig then
            p.Transparency = orig
            p:SetAttribute('StealthOrigTrans', nil)
          end
        end
      end
      local h = char:FindFirstChildOfClass('Humanoid')
      if h then h.WalkSpeed = 20 end
    end
  end)
end

-- ============================================================
-- メインハンドラ
-- ============================================================
skillEvent.OnServerEvent:Connect(function(player, slot)
  if typeof(slot) ~= 'number' then return end
  local root, hum = getChar(player)
  if not root or not hum or hum.Health <= 0 then return end

  -- サーバー側クールダウン検証
  serverCd[player] = serverCd[player] or {}
  local now = os.clock()
  if serverCd[player][slot] and now < serverCd[player][slot] then return end
  serverCd[player][slot] = now + (SKILL_CD[slot] or 0)

  if slot == 1 then
    magicBolt(player, root)
  elseif slot == 2 then
    roll(player, root, hum)
  elseif slot == 3 then
    stealth(player, root, hum)
  end
end)

Players.PlayerRemoving:Connect(function(p)
  serverCd[p] = nil
end)

print('[SKILL SERVER] ready')
