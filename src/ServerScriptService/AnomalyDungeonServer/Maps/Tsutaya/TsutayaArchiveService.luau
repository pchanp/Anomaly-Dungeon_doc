-- TSUTAYA archive: media index, CRT channels, listening stations.
-- Server authoritative. Clients only request a shelf query or report a chosen label.
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local Workspace=game:GetService("Workspace")
local Config=require(RS.AnomalyDungeon.Shared.Config.TsutayaConfig)
local Remotes=RS.AnomalyDungeon.Shared.TsutayaShared:WaitForChild("Remotes")
local OpenArchive=Remotes:WaitForChild("OpenArchive")
local ChooseArchive=Remotes:WaitForChild("ChooseArchive")
local CloseArchive=Remotes:WaitForChild("CloseArchive")
local Notice=RS:WaitForChild("AnomalyNotice")

local Service={}
local connections={}
local world
local rng=Random.new()

-- Placeholder archive entries. They intentionally read as works that were never released.
local TITLES={
	VHS={"上映記録の無い店内ショー CASE 01","返却期限切れの CM テープ","実写ではない店内で撮影された footage","棚の映像 A / 06:14 二重録音","会員限定告知（非公開）","閉店前夜 最終回 生放送","盤面に映る人物列","解放されていない 90分の拷贝","店内の音を先に録音した盘子"},
	DVD={"発売中止のセル版","字幕の無いナビゲーション","未記録の前編仕様","監督名の読み仮名が判読できない","劇場上映の更なる版","Bonus: 施工现场 撮影","仕様書に記載のない特典","地図に無い Bonus 映像","複製的前提官吏の映像"},
	CD={"試聴盤面 03 / 再生不可","タイアップ先不明","売上記録が途中のマスター","未発表 Promo","逆再生が混じる Bonus track","ライブ盤 / 収録地撮影","盤面留下的注释","順序を入れ替えでのみ再生可","到達しない,但你听见了"},
	TAPE={"資料名の無い口述","消去済み領域に残った声","60分満了前に尽きた記録","複製機3段目の出力","相互参照用の逆向きテープ","現存しない放送の予備テープ"},
}
local CRT_CHANNELS={"店内案内 / CLOSED","深夜帯の CM","在庫管理（無人）","ケーブル再調整","放送終了後の白黒","読み込み中の記録"}

local function tell(player,text) Notice:FireClient(player,text) end

local function bindPrompt(prompt,fn)
	table.insert(connections,prompt.Triggered:Connect(function(player)
		local char=player.Character
		local root=char and char:FindFirstChild("HumanoidRootPart")
		local hum=char and char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health<=0 then return end
		if (root.Position-prompt.Parent.Position).Magnitude>14 then return end
		fn(player,prompt)
	end))
end

-- Archive shelves -------------------------------------------------------

local function shelfEntries(shelf)
	-- Deterministic per shelf: a selection must stay valid after the query that offered it.
	local cached=shelf.Cache
	if cached then return cached end
	local pool=TITLES[shelf.Kind] or TITLES.VHS
	local limit=(Config.MaxEntriesPerShelf and Config.MaxEntriesPerShelf[shelf.Kind]) or #pool
	local out={}
	-- Coverage hides entries so one query never reveals the whole archive.
	for index=1,#pool do
		if rng:NextNumber()<=Config.ShelfCoverage then
			table.insert(out,{Label=pool[index],Kind=shelf.Kind})
		end
	end
	table.sort(out,function(a,b) return a.Label<b.Label end)
	while #out>limit do table.remove(out) end
	shelf.Cache=out
	return out
end

function Service.QueryShelf(player,shelfName)
	if not world then return end
	local shelf=world.Shelves[shelfName]
	if not shelf then return end
	if not player:GetAttribute("InDungeon") then
		tell(player,"棚は探索中にのみ調べられる。")
		return
	end
	OpenArchive:FireClient(player,{Shelf=shelf.Label,Entries=shelfEntries(shelf)})
end

local function applyShelfResult(player,shelf,label)
	if shelf.Kind=="VHS" then
		-- A store-cam tape reports an aisle layout it was never filmed in.
		shelf.Part:SetAttribute("LastEntry",label)
		local route=world.Root and world.Root:GetAttribute("Route") or "-"
		tell(player,"棚の映像を取得した / "..label.."\nこの映像に映る経路: "..route)
	elseif shelf.Kind=="CD" then
		shelf.Part:SetAttribute("LastEntry",label)
		tell(player,"CD規格外の項目を選択した / "..label)
	else
		shelf.Part:SetAttribute("LastEntry",label)
		tell(player,"登録のないメディアを選択した / "..label)
	end
