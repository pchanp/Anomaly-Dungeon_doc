-- DebugFloor: ダンジョン生成に依存せずアノマリー・アイテムの挙動を確認するテストエリア
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local notice=RS:WaitForChild('AnomalyNotice')
local state=RS:WaitForChild('AnomalyState')
local Exposure=require(script.Parent.Parent.Services.ExposureService)
local RunConfig=require(RS.AnomalyDungeon.Shared.Config.RunConfig)

local function tell(p,t) notice:FireClient(p,t) end
local function body(p) local c=p.Character; return c and c:FindFirstChild('HumanoidRootPart'),c and c:FindFirstChildOfClass('Humanoid') end

-- colors matching the main game
local C={wall=Color3.fromRGB(167,166,151),floor=Color3.fromRGB(118,119,111),blue=Color3.fromRGB(26,61,103),yellow=Color3.fromRGB(236,203,70),dark=Color3.fromRGB(47,52,57),cyan=Color3.fromRGB(80,218,202),violet=Color3.fromRGB(157,108,195),green=Color3.fromRGB(78,221,217),red=Color3.fromRGB(224,64,64)}

local ORIGIN=Vector3.new(1200,1000,0) -- ダンジョンから離れた位置
local FLOOR_SIZE=240

local function part(n,size,pos,col,p,mat)
 local b=Instance.new('Part'); b.Name=n; b.Anchored=true; b.Size=size; b.Position=pos; b.Color=col; b.Material=mat or Enum.Material.SmoothPlastic; b.TopSurface=Enum.SurfaceType.Smooth; b.BottomSurface=Enum.SurfaceType.Smooth; b.Parent=p; return b
end
local function sign(b,text,color)
 local g=Instance.new('BillboardGui'); g.Name='Sign'; g.Size=UDim2.fromOffset(300,72); g.StudsOffset=Vector3.new(0,5,0); g.MaxDistance=60; g.Parent=b
 local t=Instance.new('TextLabel'); t.Size=UDim2.fromScale(1,1); t.BackgroundColor3=C.dark; t.BackgroundTransparency=.15; t.TextColor3=color or C.yellow; t.TextSize=16; t.TextWrapped=true; t.Font=Enum.Font.GothamMedium; t.Text=text; t.Parent=g
end
local function prompt(b,action,name)
 local q=Instance.new('ProximityPrompt'); q.ActionText=action; q.ObjectText=name; q.HoldDuration=.35; q.MaxActivationDistance=12; q.RequiresLineOfSight=false; q.Parent=b; return q
end

-- build floor
local root=Instance.new('Model'); root.Name='DebugFloor'; root.Parent=workspace
root:SetAttribute('Theme','Debug Test Floor'); root:SetAttribute('Version','debug')

local floor=part('Floor',Vector3.new(FLOOR_SIZE,2,FLOOR_SIZE),ORIGIN,C.floor,root,Enum.Material.Concrete)
part('Ceiling',Vector3.new(FLOOR_SIZE,1,FLOOR_SIZE),ORIGIN+Vector3.new(0,24,0),Color3.fromRGB(60,63,62),root)

-- walls
for _,side in {'N','S','E','W'} do
 local alongX=side=='N' or side=='S'
 local size=alongX and Vector3.new(FLOOR_SIZE,24,2) or Vector3.new(2,24,FLOOR_SIZE)
 local dir=(side=='S' or side=='E') and 1 or -1
 local pos=alongX and ORIGIN+Vector3.new(0,12,dir*FLOOR_SIZE/2) or ORIGIN+Vector3.new(dir*FLOOR_SIZE/2,12,0)
 part('Wall_'..side,size,pos,C.wall,root)
end

-- lighting
for ix=-2,2 do for iz=-2,2 do
 local b=part('Light',Vector3.new(10,.3,1.5),ORIGIN+Vector3.new(ix*40,23,iz*40),Color3.fromRGB(229,237,218),root,Enum.Material.Neon)
 local l=Instance.new('PointLight'); l.Color=Color3.fromRGB(222,232,211); l.Range=50; l.Brightness=1.2; l.Shadows=false; l.Parent=b
end end

-- helper: station with prompt
local prompts={}
local function station(n,offset,color,text,action)
 local b=part(n,Vector3.new(6,4,4),ORIGIN+offset,color,root,Enum.Material.Metal)
 sign(b,text,color)
 local q=prompt(b,action,n); prompts[n]=q; return b
end

-- === 1. Enter / Extract (中央) ===
station('Enter',Vector3.new(0,2,-20),C.yellow,'DEBUG ENTER\nダンジョン状態を付与','入る')
station('Extract',Vector3.new(0,2,20),C.cyan,'DEBUG EXTRACT\nダンジョン状態を解除','脱出する')

-- === 2. HealingPool (東) ===
local pool=part('HealingPool',Vector3.new(18,.3,18),ORIGIN+Vector3.new(60,.2,0),C.cyan,root,Enum.Material.Neon)
pool.CanCollide=false
sign(pool,'泉 / 1人で回復・2人以上で毒',C.cyan)
pool.Sign.TextLabel.Text='泉 / 0人 / 回復'

-- === 3. Observer (北) ===
local observer=part('Observer',Vector3.new(5,6,3),ORIGIN+Vector3.new(0,3,-80),C.violet,root,Enum.Material.Neon)
sign(observer,'観測体 / 近くにいるとExposure増加 (17st)',C.violet)

-- === 4. AnomalyGate (西) ===

