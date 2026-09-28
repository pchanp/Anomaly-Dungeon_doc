local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Map=require(script.Parent.Parent.Maps.Generators.MapGenerator)
local Exposure=require(script.Parent.ExposureService)
local RunConfig=require(game:GetService('ReplicatedStorage').AnomalyDungeon.Shared.Config.RunConfig)
local MapDefinitions=require(RS.AnomalyDungeon.Shared.Definitions.MapDefinitions)
local M={}; local world; local last={}; local connections={}
local state=RS:WaitForChild('AnomalyState'); local notice=RS:WaitForChild('AnomalyNotice')
local function tell(p,t) notice:FireClient(p,t) end
local function body(p) local c=p.Character; return c and c:FindFirstChild('HumanoidRootPart'),c and c:FindFirstChildOfClass('Humanoid') end
local function teleport(p,pos) if p.Character then p.Character:PivotTo(CFrame.new(pos)) end end
function M.SetExposure(p,value) return Exposure.Set(p,value) end
function M.Reset(p,nextState)
 Exposure.Reset(p); p:SetAttribute('InDungeon',false); p:SetAttribute('Room','LOBBY'); p:SetAttribute('PlayerRunState',nextState or RunConfig.PlayerRunLobby)
end
function M.Enter(p)
 local _,h=body(p); if not h or h.Health<=0 or p:GetAttribute('InDungeon') then return end
 M.Reset(p,RunConfig.PlayerRunExploring); p:SetAttribute('QuestState','ACTIVE'); p:SetAttribute('QuestObjective','出口制御端末を起動する'); p:SetAttribute('InDungeon',true); h.Health=h.MaxHealth; teleport(p,world.Entry); tell(p,'マップ条件を満たし、出口ポータルから帰還してください。危険なら入口からも帰還できます。')
end
function M.Extract(p,force)
 if not p:GetAttribute('InDungeon') then return false end
 if not force and not state:GetAttribute('ExitUnlocked') then tell(p,'出口ポータルはまだ起動していません。指定端末を探してください。'); return false end
 local completed=p:GetAttribute('QuestState')=='COMPLETED'
 M.Reset(p,RunConfig.PlayerRunReturned); teleport(p,world.Lobby); local _,h=body(p); if h then h.Health=h.MaxHealth end
 if completed then p:SetAttribute('Credits',(p:GetAttribute('Credits') or 0)+RunConfig.QuestRewardCredits); p:SetAttribute('QuestState','REWARDED'); p:SetAttribute('QuestObjective','依頼完了'); tell(p,'帰還成功 / 報酬 '..RunConfig.QuestRewardCredits..' Credits') else p:SetAttribute('QuestState','FAILED'); p:SetAttribute('QuestObjective','依頼未達成'); tell(p,'帰還成功 / 報酬なし') end; return true
end
local function bind(q,fn)
 table.insert(connections,q.Triggered:Connect(function(p)
  local r,h=body(p); if not r or not h or h.Health<=0 or (r.Position-q.Parent.Position).Magnitude>13 then return end
  local now=os.clock(); if now-(last[p] or 0)<.4 then return end; last[p]=now; fn(p)
 end))