end

ChooseArchive.OnServerEvent:Connect(function(player,shelfName,label)
	if type(shelfName)~="string" or type(label)~="string" then return end
	if not world then return end
	local shelf=world.Shelves[shelfName]
	if not shelf then return end
	-- Only accept labels this shelf actually offered on the current query.
	local ok=false
	for _,entry in ipairs(shelfEntries(shelf)) do
		if entry.Label==label then ok=true break end
	end
	if not ok then return end
	if not player:GetAttribute("InDungeon") then return end
	applyShelfResult(player,shelf,label)
end)

CloseArchive.OnServerEvent:Connect(function() end)

-- CRT -------------------------------------------------------------------

local function applyChannel(crt,channel)
	local screen=crt:FindFirstChild("Screen")
	if not screen then return end
	local label=screen:FindFirstChildWhichIsA("SurfaceGui") and screen:FindFirstChildWhichIsA("SurfaceGui"):FindFirstChildWhichIsA("TextLabel")
	local dead=channel==0 or channel==Config.CrtChannelCount-1
	if label then
		label.Text=CRT_CHANNELS[channel] or "?"
		label.TextColor3=dead and Color3.fromRGB(190,200,206) or Color3.fromRGB(120,240,220)
	end
	screen.Color=dead and Color3.fromRGB(28,30,34) or Color3.fromRGB(46,60,58)
	crt:SetAttribute("Channel",channel)
	local tone=crt:FindFirstChild("StaticTone")
	if tone then
		tone.SoundId=dead and Config.CrtStaticToneId or Config.CrtNoiseId
	end
end

local function crtTune(crt)
	local channel=crt:GetAttribute("Channel") or 0
	local spinner=crt:FindFirstChild("Spinner")
	if spinner then spinner.Transparency=1 end
	-- A channel change passes through dead air before the picture resolves.
	task.delay(Config.CrtChannelSwitchDelay,function()
		if not crt.Parent then return end
		applyChannel(crt,(channel+1)%Config.CrtChannelCount)
		if spinner then spinner.Transparency=.25 end
	end)
end

function Service.AttachCrt(model)
	applyChannel(model,0)
	local prompt=model:FindFirstChildWhichIsA("ProximityPrompt",true)
	if prompt then bindPrompt(prompt,function() crtTune(model) end) end
	if world then table.insert(world.Crts,model) end
	return model
end

-- Listening stations ----------------------------------------------------

function Service.SetSharedBgm(soundId)
	if not world then return end
	if world.Bgm then
		world.Bgm.SoundId=soundId or Config.SharedBgmId
		world.Bgm.Volume=Config.SharedBgmVolume
	end
end

function Service.AttachStation(model,trackId)
	if world then table.insert(world.Stations,model) end
	local unit=model:FindFirstChild("Unit") or model
	local preview=Instance.new("Sound")
	preview.Name="Preview"
	preview.SoundId=Config.PreviewId or Config.SharedBgmId
	preview.Volume=Config.PreviewVolume
	-- The unit Part does not carry the sound, so audibility needs its own range.
	preview.RollOffMaxDistance=Config.PreviewRange
	preview.Looped=true
	preview.Parent=unit
	local prompt=model:FindFirstChildWhichIsA("ProximityPrompt",true)
	if prompt then
		bindPrompt(prompt,function(player)
			if not player:GetAttribute("InDungeon") then
				tell(player,"試聴は探索中にのみ利用できる。")
				return
			end
			-- A personal preview never changes the shared broadcast.
			preview:Stop()
			preview:Play()
			player:SetAttribute("ListeningTrack",model:GetAttribute("Track"))
			player:SetAttribute("ListeningUntil",workspace:GetServerTimeNow()+Config.PreviewDuration)
			tell(player,"試聴中 / "..tostring(model:GetAttribute("Track")))
			-- A preview ends on its own; it is not the shared broadcast.
			task.delay(Config.PreviewDuration,function() preview:Stop() end)
		end)
	end
	return model
end

-- Safe to call repeatedly: only the first bind for a given world takes effect.
function Service.Bind(targetWorld)
	if world==targetWorld then return end
	world=targetWorld
	world.Shelves=world.Shelves or {}
	world.Crts=world.Crts or {}
	world.Stations=world.Stations or {}
end

-- Drops prompt handlers for the map that is going away. Build() rebinds afterwards.
function Service.Unbind()
	for _,c in ipairs(connections) do c:Disconnect() end
	connections={}
	if world and world.Shelves then
		for _,shelf in pairs(world.Shelves) do shelf.Cache=nil end
	end
	world=nil
end

return Service
