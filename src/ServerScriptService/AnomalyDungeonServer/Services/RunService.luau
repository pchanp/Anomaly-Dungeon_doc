local Players=game:GetService('Players')
local RS=game:GetService('ReplicatedStorage')
local Map=require(script.Parent.Parent.Maps.Generators.MapGenerator)
local MapGenerators={CLOSED_STACKS=Map}
local Exposure=require(script.Parent.ExposureService)
local RunConfig=require(game:GetService('ReplicatedStorage').AnomalyDungeon.Shared.Config.RunConfig)
local MapDefinitions=require(RS.AnomalyDungeon.Shared.Definitions.MapDefinitions)
local RunOutcomes=require(RS.AnomalyDungeon.Shared.Definitions.RunOutcomes)
local TsutayaGenerator=require(script.Parent.Parent.Maps.Tsutaya.TsutayaGenerator)
local Archive=require(script.Parent.Parent.Maps.Tsutaya.TsutayaArchiveService)
MapGenerators.TSUTAYA=TsutayaGenerator
local AugustGenerator=require(script.Parent.Parent.Maps.August.AugustGenerator)
local August=require(script.Parent.Parent.Maps.August.August31Service)
MapGenerators.AUGUST_31=AugustGenerator
local Inventory=require(script.Parent.InventoryService)
local M={}; local world; local last={}; local connections={}
local state=RS:WaitForChild('AnomalyState'); local notice=RS:WaitForChild('AnomalyNotice')
-- 結果送信用のRemote。プレースに未配置でも playable になるように、無ければ生成する。
local runRemotes=RS:FindFirstChild('AnomalyRunRemotes')
if not runRemotes then runRemotes=Instance.new('Folder'); runRemotes.Name='AnomalyRunRemotes'; runRemotes.Parent=RS end
local function remoteOf(name) local r=runRemotes:FindFirstChild(name); if not r then r=Instance.new('RemoteEvent'); r.Name=name; r.Parent=runRemotes end return r end
local resultRemote=remoteOf('Result'); local resultRequest=remoteOf('ResultRequest')
-- Runの状態機械。都市ロビー、入口ロビー、Party受付中、出発、探索中、個人リザルト、終了待機を明示的に持つ。
local runState=RunConfig.RunStateIdle
local party={}
local active=setmetatable({}, {__mode='k'})
local roster=setmetatable({}, {__mode='k'})
local runMapId
local lobby, Party
local function tell(p,t) notice:FireClient(p,t) end
local function body(p) local c=p.Character; return c and c:FindFirstChild('HumanoidRootPart'),c and c:FindFirstChildOfClass('Humanoid') end
local function teleport(p,pos) if p.Character then p.Character:PivotTo(CFrame.new(pos)) end end
local function setLobbyState(p,s) p:SetAttribute('LobbyState',s) end
function M.Tell(p,t) tell(p,t) end
function M.SetExposure(p,value) return Exposure.Set(p,value) end
function M.SetRunState(next) runState=next; state:SetAttribute('RunState',next) end
function M.GetRunState() return runState end
function M.SetLobbyState(p,s) setLobbyState(p,s) end
function M.Reset(p,nextState)
 Exposure.Reset(p); p:SetAttribute('InDungeon',false); p:SetAttribute('Room','LOBBY'); p:SetAttribute('PlayerRunState',nextState or RunConfig.PlayerRunLobby)
end
-- Enters the generated dungeon. Only the party that already departed may pass: the entrance
-- reception owns entry, so a direct prompt can no longer bypass the field and the deadline.
function M.Enter(p)
 local _,h=body(p); if not h or h.Health<=0 or p:GetAttribute('InDungeon') or not active[p] then return end
 M.Reset(p,RunConfig.PlayerRunExploring); p:SetAttribute('QuestState','ACTIVE'); p:SetAttribute('QuestObjective',MapDefinitions[M.MapId].QuestObjective or '出口制御端末を起動する'); p:SetAttribute('InDungeon',true); h.Health=h.MaxHealth; teleport(p,world.Entry); tell(p,'マップ条件を満たし、出口ポータルから帰還してください。危険なら入口からも帰還できます。')
end
local function dropFromParty(p)
 active[p]=nil; roster[p]=nil
 for index,other in ipairs(party) do if other==p then table.remove(party,index) break end end
