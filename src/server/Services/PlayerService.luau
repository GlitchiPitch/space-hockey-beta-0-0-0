local Players = game:GetService("Players")
local Types = require(script.Parent.Parent.Types)

local PlayerService = {}
local _dataSystem
-- ===================== Private ===================== --
local function onPlayerAdded(player: Player)
    _dataSystem:GetPlayerData(player.UserId)
end

local function onPlayerRemoving(player: Player)
    _dataSystem:PostPlayerData(player.UserId)
end

function PlayerService:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _dataSystem = ServerBootstrap._systems.dataSystem
end

function PlayerService:Setup()
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end



return PlayerService