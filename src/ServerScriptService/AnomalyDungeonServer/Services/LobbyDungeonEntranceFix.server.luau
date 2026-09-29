-- LobbyDungeonEntranceFix は無効化。
-- 生成マップ内 LOBBY/GimmickPoints/Enter のTouch入場は、入口ロビーのパーティ受付を迂回するため
-- 撤去した。入場は LobbyService のパーティ受付と RunService.StartRun だけが認可する。
-- 過去の入場経路を確認したい場合は、RunService.Enter と roster の利用状況を確認する。
local RunService=require(script.Parent.RunService)
print("[LOBBY LINK] disabled / entry is owned by the party reception in Services/LobbyService + PartyService")
