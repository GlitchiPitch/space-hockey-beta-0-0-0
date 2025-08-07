local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local LobbySystem = {}

-- ===================== Private ===================== --
local _logger, _remotes, _uiService, _playerService

local function quitFromPad(data: { padName: string, teamName: Types.TeamsEnum })
	_logger:info(`ты спрыгнул с пэда`)
	_remotes:LobbyRemoteEventFireServer().quitFromPad(data)
	_playerService:SetControl(true)
end

local function prepareToMatch()
	for i = 3, 0, -1 do
		_uiService._guiModules.mainGui:SetPrepareMatchTimer(i)
		task.wait(1)
	end
	
	_remotes:LobbyRemoteEventFireServer().goToMatch()
end

local function setToPad(data: { padName: string, teamName: Types.TeamsEnum })
	_logger:info(`ты сел на пэд`)
	local function lobbyQuitPadCallback()
		quitFromPad(data)
	end

	_uiService._guiModules.mainGui:ShowPadQuitButton(lobbyQuitPadCallback)
	_playerService:SetControl(false)
end

local function subscribeLobbyRemoteEvent()
	local callbacks = {
		[_remotes.actions.lobbyRemoteEvent.fromServer.setToPad] = setToPad,
		[_remotes.actions.lobbyRemoteEvent.fromServer.prepareToMatch] = prepareToMatch,
	}
	_remotes:SubscribeLobbyRemoteEvent(script.Name, callbacks)
end

-- ===================== API ===================== --
function LobbySystem:Initalize(ClientBootstrap: Types.ClientBootstrapType)
	_logger = ClientBootstrap._logger.new(script.Name)
	_uiService = ClientBootstrap._services.uiService
	_playerService = ClientBootstrap._services.playerService
	_remotes = ClientBootstrap._remotes
end

function LobbySystem:Setup()
	subscribeLobbyRemoteEvent()
end

function LobbySystem:GoToPadsZone()
	_remotes:LobbyRemoteEventFireServer().goToPadsZone()
end

return LobbySystem