end
-- Single end of run. Success, optional return without the quest, death, disconnect, 8/32 lifetime
-- expiry and transformed timeout all arrive here, and the result screen only ever shows what
-- this function decided. offline skips the teleport and the remote for a leaving player.
function M.Finish(p,outcomeKey,offline)
 if not p:GetAttribute('InDungeon') then return false end
 local outcome=RunOutcomes[outcomeKey] or RunOutcomes.DEATH
 local success=outcome.Success==true
 local entry=roster[p]
 local objective=(entry and entry.Objective) or p:GetAttribute('QuestObjective') or ''
 local gained,lost=Inventory.Settle(p,success)
 local mapId=entry and entry.MapId or runMapId
 local creditsBefore=p:GetAttribute('Credits') or 0
 local creditsDelta=success and RunConfig.QuestRewardCredits or 0
 p:SetAttribute('Credits',creditsBefore+creditsDelta)
 p:SetAttribute('QuestState',success and 'REWARDED' or 'FAILED')
 p:SetAttribute('QuestObjective',success and '依頼完了' or '依頼未達成')
 p:SetAttribute('RunResultOutcome',outcome.Id)
 p:SetAttribute('RunResultPending',not offline)
 dropFromParty(p)
 M.Reset(p,outcome.Id==RunOutcomes.DEATH.Id and RunConfig.PlayerRunDead or RunConfig.PlayerRunReturned)
 setLobbyState(p,RunConfig.LobbyResult)
 if not offline then
  local _,h=body(p)
  if h and h.Health>0 then h.Health=h.MaxHealth; if lobby then lobby.Teleport(p,'Result') end end
  resultRemote:FireClient(p,{Outcome=outcome.Id,OutcomeLabel=outcome.Label,Success=success,
   MapId=mapId,MapDisplayName=MapDefinitions[mapId] and MapDefinitions[mapId].DisplayName or '',
   Quests={{Id='BASIC_QUEST',Objective=objective,State=success and 'COMPLETED' or 'FAILED'}},
   Gained=gained,Lost=lost,CreditsBefore=creditsBefore,CreditsDelta=creditsDelta,CreditsAfter=creditsBefore+creditsDelta,
   InventoryUsed=p:GetAttribute('InventoryUsed') or #gained,InventoryCapacity=RunConfig.InventorySlots,
   SecureUsed=p:GetAttribute('SecureUsed') or 0,SecureCapacity=p:GetAttribute('SecureSlotCapacity') or RunConfig.SecureSlots})
  tell(p,outcome.Label..(success and (' / 報酬 '..RunConfig.QuestRewardCredits..' Credits') or ' / 報酬なし'))
 end
 if #party==0 then M.CloseRun() end
 return true
end
-- Compatibility entry. A string is an explicit outcome id; the legacy boolean force is mapped
-- to the lifetime failure instead of a rewarded extraction.
function M.Extract(p,outcomeOrForce)
 if not p:GetAttribute('InDungeon') then return false end
 local key=outcomeOrForce
 if type(key)~='string' then
  if outcomeOrForce==true then key=RunOutcomes.LIFETIME_EXPIRED.Id
  else
   if not state:GetAttribute('ExitUnlocked') then tell(p,'出口ポータルはまだ起動していません。指定端末を探してください。'); return false end
   key=(p:GetAttribute('QuestState')=='COMPLETED') and RunOutcomes.SUCCESS.Id or RunOutcomes.RETURN_INCOMPLETE.Id
  end
 end
 return M.Finish(p,key)
end
-- Binds a generated prompt. A map is allowed to leave a surface out, so a missing prompt
-- is skipped instead of indexing nil.
local function bind(q,fn)
 if not q then return end
 table.insert(connections,q.Triggered:Connect(function(p)
  local r,h=body(p); if not r or not h or h.Health<=0 or (r.Position-q.Parent.Position).Magnitude>13 then return end
  local now=os.clock(); if now-(last[p] or 0)<.4 then return end; last[p]=now; fn(p)
 end))
end
-- Selects the generator registered for a map ID. Unknown IDs fall back to CLOSED_STACKS.
function M.SetMap(mapId)
 M.MapId=mapId and MapDefinitions[mapId] and mapId or 'CLOSED_STACKS'
end
function M.GetMapId() return M.MapId end
-- Opens or closes the shared return surfaces. Exposed so a map gimmick service can decide when
-- the way out exists, instead of every map editing the prompts itself.
function M.SetExitUnlocked(unlocked)
 state:SetAttribute('ExitUnlocked',unlocked)
 if not world then return end
 for _,name in {'Return','Extract','AnomalyExit'} do local q=world.Prompts[name]; if not q then continue end; q.Enabled=unlocked; q.Parent.Transparency=unlocked and 0 or 1; q.Parent.CanCollide=unlocked; local sg=q.Parent:FindFirstChild('Sign'); if sg then sg.Enabled=unlocked end end