local gate=part('AnomalyGate',Vector3.new(1,12,14),ORIGIN+Vector3.new(-100,6,0),C.violet,root)
sign(gate,'異常通路 / 変異状態で越えられる',C.violet)
prompts.Secret=prompt(gate,'境界を越える','裏側')
local secretArea=part('SecretFloor',Vector3.new(40,2,40),ORIGIN+Vector3.new(-140,0,0),C.dark,root,Enum.Material.Concrete)
sign(secretArea,'異常領域 / 出口ポータルから帰還',C.violet)
station('AnomalyExit',Vector3.new(-140,2,-12),C.violet,'出口ポータル','帰還する')

-- === 6. Debug tools (Exposure操作) ===
station('Exposure_Max',Vector3.new(-40,2,-40),C.red,'Exposure を閾値にする / 異常化テスト','Exposure最大')
station('Exposure_Zero',Vector3.new(40,2,-40),C.green,'Exposure を 0 にする / リセットテスト','Exposureを0に')
station('Reset',Vector3.new(0,2,-40),C.blue,'プレイヤー状態をリセット\nExposure/Anomaly/Lifetime','リセット')

-- === state management ===
local last={}

local function Reset(p,nextState)
 Exposure.Reset(p)
 p:SetAttribute('InDungeon',false); p:SetAttribute('Room','DEBUG'); p:SetAttribute('PlayerRunState',nextState or RunConfig.PlayerRunLobby)
end
local function teleport(p,pos) if p.Character then p.Character:PivotTo(CFrame.new(pos)) end end

local function bind(q,fn)
 q.Triggered:Connect(function(p)
  local r,h=body(p); if not r or not h or h.Health<=0 then return end
  local now=os.clock(); if now-(last[p] or 0)<.4 then return end; last[p]=now
  fn(p)
 end)
end

-- Enter
bind(prompts.Enter,function(p)
 if p:GetAttribute('InDungeon') then tell(p,'既にダンジョン状態です'); return end
 Reset(p,RunConfig.PlayerRunExploring); p:SetAttribute('InDungeon',true); local _,h=body(p); if h then h.Health=h.MaxHealth end
 tell(p,'デバッグ: ダンジョン状態を付与しました')
end)
-- Extract
bind(prompts.Extract,function(p)
 if not p:GetAttribute('InDungeon') then tell(p,'ダンジョン状態ではありません'); return end
 Reset(p,RunConfig.PlayerRunReturned); tell(p,'デバッグ: 帰還')
end)
-- Secret gate
bind(prompts.Secret,function(p)
 if Exposure.IsTransformed(p) then teleport(p,ORIGIN+Vector3.new(-140,4,0)); tell(p,'異常領域へ移動') else tell(p,'ただの壁だ。今のあなたには何も見えない。') end
end)
-- AnomalyExit
bind(prompts.AnomalyExit,function(p)
 Reset(p,RunConfig.PlayerRunReturned); teleport(p,ORIGIN+Vector3.new(0,4,0)); tell(p,'出口ポータルから帰還')
end)
-- Exposure threshold
bind(prompts.Exposure_Max,function(p)
 Exposure.Set(p,RunConfig.TransformationThreshold); tell(p,'デバッグ: Exposure = threshold')
end)
-- Exposure zero
bind(prompts.Exposure_Zero,function(p)
 Exposure.Reset(p); tell(p,'デバッグ: Exposure = 0')
end)
-- Reset
bind(prompts.Reset,function(p)
 Reset(p); tell(p,'デバッグ: 状態リセット完了')
end)
-- === tick loop (pool + observer + room detection) ===
local function PoolEffect(count) return count>=2 and -8*(count-1) or (count==1 and 6 or 0) end
-- デバッグフロアの範囲内にいる人だけを対象にする。Run中のプレイヤーまで触ると
-- Run Lifetime と状態リセットが RunService と競合する。
local function inFloor(p)
 local r=p.Character and p.Character:FindFirstChild('HumanoidRootPart')
 if not r then return false end
 return (r.Position-ORIGIN).Magnitude<FLOOR_SIZE/2
end

task.spawn(function()
 while true do
  task.wait(.5); local dt=.5
  local occupants={}
  for _,p in Players:GetPlayers() do
   local r,h=body(p)
   if r and h and h.Health>0 and inFloor(p) then
    if p:GetAttribute('RunLifetimeTicks') then
     local remaining=math.max(0,(p:GetAttribute('RunLifetimeRemaining') or RunConfig.TransformedLifetimeSeconds)-dt); p:SetAttribute('RunLifetimeRemaining',remaining)
     if remaining<=0 then Reset(p,RunConfig.PlayerRunReturned); teleport(p,ORIGIN+Vector3.new(0,4,0)); tell(p,'Run Lifetime終了 / 強制帰還しました') end
    end
    -- pool
    local dp=r.Position-pool.Position
    if math.abs(dp.X)<=9 and math.abs(dp.Z)<=9 and math.abs(dp.Y)<6 then table.insert(occupants,p) end
    -- observer
    if (r.Position-observer.Position).Magnitude<17 then
     Exposure.Add(p,RunConfig.ObserverExposurePerSecond*dt)
    end
    -- room label
    p:SetAttribute('Room','DEBUG_FLOOR')
   end
  end
  pool:SetAttribute('Occupants',#occupants)
  pool.Color=#occupants>=2 and Color3.fromRGB(170,225,65) or C.cyan
  for _,p in occupants do
   local _,h=body(p); local delta=PoolEffect(#occupants)*dt
   if delta<0 then h:TakeDamage(-delta) else h.Health=math.min(h.MaxHealth,h.Health+delta) end
  end
 end
end)

-- === player init ===
-- 初期配置は RunService が都市ロビーへ行う。ここでは移動させず、デバッグフロア内の操作だけを受ける。
Players.PlayerRemoving:Connect(function(p) Exposure.Release(p); last[p]=nil end)

print('[DEBUG FLOOR] ready at '..tostring(ORIGIN))
