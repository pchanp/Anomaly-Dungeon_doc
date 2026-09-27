local Players=game:GetService('Players'); local RS=game:GetService('ReplicatedStorage'); local Run=game:GetService('RunService')
local p=Players.LocalPlayer; local state=RS:WaitForChild('AnomalyState')
local gui=Instance.new('ScreenGui'); gui.Name='AnomalyHUD'; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=false; gui.Parent=p:WaitForChild('PlayerGui')
local function label(name,pos,size,text,color)
 local t=Instance.new('TextLabel'); t.Name=name; t.Position=pos; t.Size=size; t.BackgroundColor3=Color3.fromRGB(12,18,27); t.BackgroundTransparency=.12; t.BorderSizePixel=0; t.TextColor3=color or Color3.fromRGB(219,233,239); t.Font=Enum.Font.GothamMedium; t.TextSize=16; t.TextWrapped=true; t.Text=text; t.Parent=gui
 local c=Instance.new('UICorner'); c.CornerRadius=UDim.new(0,8); c.Parent=t; return t
end
label('Title',UDim2.new(0,18,0,14),UDim2.new(0,310,0,38),'CLOSED STACKS / FIELD TEST 02',Color3.fromRGB(78,221,217))
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
 local lifetime=p:GetAttribute('RunLifetimeRemaining') or 0; local lifetimeText=p:GetAttribute('RunLifetimeTicks') and string.format(' | 残り %d秒',math.ceil(lifetime)) or ''
 status.Text=string.format('HP  %d / 100\n%s%s  |  %s',hp,anomaly and '未認識' or '正常',lifetimeText,p:GetAttribute('Room') or 'LOBBY')
 status.TextColor3=anomaly and Color3.fromRGB(195,150,255) or Color3.fromRGB(219,233,239)
 objective.Text=p:GetAttribute('InDungeon') and (anomaly and '目的：VHS売場の境界から出口ポータルへ\nRun Lifetime終了までに帰還してください' or '目的：マップ条件を満たし出口ポータルから帰還\n泉は1人で回復 / 観測体の近くは危険') or '中央の端末で探索開始 / E または画面の操作表示\n全員帰還後、右の端末で棚を再配置\n出口はマップ条件の達成後に利用可能'
 boss.Visible=(state:GetAttribute('BossUntil') or 0)>workspace:GetServerTimeNow(); boss.Text='BOSS ?   '..(state:GetAttribute('BossName') or '')..'\n━━━━━━━━━━━━━━━━━━━━\n演出のみ / 戦闘は発生しません'
end)
