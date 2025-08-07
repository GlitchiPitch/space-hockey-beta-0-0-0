local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local DataSytem = {}

-- ===================== Private ===================== --
local _remotes, _playerData

local function getPlayerData(playerData: Types.PlayerDataType)
    _playerData = playerData
end

local function subscribeDataRemoteEvent()
    local callbacks = {
        [_remotes.actions.dataRemoteEvent.fromServer.receiveData] = getPlayerData,
    }
    _remotes:SubscribeDataRemoteEvent(script.Name, callbacks)
end

function DataSytem:Initialize(ClientBootstrap: Types.ClientBootstrapType)
    _remotes = ClientBootstrap._remotes
end

function DataSytem:Setup()
    subscribeDataRemoteEvent()
end

-- ===================== API ===================== --
function DataSytem:GetPlayerData(): Types.PlayerDataType
    return _playerData
end

return DataSytem