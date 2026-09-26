local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Map=require(script.Parent.MapGenerator)
local M={}; local world; local anomalyOwner; local collected={}; local last={}; local connections={}
local state=RS:WaitForChild('AnomalyState'); local notice=RS:WaitForChild('AnomalyNotice')
local function tell(p,t) notice:FireClient(p,t) end
local function body(p) local c=p.Character; return c and c:FindFirstChild('HumanoidRootPart'),c and c:FindFirstChildOfClass('Humanoid') end
local function teleport(p,pos) if p.Character then p.Character:PivotTo(CFrame.new(pos)) end end
function M.SetSAN(p,value)
 value=math.clamp(value,0,100)
 if value==0 and not p:GetAttribute('IsAnomaly') then
  if not anomalyOwner then anomalyOwner=p; p:SetAttribute('IsAnomaly',true); tell(p,'世界があなたを認識しなくなった。VHS売場の境界へ。') else value=1 end
 end
 p:SetAttribute('SAN',value)
end
function M.Reset(p)
 if anomalyOwner==p then anomalyOwner=nil end
 p:SetAttribute('IsAnomaly',false); p:SetAttribute('SAN',100); p:SetAttribute('InDungeon',false); p:SetAttribute('Relics',0); p:SetAttribute('Room','LOBBY'); collected[p]={}
end
function M.Enter(p)
 local _,h=body(p); if not h or h.Health<=0 or p:GetAttribute('InDungeon') then return end
 M.Reset(p); p:SetAttribute('InDungeon',true); h.Health=h.MaxHealth; teleport(p,world.Entry); tell(p,'記録片を集め、出口へ。危険なら入口からも帰還できます。')
end
function M.Extract(p,abnormal)
 if not p:GetAttribute('InDungeon') then return false end
 if p:GetAttribute('IsAnomaly')~=abnormal then tell(p,abnormal and 'ここは正常な存在の出口ではない。' or 'この出口はあなたを認識できない。VHS売場の境界へ。'); return false end
 local n=p:GetAttribute('Relics') or 0; p:SetAttribute('Banked',(p:GetAttribute('Banked') or 0)+n)
 M.Reset(p); teleport(p,world.Lobby); local _,h=body(p); if h then h.Health=h.MaxHealth end; tell(p,'帰還成功 / 記録片 '..n..' 個を持ち帰りました'); return true
end
local function bind(q,fn)
 table.insert(connections,q.Triggered:Connect(function(p)
  local r,h=body(p); if not r or not h or h.Health<=0 or (r.Position-q.Parent.Position).Magnitude>13 then return end
  local now=os.clock(); if now-(last[p] or 0)<.4 then return end; last[p]=now; fn(p)
 end))
end
function M.Build(seed)
 for _,c in connections do c:Disconnect() end; connections={}
 world=Map.Build(seed); state:SetAttribute('Seed',seed); state:SetAttribute('Route',world.Root:GetAttribute('Route'))
 bind(world.Prompts.Enter,M.Enter)
 bind(world.Prompts.Reroll,function(p)
  for _,v in Players:GetPlayers() do if v:GetAttribute('InDungeon') then tell(p,'探索中のプレイヤーがいます。全員帰還してから再構成してください。'); return end end
  M.Build(Random.new():NextInteger(1000,99999)); for _,v in Players:GetPlayers() do teleport(v,world.Lobby) end
 end)
 for _,name in {'Return','Extract'} do bind(world.Prompts[name],function(p) M.Extract(p,false) end) end
 bind(world.Prompts.AnomalyExit,function(p) M.Extract(p,true) end)
 bind(world.Prompts.Secret,function(p)
  if p:GetAttribute('InDungeon') and p:GetAttribute('IsAnomaly') then teleport(p,world.SecretSpawn) else tell(p,'ただの壁だ。SAN が低ければ違って見えるかもしれない。') end
 end)
 bind(world.Prompts.Boss,function(p) if p:GetAttribute('InDungeon') then state:SetAttribute('BossName',p.DisplayName); state:SetAttribute('BossUntil',workspace:GetServerTimeNow()+8) end end)
 for _,item in world.Relics do bind(item.Prompt,function(p)
  if not p:GetAttribute('InDungeon') then return end
  collected[p]=collected[p] or {}; if collected[p][item.Id] then tell(p,'この記録片は回収済みです'); return end
  collected[p][item.Id]=true; p:SetAttribute('Relics',(p:GetAttribute('Relics') or 0)+1); tell(p,'記録片を回収。帰還すると持ち帰れます。')
 end) end
end
function M.PoolEffect(count) return count>=2 and -8*(count-1) or (count==1 and 6 or 0) end
function M.Tick(dt)
 local occupants={}
 for _,p in Players:GetPlayers() do
  local r,h=body(p)
  if r and h and h.Health>0 and p:GetAttribute('InDungeon') then
   local delta=r.Position-world.Pool.Position
   if math.abs(delta.X)<=9 and math.abs(delta.Z)<=9 and math.abs(delta.Y)<6 then table.insert(occupants,p) end
   if (r.Position-world.Observer.Position).Magnitude<17 then M.SetSAN(p,(p:GetAttribute('SAN') or 100)-8*dt) end
   local roomName='CORRIDOR'; for _,room in world.Rooms do local d=r.Position-room.Center; if math.abs(d.X)<room.Width/2 and math.abs(d.Z)<room.Depth/2 and math.abs(d.Y)<room.Height then roomName=room.DisplayName end end
   p:SetAttribute('Room',roomName)
   if r.Position.Y<world.KillY then h.Health=0 end
  end
 end
 world.Pool:SetAttribute('Occupants',#occupants); world.Pool.Color=#occupants>=2 and Color3.fromRGB(170,225,65) or Color3.fromRGB(78,221,217)
 world.Pool.Sign.TextLabel.Text='泉 / '..#occupants..'人 / '..(#occupants>=2 and '毒' or '回復')
 for _,p in occupants do local _,h=body(p); local delta=M.PoolEffect(#occupants)*dt; if delta<0 then h:TakeDamage(-delta) else h.Health=math.min(h.MaxHealth,h.Health+delta) end end
end
function M.GetWorld() return world end
function M.Start()
 M.Build(92026)
 local function player(p)
  p:SetAttribute('Banked',0); M.Reset(p)
  local function character(c)
   M.Reset(p); local h=c:WaitForChild('Humanoid'); h.WalkSpeed=20; task.defer(function() teleport(p,world.Lobby) end)
   h.Died:Connect(function() M.Reset(p); tell(p,'探索失敗 / 未帰還の記録片を失いました') end)
  end
  p.CharacterAdded:Connect(character); if p.Character then task.spawn(character,p.Character) end
 end
 Players.PlayerAdded:Connect(player); for _,p in Players:GetPlayers() do player(p) end
 Players.PlayerRemoving:Connect(function(p) if anomalyOwner==p then anomalyOwner=nil end; collected[p]=nil; last[p]=nil end)
 task.spawn(function() while true do task.wait(.5); M.Tick(.5) end end)
 print('[ANOMALY] Prototype ready / seed 92026')
end
return M
