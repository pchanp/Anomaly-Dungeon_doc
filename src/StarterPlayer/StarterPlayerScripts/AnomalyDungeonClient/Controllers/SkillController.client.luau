-- SkillClient: SHIFTダッシュ + 4スロットスキルインベントリ
local Players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local UIS = game:GetService('UserInputService')

local player = Players.LocalPlayer
local skillEvent = RS:WaitForChild('SkillEvent')

-- ============================================================
-- スキル定義
-- ============================================================
local SKILL_DEFS = {
  [1] = {name = 'Magic Bolt',  cd = 3,  desc = '遠距離攻撃魔法'},
  [2] = {name = 'Roll',        cd = 4,  desc = '無敵ローリング'},
  [3] = {name = 'Stealth',     cd = 10, desc = '隠密移動'},
  [4] = {name = '—',           cd = 0,  desc = '空きスロット'},
}

local DASH_CD    = 1.5
local DASH_POWER = 55

-- ============================================================
-- 状態
-- ============================================================
local cooldowns = {}     -- [slot] = os.clock()終了時刻
local dashCdEnd  = 0

-- ============================================================
-- UI構築
-- ============================================================
local gui = Instance.new('ScreenGui')
gui.Name = 'SkillHUD'
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild('PlayerGui')

local bar = Instance.new('Frame')
bar.Name = 'SkillBar'
bar.Size = UDim2.new(0, 340, 0, 70)
bar.Position = UDim2.new(0.5, -170, 1, -90)
bar.BackgroundColor3 = Color3.fromRGB(12, 18, 27)
bar.BackgroundTransparency = 0.15
bar.Parent = gui
local barCorner = Instance.new('UICorner')
barCorner.CornerRadius = UDim.new(0, 10)
barCorner.Parent = bar

local slots = {}
for i = 1, 4 do
  local slot = Instance.new('Frame')
  slot.Name = 'Slot' .. i
  slot.Size = UDim2.new(0, 72, 0, 56)
  slot.Position = UDim2.new(0, 10 + (i - 1) * 82, 0, 7)
  slot.BackgroundColor3 = Color3.fromRGB(30, 38, 50)
  slot.Parent = bar
  local sc = Instance.new('UICorner'); sc.CornerRadius = UDim.new(0, 8); sc.Parent = slot

  local label = Instance.new('TextLabel')
  label.Name = 'Label'
  label.Size = UDim2.new(1, 0, 0.4, 0)
  label.Position = UDim2.fromScale(0, 0)
  label.BackgroundTransparency = 1
  label.TextColor3 = Color3.fromRGB(219, 233, 239)
  label.Font = Enum.Font.GothamMedium
  label.TextSize = 11
  label.Text = SKILL_DEFS[i].name
  label.Parent = slot

  local keyLabel = Instance.new('TextLabel')
  keyLabel.Name = 'Key'
  keyLabel.Size = UDim2.fromScale(0.28, 0.28)
  keyLabel.Position = UDim2.fromScale(0.06, 0.06)
  keyLabel.BackgroundColor3 = Color3.fromRGB(60, 70, 85)
  keyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
  keyLabel.Font = Enum.Font.GothamBold
  keyLabel.TextSize = 11
  keyLabel.Text = tostring(i)
  keyLabel.Parent = slot
  local kc = Instance.new('UICorner'); kc.CornerRadius = UDim.new(0, 4); kc.Parent = keyLabel

  local cdOverlay = Instance.new('TextLabel')
  cdOverlay.Name = 'Cooldown'
  cdOverlay.Size = UDim2.fromScale(1, 1)
  cdOverlay.Position = UDim2.fromScale(0, 0)
  cdOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  cdOverlay.BackgroundTransparency = 0.55
  cdOverlay.TextColor3 = Color3.fromRGB(255, 255, 255)
  cdOverlay.Font = Enum.Font.GothamBold
  cdOverlay.TextSize = 20
  cdOverlay.Text = ''
  cdOverlay.Visible = false
  cdOverlay.Parent = slot

  slots[i] = {frame = slot, label = label, cd = cdOverlay}
end

