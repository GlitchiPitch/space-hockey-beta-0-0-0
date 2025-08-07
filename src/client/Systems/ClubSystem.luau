local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local ClubSystem = {}

-- ===================== Private ===================== --
local _logger, _remotes, _uiService

local function receiveClubsMember(clubsMember: { [string]: { number } })
    _uiService._guiModules.clubsGui:UpdateClubsMember(clubsMember)
end

local function receiveClubsRating(clubsRating: { [string]: number })
    _uiService._guiModules.clubsGui:UpdateClubsRating(clubsRating)
end

local function connectToDataRemoteEvent()
    local callbacks = {
        [_remotes.actions.dataRemoteEvent.fromServer.receiveClubsMember] = receiveClubsMember,
        [_remotes.actions.dataRemoteEvent.fromServer.receiveClubsRating] = receiveClubsRating,
    }
    _remotes:SubscribeDataRemoteEvent(script.Name, callbacks)
end

-- ===================== API ===================== --
function ClubSystem:Initialize(ClientBootstrap: Types.ClientBootstrapType)
    _remotes = ClientBootstrap._remotes
    _uiService = ClientBootstrap._services.uiService
end

function ClubSystem:Setup()
    connectToDataRemoteEvent()
end

return ClubSystem