end
function M.Build(seed,mapId)
 for _,c in connections do c:Disconnect() end; connections={}
 Archive.Unbind(); August.Unbind()
 M.SetMap(mapId or M.MapId)
 local mapDef=MapDefinitions[M.MapId]
 local generator=MapGenerators[M.MapId] or Map
 world=generator.Build(seed); Archive.Bind(world); state:SetAttribute('Seed',seed); state:SetAttribute('RunSeed',seed); state:SetAttribute('Route',world.Root:GetAttribute('Route')); state:SetAttribute('MapId',mapDef.Id); state:SetAttribute('MapDisplayName',mapDef.DisplayName)
 M.SetExitUnlocked(false)
 bind(world.Prompts.Enter,M.Enter)
 bind(world.Prompts[mapDef.ExitCondition.PromptName],function(p) if not p:GetAttribute('InDungeon') then return end; if state:GetAttribute('ExitUnlocked') then tell(p,'出口ポータルは既に起動しています'); return end; M.SetExitUnlocked(true); for _,v in Players:GetPlayers() do if v:GetAttribute('InDungeon') then v:SetAttribute('QuestState','COMPLETED'); v:SetAttribute('QuestObjective','出口ポータルから帰還する'); tell(v,p.DisplayName..' が出口ポータルを起動しました') end end end)
 bind(world.Prompts.Reroll,function(p)
  for _,v in Players:GetPlayers() do if v:GetAttribute('InDungeon') then tell(p,'探索中のプレイヤーがいます。全員帰還してから再構成してください。'); return end end
  M.Build(Random.new():NextInteger(1000,99999)); if lobby then lobby.SendToCity(p) end
 end)
 for _,name in {'Return','Extract','AnomalyExit'} do bind(world.Prompts[name],function(p) M.Extract(p,false) end) end
 bind(world.Prompts.Secret,function(p)
  if p:GetAttribute('InDungeon') and Exposure.IsTransformed(p) then teleport(p,world.SecretSpawn) else tell(p,'ただの壁だ。今のあなたには何も見えない。') end
 end)
 bind(world.Prompts.Boss,function(p) if p:GetAttribute('InDungeon') then state:SetAttribute('BossName',p.DisplayName); state:SetAttribute('BossUntil',workspace:GetServerTimeNow()+8) end end)
 -- The map gimmick service binds last, so it drives the exit surfaces through the wrapper above.
 August.Bind(world,{SetExitUnlocked=M.SetExitUnlocked})