-- ダッシュ表示
local dashLabel = Instance.new('TextLabel')
dashLabel.Name = 'DashHint'
dashLabel.Size = UDim2.new(0, 340, 0, 20)
dashLabel.Position = UDim2.new(0, 0, 0, -22)
dashLabel.BackgroundTransparency = 1
dashLabel.TextColor3 = Color3.fromRGB(150, 160, 170)
dashLabel.Font = Enum.Font.GothamMedium
dashLabel.TextSize = 12
dashLabel.Text = 'SHIFT: Dash [Ready]'
dashLabel.Parent = bar

-- ============================================================
-- ヘルパー
-- ============================================================
local function getChar()
  local c = player.Character
  if not c then return nil, nil end
  return c:FindFirstChild('HumanoidRootPart'), c:FindFirstChildOfClass('Humanoid')
end

local function playDashSound(root)
  local old=root:FindFirstChild("DashSFX")
  if old then old:Destroy() end
  local sound=Instance.new("Sound")
  sound.Name="DashSFX"
  sound.SoundId="rbxasset://sounds/action_jump_land.mp3"
  sound.Volume=.75
  sound.PlaybackSpeed=1.18
  sound.Parent=root
  sound:Play()
  game:GetService("Debris"):AddItem(sound,2)
end

-- ============================================================
-- ダッシュ（クライアント側で即座に実行、物理は所有権により複製）
-- ============================================================
local function tryDash()
  if os.clock() < dashCdEnd then return end
  local root, hum = getChar()
  if not root or not hum or hum.Health <= 0 then return end

  local look = root.CFrame.LookVector
  local dir = Vector3.new(look.X, 0, look.Z)
  if dir.Magnitude < 0.1 then return end
  dir = dir.Unit

  root.AssemblyLinearVelocity = dir * DASH_POWER + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
  playDashSound(root)
  dashCdEnd = os.clock() + DASH_CD
end

-- ============================================================
-- スキル発動
-- ============================================================
local function trySkill(slot)
  if slot < 1 or slot > 4 then return end
  local def = SKILL_DEFS[slot]
  if def.cd == 0 then return end

  local now = os.clock()
  if cooldowns[slot] and now < cooldowns[slot] then return end

  local root, hum = getChar()
  if not root or not hum or hum.Health <= 0 then return end

  cooldowns[slot] = now + def.cd
  skillEvent:FireServer(slot)

  -- Roll: クライアント側で即座に移動ベクトルを適用
  if slot == 2 then
    local moveDir = hum.MoveDirection
    if moveDir.Magnitude < 0.1 then
      local lv = root.CFrame.LookVector
      moveDir = Vector3.new(lv.X, 0, lv.Z)
    end
    if moveDir.Magnitude > 0.01 then
      moveDir = moveDir.Unit
      root.AssemblyLinearVelocity = moveDir * 50 + Vector3.new(0, 12, 0)
    end
  end
end

-- ============================================================
-- 入力処理
-- ============================================================
UIS.InputBegan:Connect(function(input, gp)
  if gp then return end
  if input.KeyCode == Enum.KeyCode.LeftShift then
    tryDash()
  elseif input.KeyCode == Enum.KeyCode.One then
    trySkill(1)
  elseif input.KeyCode == Enum.KeyCode.Two then
    trySkill(2)
  elseif input.KeyCode == Enum.KeyCode.Three then
    trySkill(3)
  elseif input.KeyCode == Enum.KeyCode.Four then
    trySkill(4)
  end
end)

-- ============================================================
-- UI更新ループ
-- ============================================================
task.spawn(function()
  while true do
    task.wait(0.1)
    local now = os.clock()

    for i = 1, 4 do
      local cdEnd = cooldowns[i]
      if cdEnd and now < cdEnd then
        slots[i].cd.Visible = true
        slots[i].cd.Text = string.format('%.1f', cdEnd - now)
      else
        slots[i].cd.Visible = false
      end
    end

    if now < dashCdEnd then
      dashLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
      dashLabel.Text = string.format('SHIFT: Dash (%.1fs)', dashCdEnd - now)
    else
      dashLabel.TextColor3 = Color3.fromRGB(150, 160, 170)
      dashLabel.Text = 'SHIFT: Dash [Ready]'
    end
  end
end)

print('[SKILL CLIENT] ready')
