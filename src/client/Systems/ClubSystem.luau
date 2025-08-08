local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local ClubSystem = {}

-- ===================== Private ===================== --
local _logger, _remotes, _uiService

local function receiveClubMembers(data: Types.receiveClubMembersType)
	_uiService._guiModules.clubsGui:UpdateClubMembers(data)
end

local function receiveClubRating(data: Types.receiveClubRatingType)
	_uiService._guiModules.clubsGui:UpdateClubRating(data)
end

local function connectToDataRemoteEvent()
	local callbacks = {
		[_remotes.actions.dataRemoteEvent.fromServer.receiveClubMembers] = receiveClubMembers,
		[_remotes.actions.dataRemoteEvent.fromServer.receiveClubRating] = receiveClubRating,
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