end
-- Departs one confirmed party. The draw already happened, so Build runs exactly once here and
-- each member is moved to world.Entry with a fresh run state.
function M.StartRun(members,mapId,reason)
 local seed=Random.new():NextInteger(1000,99999)
 M.Build(seed,mapId)
 runMapId=mapId
 state:SetAttribute('RunMapId',mapId)
 party={}
 for _,p in ipairs(members) do
  if p.Parent==Players then
   table.insert(party,p); active[p]=true
   local objective=MapDefinitions[mapId].QuestObjective or '依頼を達成する'
   roster[p]={MapId=mapId,Objective=objective}
   Exposure.Reset(p)
   M.Reset(p,RunConfig.PlayerRunExploring)
   p:SetAttribute('QuestState','ACTIVE'); p:SetAttribute('QuestObjective',objective)
   p:SetAttribute('RunResultPending',false); p:SetAttribute('RunResultOutcome',nil)
   p:SetAttribute('InDungeon',true)
   setLobbyState(p,RunConfig.LobbyRunning)
   local _,h=body(p); if h then h.Health=h.MaxHealth end
   teleport(p,world.Entry)
  end
 end
 state:SetAttribute('PartyCount',#party)
 M.SetRunState(RunConfig.RunStateActive)
 for _,p in ipairs(party) do tell(p,string.format('出発 / %s%s',MapDefinitions[mapId].DisplayName,reason=='FORCE_CLOSE' and ' / 強制締切' or '')) end
end
-- Tears the generated world down once the whole party is finished, so the next party starts from
-- a fresh map. The 8月31日 clock and its Lighting borrow go with it.
function M.CloseRun()
 if runState==RunConfig.RunStateClosing then return end
 M.SetRunState(RunConfig.RunStateClosing)
 for _,c in connections do c:Disconnect() end; connections={}
 Archive.Unbind(); August.Unbind()
 if world and world.Root and world.Root.Parent then world.Root:Destroy() end
 world=nil; runMapId=nil
 -- 8/32の残骸を残さない。Aug32Active は次のRunの判定に使われるため必ず落とす。
 M.SetExitUnlocked(false); state:SetAttribute('Aug32Active',nil)
 party={}; active=setmetatable({}, {__mode='k'}); roster=setmetatable({}, {__mode='k'})
 state:SetAttribute('MapId',nil); state:SetAttribute('MapDisplayName',nil)
 state:SetAttribute('RunMapId',nil); state:SetAttribute('RunSeed',nil); state:SetAttribute('PartyCount',0)
 M.SetRunState(RunConfig.RunStateIdle)
 if Party then Party.Reset() end
end
function M.PoolEffect(count) return count>=2 and -8*(count-1) or (count==1 and 6 or 0) end
function M.Tick(dt)
 if not world then return end
 -- Finish は同期で CloseRun を呼び world を nil にする。ループ中は先頭で取った world だけを使い、
 -- 差し替えられていれば泉の更新と August.Tick へ進まない。
 local current=world
 local occupants={}
 local rate=(current.ExposureMultiplier or 1)*RunConfig.ObserverExposurePerSecond
 for _,p in Players:GetPlayers() do
  local r,h=body(p)
  if r and h and h.Health>0 and p:GetAttribute('InDungeon') then
   local delta=r.Position-current.Pool.Position
   if math.abs(delta.X)<=9 and math.abs(delta.Z)<=9 and math.abs(delta.Y)<6 then table.insert(occupants,p) end
   if (r.Position-current.Observer.Position).Magnitude<17 then Exposure.Add(p,rate*dt) end
   local roomName='CORRIDOR'; for _,room in current.Rooms do local d=r.Position-room.Center; if math.abs(d.X)<room.Width/2 and math.abs(d.Z)<room.Depth/2 and math.abs(d.Y)<room.Height then roomName=room.DisplayName end end
   p:SetAttribute('Room',roomName)
   if p:GetAttribute('RunLifetimeTicks') then
    local remaining=math.max(0,(p:GetAttribute('RunLifetimeRemaining') or RunConfig.TransformedLifetimeSeconds)-dt); p:SetAttribute('RunLifetimeRemaining',remaining)
    if remaining<=0 then
     -- 8/32のRun Lifetime満了は死亡扱いの失敗。強制帰還成功ではない。
     if state:GetAttribute('Aug32Active')==true then M.Finish(p,RunOutcomes.LIFETIME_EXPIRED.Id); tell(p,'8/32 Run Lifetime終了 / 帰還できません') else M.Finish(p,RunOutcomes.TRANSFORMED_TIMEOUT.Id); tell(p,'Run Lifetime終了 / 帰還しました') end
    end
   end
   if r.Position.Y<current.KillY then h.Health=0 end
  end
 end
 if world~=current then return end
 local pool=current.Pool
 pool:SetAttribute('Occupants',#occupants); pool.Color=#occupants>=2 and Color3.fromRGB(170,225,65) or Color3.fromRGB(78,221,217)
 local poolSign=pool:FindFirstChild('Sign'); if poolSign and poolSign:FindFirstChild('TextLabel') then poolSign.TextLabel.Text='泉 / '..#occupants..'人 / '..(#occupants>=2 and '毒' or '回復') end
 for _,p in occupants do local _,h=body(p); local delta=M.PoolEffect(#occupants)*dt; if delta<0 then h:TakeDamage(-delta) else h.Health=math.min(h.MaxHealth,h.Health+delta) end end
 August.Tick(dt)
end
function M.GetWorld() return world end
function M.Start()
 local Lobby=require(script.Parent.LobbyService)
 local PartyService=require(script.Parent.PartyService)
 lobby=Lobby; Party=PartyService
 Lobby.Start()
 PartyService.Start(M,Lobby)
 M.SetRunState(RunConfig.RunStateIdle)
 resultRequest.OnServerEvent:Connect(function(p)
  if p:GetAttribute('RunResultPending')~=true then return end
  p:SetAttribute('RunResultPending',false)
  if lobby then lobby.SendToCity(p) end
 end)
 local function player(p)
  p:SetAttribute('Credits',p:GetAttribute('Credits') or 0); p:SetAttribute('QuestState','NONE'); p:SetAttribute('QuestObjective','依頼を受ける')
  p:SetAttribute('RunResultPending',false); p:SetAttribute('RunResultOutcome',nil)
  Inventory.Setup(p); M.Reset(p); setLobbyState(p,RunConfig.LobbyCity)
  if lobby then p.RespawnLocation=lobby.GetCitySpawn() end
  local function character(c)
   M.Reset(p); local h=c:WaitForChild('Humanoid'); h.WalkSpeed=20; task.defer(function() if lobby then lobby.SendToCity(p) end end)
   h.Died:Connect(function() M.Finish(p,RunOutcomes.DEATH.Id) end)
  end
  p.CharacterAdded:Connect(character); if p.Character then task.spawn(character,p.Character) end
 end
 Players.PlayerAdded:Connect(player); for _,p in Players:GetPlayers() do player(p) end
 Players.PlayerRemoving:Connect(function(p)
  Exposure.Release(p); last[p]=nil
  if active[p] then M.Finish(p,RunOutcomes.DISCONNECT.Id,true) end
  Inventory.Release(p)
 end)
 task.spawn(function() while true do task.wait(.5); M.Tick(.5) end end)
 print('[ANOMALY] Prototype ready / city lobby + entrance lobby + party run')
end
return M
