-- DebugFloor: ダンジョン生成に依存せずアノマリー・アイテムの挙動を確認するテストエリア
local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local notice=RS:WaitForChild('AnomalyNotice')
local state=RS:WaitForChild('AnomalyState')

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

-- === 3. Observer (北) ===
local observer=part('Observer',Vector3.new(5,6,3),ORIGIN+Vector3.new(0,3,-80),C.violet,root,Enum.Material.Neon)
sign(observer,'観測体 / 近くでSAN低下 (17st)',C.violet)

-- === 4. Relics (南) ===
local relics={}
for i,x in ipairs({-20,0,20}) do
 local b=part('Relic_'..i,Vector3.new(2,2,2),ORIGIN+Vector3.new(x,2,80),C.yellow,root,Enum.Material.Neon)
 sign(b,'記録片 #'..i..' / 回収')
 relics[i]={Prompt=prompt(b,'回収','記録片'),Id='DEBUG_'..i,Part=b}
end

-- === 5. AnomalyGate (西) ===
local gate=part('AnomalyGate',Vector3.new(1,12,14),ORIGIN+Vector3.new(-100,6,0),C.violet,root)
sign(gate,'異常通路 / SAN 0 で越えられる',C.violet)
prompts.Secret=prompt(gate,'境界を越える','裏側')
local secretArea=part('SecretFloor',Vector3.new(40,2,40),ORIGIN+Vector3.new(-140,0,0),C.dark,root,Enum.Material.Concrete)
sign(secretArea,'異常領域 / AnomalyExitで帰還',C.violet)
station('AnomalyExit',Vector3.new(-140,2,-12),C.violet,'異常出口','外側から帰還')

-- === 6. Debug tools (SAN操作) ===
station('SAN_Zero',Vector3.new(-40,2,-40),C.red,'SAN を 0 にする\n(異常化テスト)','SANを0に')
station('SAN_Full',Vector3.new(40,2,-40),C.green,'SAN を 100 にする\n(回復テスト)','SANを100に')
station('Reset',Vector3.new(0,2,-40),C.blue,'プレイヤー状態をリセット\nSAN/Relic/Anomaly','リセット')

-- === state management ===
local anomalyOwner
local collected={}
local last={}

local function SetSAN(p,value)
 value=math.clamp(value,0,100)
 if value==0 and not p:GetAttribute('IsAnomaly') then
  if not anomalyOwner then anomalyOwner=p; p:SetAttribute('IsAnomaly',true); tell(p,'世界があなたを認識しなくなった。') else value=1 end
 end
 p:SetAttribute('SAN',value)
end
local function Reset(p)
 if anomalyOwner==p then anomalyOwner=nil end
 p:SetAttribute('IsAnomaly',false); p:SetAttribute('SAN',100); p:SetAttribute('InDungeon',false); p:SetAttribute('Relics',0); p:SetAttribute('Room','DEBUG'); collected[p]={}
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
 Reset(p); p:SetAttribute('InDungeon',true); local _,h=body(p); if h then h.Health=h.MaxHealth end
 tell(p,'デバッグ: ダンジョン状態を付与しました')
end)
-- Extract
bind(prompts.Extract,function(p)
 if not p:GetAttribute('InDungeon') then tell(p,'ダンジョン状態ではありません'); return end
 local n=p:GetAttribute('Relics') or 0
 Reset(p); tell(p,'デバッグ: 脱出 / 記録片 '..n..' 個')
end)
-- Secret gate
bind(prompts.Secret,function(p)
 if p:GetAttribute('IsAnomaly') then teleport(p,ORIGIN+Vector3.new(-140,4,0)); tell(p,'異常領域へ移動') else tell(p,'ただの壁だ。SAN が低ければ違って見えるかもしれない。') end
end)
-- AnomalyExit
bind(prompts.AnomalyExit,function(p)
 if not p:GetAttribute('IsAnomaly') then tell(p,'この出口はあなたを認識できない。'); return end
 Reset(p); teleport(p,ORIGIN+Vector3.new(0,4,0)); tell(p,'異常出口から帰還')
end)
-- SAN Zero
bind(prompts.SAN_Zero,function(p)
 SetSAN(p,0); tell(p,'デバッグ: SAN = 0')
end)
-- SAN Full
bind(prompts.SAN_Full,function(p)
 if anomalyOwner==p then anomalyOwner=nil end
 p:SetAttribute('IsAnomaly',false); p:SetAttribute('SAN',100); tell(p,'デバッグ: SAN = 100')
end)
-- Reset
bind(prompts.Reset,function(p)
 Reset(p); tell(p,'デバッグ: 状態リセット完了')
end)
-- Relics
for _,item in relics do
 bind(item.Prompt,function(p)
  if not p:GetAttribute('InDungeon') then tell(p,'ダンジョン状態が必要です (Enterで開始)'); return end
  collected[p]=collected[p] or {}; if collected[p][item.Id] then tell(p,'回収済みです'); return end
  collected[p][item.Id]=true; p:SetAttribute('Relics',(p:GetAttribute('Relics') or 0)+1); tell(p,'記録片を回収')
 end)
end

-- === tick loop (pool + observer + room detection) ===
local function PoolEffect(count) return count>=2 and -8*(count-1) or (count==1 and 6 or 0) end

task.spawn(function()
 while true do
  task.wait(.5); local dt=.5
  local occupants={}
  for _,p in Players:GetPlayers() do
   local r,h=body(p)
   if r and h and h.Health>0 then
    -- pool
    local dp=r.Position-pool.Position
    if math.abs(dp.X)<=9 and math.abs(dp.Z)<=9 and math.abs(dp.Y)<6 then table.insert(occupants,p) end
    -- observer
    if (r.Position-observer.Position).Magnitude<17 then
     SetSAN(p,(p:GetAttribute('SAN') or 100)-8*dt)
    end
    -- room label
    if (r.Position-ORIGIN).Magnitude<FLOOR_SIZE/2 then
     p:SetAttribute('Room','DEBUG_FLOOR')
    end
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

-- player init
local function onPlayer(p)
 p:SetAttribute('Banked',p:GetAttribute('Banked') or 0); Reset(p)
 p.CharacterAdded:Connect(function(c)
  Reset(p); local h=c:WaitForChild('Humanoid'); h.WalkSpeed=20
  task.defer(function() teleport(p,ORIGIN+Vector3.new(0,4,30)) end)
 end)
 if p.Character then task.spawn(function() teleport(p,ORIGIN+Vector3.new(0,4,30)) end) end
end
Players.PlayerAdded:Connect(onPlayer)
for _,p in Players:GetPlayers() do onPlayer(p) end
Players.PlayerRemoving:Connect(function(p) if anomalyOwner==p then anomalyOwner=nil end; collected[p]=nil; last[p]=nil end)

print('[DEBUG FLOOR] ready at '..tostring(ORIGIN))
