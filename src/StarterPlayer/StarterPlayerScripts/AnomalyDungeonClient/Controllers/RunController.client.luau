local Players=game:GetService('Players'); local RS=game:GetService('ReplicatedStorage'); local Run=game:GetService('RunService')
local p=Players.LocalPlayer; local state=RS:WaitForChild('AnomalyState')
local LobbyPartyMax=require(RS.AnomalyDungeon.Shared.Config.LobbyConfig).PartyMax
local gui=Instance.new('ScreenGui'); gui.Name='AnomalyHUD'; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=p:WaitForChild('PlayerGui')
local function label(name,pos,size,text,color)
 local t=Instance.new('TextLabel'); t.Name=name; t.Position=pos; t.Size=size; t.BackgroundColor3=Color3.fromRGB(12,18,27); t.BackgroundTransparency=.12; t.BorderSizePixel=0; t.TextColor3=color or Color3.fromRGB(219,233,239); t.Font=Enum.Font.GothamMedium; t.TextSize=16; t.TextWrapped=true; t.Text=text; t.Parent=gui
 local c=Instance.new('UICorner'); c.CornerRadius=UDim.new(0,8); c.Parent=t; return t
end
label('Title',UDim2.new(0,18,0,14),UDim2.new(0,310,0,38),'ANOMALY DUNGEON / FIELD TEST',Color3.fromRGB(78,221,217))
local status=label('Status',UDim2.new(0,18,0,60),UDim2.new(0,310,0,86),'')
local objective=label('Objective',UDim2.new(0,18,1,-113),UDim2.new(0,390,0,92),'')
local toast=label('Notice',UDim2.new(.5,-225,1,-180),UDim2.new(0,450,0,58),''); toast.Visible=false
local boss=label('Boss',UDim2.new(.5,-210,0,20),UDim2.new(0,420,0,62),'',Color3.fromRGB(246,185,87)); boss.Visible=false
local stamp=0
RS:WaitForChild('AnomalyNotice').OnClientEvent:Connect(function(t) stamp+=1; local n=stamp; toast.Text=t; toast.Visible=true; task.delay(5,function() if n==stamp then toast.Visible=false end end) end)
local elapsed=0
Run.Heartbeat:Connect(function(dt)
 elapsed+=dt; if elapsed<.15 then return end; elapsed=0
 local h=p.Character and p.Character:FindFirstChildOfClass('Humanoid'); local hp=h and math.ceil(h.Health) or 0; local anomaly=p:GetAttribute('PlayerAnomalyState')=='TRANSFORMED'
 local resultPending=p:GetAttribute('RunResultPending')==true
 local lifetime=p:GetAttribute('RunLifetimeRemaining') or 0; local lifetimeText=p:GetAttribute('RunLifetimeTicks') and string.format(' | 残り %d秒',math.ceil(lifetime)) or ''
 status.Text=string.format('HP  %d / 100\n%s%s  |  %s',hp,anomaly and '未認識' or '正常',lifetimeText,resultPending and 'RESULT' or (p:GetAttribute('Room') or 'LOBBY'))
 status.TextColor3=anomaly and Color3.fromRGB(195,150,255) or Color3.fromRGB(219,233,239)
 local exitUnlocked=state:GetAttribute('ExitUnlocked')==true
 local mapName=state:GetAttribute('MapDisplayName') or 'DUNGEON'
 local lobbyState=p:GetAttribute('LobbyState') or 'CITY'
 if resultPending then
  objective.Text='リザルト画面を確認しています\n「都市ロビーへ戻る」でロビーへ戻ります'
 elseif p:GetAttribute('InDungeon') then
  objective.Text=exitUnlocked and '目的：起動した出口ポータルから帰還\n通常・異常状態とも利用可能' or '目的：出口制御端末を操作して帰還経路を開く\n出口ポータルはまだ停止中'
 elseif lobbyState=='ENTRANCE' then
  objective.Text=string.format('入口ロビー / 参加 %d・%d 人\nパーティ用フィールドへ入ると受付開始',state:GetAttribute('PartyCount') or 0,LobbyPartyMax)
 elseif lobbyState=='PARTY' then
  objective.Text='パーティ受付中\nフィールド内に留まってください'
 elseif lobbyState=='RUNNING' then
  objective.Text='探索中です / '..mapName
 else
  objective.Text='都市ロビー\n「DUNGEON ENTRANCE」で入口ロビーへ移動します'
 end
 boss.Visible=(state:GetAttribute('BossUntil') or 0)>workspace:GetServerTimeNow(); boss.Text='BOSS ?   '..(state:GetAttribute('BossName') or '')..'\n━━━━━━━━━━━━━━━━━━━━\n演出のみ / 戦闘は発生しません'
end)