end
function M.Build(seed)
 for _,c in connections do c:Disconnect() end; connections={}
 world=Map.Build(seed); local mapDef=MapDefinitions.CLOSED_STACKS; state:SetAttribute('Seed',seed); state:SetAttribute('Route',world.Root:GetAttribute('Route')); state:SetAttribute('MapId',mapDef.Id); state:SetAttribute('ExitUnlocked',false)
 local function setExitUnlocked(unlocked)
  state:SetAttribute('ExitUnlocked',unlocked)
  for _,name in {'Return','Extract','AnomalyExit'} do local q=world.Prompts[name]; q.Enabled=unlocked; q.Parent.Transparency=unlocked and 0 or 1; q.Parent.CanCollide=unlocked; q.Parent.Sign.Enabled=unlocked end
 end
 setExitUnlocked(false)
 bind(world.Prompts.Enter,M.Enter)
 bind(world.Prompts[mapDef.ExitCondition.PromptName],function(p) if not p:GetAttribute('InDungeon') then return end; if state:GetAttribute('ExitUnlocked') then tell(p,'出口ポータルは既に起動しています'); return end; setExitUnlocked(true); for _,v in Players:GetPlayers() do if v:GetAttribute('InDungeon') then v:SetAttribute('QuestState','COMPLETED'); v:SetAttribute('QuestObjective','出口ポータルから帰還する'); tell(v,p.DisplayName..' が出口ポータルを起動しました') end end end)
 bind(world.Prompts.Reroll,function(p)
  for _,v in Players:GetPlayers() do if v:GetAttribute('InDungeon') then tell(p,'探索中のプレイヤーがいます。全員帰還してから再構成してください。'); return end end
  M.Build(Random.new():NextInteger(1000,99999)); for _,v in Players:GetPlayers() do teleport(v,world.Lobby) end
 end)
 for _,name in {'Return','Extract','AnomalyExit'} do bind(world.Prompts[name],function(p) M.Extract(p,false) end) end
 bind(world.Prompts.Secret,function(p)
  if p:GetAttribute('InDungeon') and Exposure.IsTransformed(p) then teleport(p,world.SecretSpawn) else tell(p,'ただの壁だ。今のあなたには何も見えない。') end
 end)
 bind(world.Prompts.Boss,function(p) if p:GetAttribute('InDungeon') then state:SetAttribute('BossName',p.DisplayName); state:SetAttribute('BossUntil',workspace:GetServerTimeNow()+8) end end)
end
function M.PoolEffect(count) return count>=2 and -8*(count-1) or (count==1 and 6 or 0) end
function M.Tick(dt)
 local occupants={}
 for _,p in Players:GetPlayers() do
  local r,h=body(p)
  if r and h and h.Health>0 and p:GetAttribute('InDungeon') then
   local delta=r.Position-world.Pool.Position
   if math.abs(delta.X)<=9 and math.abs(delta.Z)<=9 and math.abs(delta.Y)<6 then table.insert(occupants,p) end
   if (r.Position-world.Observer.Position).Magnitude<17 then Exposure.Add(p,RunConfig.ObserverExposurePerSecond*dt) end
   local roomName='CORRIDOR'; for _,room in world.Rooms do local d=r.Position-room.Center; if math.abs(d.X)<room.Width/2 and math.abs(d.Z)<room.Depth/2 and math.abs(d.Y)<room.Height then roomName=room.DisplayName end end
   p:SetAttribute('Room',roomName)
   if p:GetAttribute('RunLifetimeTicks') then
    local remaining=math.max(0,(p:GetAttribute('RunLifetimeRemaining') or RunConfig.TransformedLifetimeSeconds)-dt); p:SetAttribute('RunLifetimeRemaining',remaining)
    if remaining<=0 then M.Extract(p,true); tell(p,'Run Lifetime終了 / 強制帰還しました') end
   end
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
  p:SetAttribute('Credits',p:GetAttribute('Credits') or 0); p:SetAttribute('QuestState','NONE'); p:SetAttribute('QuestObjective','依頼を受ける'); M.Reset(p)
  local function character(c)
   M.Reset(p); local h=c:WaitForChild('Humanoid'); h.WalkSpeed=20; task.defer(function() teleport(p,world.Lobby) end)
   h.Died:Connect(function() M.Reset(p,RunConfig.PlayerRunDead); p:SetAttribute('QuestState','FAILED'); p:SetAttribute('QuestObjective','探索失敗'); tell(p,'探索失敗 / 報酬なし') end)
  end
  p.CharacterAdded:Connect(character); if p.Character then task.spawn(character,p.Character) end
 end
 Players.PlayerAdded:Connect(player); for _,p in Players:GetPlayers() do player(p) end
 Players.PlayerRemoving:Connect(function(p) Exposure.Release(p); last[p]=nil end)
 task.spawn(function() while true do task.wait(.5); M.Tick(.5) end end)
 print('[ANOMALY] Prototype ready / seed 92026')
end
return M
