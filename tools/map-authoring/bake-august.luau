-- Studio Command Bar / Edit専用。既存モデルがあれば上書きせず停止する。
assert(not game:GetService('RunService'):IsRunning(),'Stop Play before baking')
local folder=workspace:FindFirstChild('MapAuthoring')
if not folder then folder=Instance.new('Folder');folder.Name='MapAuthoring';folder.Parent=workspace end
assert(not folder:FindFirstChild('AUGUST_31'),'Authored map exists; do not overwrite edits')
local maps=game.ServerScriptService.AnomalyDungeonServer.Maps
local world=require(maps.August.AugustGenerator).Build(8312026,folder)
local root=require(maps.Authoring.AuthoredAugustMap).Bake(world,folder)
game:GetService('Selection'):Set({root})
print('Authored map:',root:GetFullName())
