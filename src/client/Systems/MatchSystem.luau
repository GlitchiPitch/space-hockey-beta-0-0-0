local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local MatchSystem = {}

-- ===================== Private ===================== --
local _remotes, _logger, _dataSystem, config, _uiService, settings, _controllers
local _gamePlayerData: Types.GamePlayerDataType
local _gameData: Types.GameDataType

local function updatePlayerGameData(gamePlayerData: Types.GamePlayerDataType)
	_gamePlayerData = gamePlayerData
end

local function updateGameData(gameData: Types.GameDataType)
    _gameData = gameData
    _uiService._guiModules.gameGui:UpdateGameData(_gameData)
end

local function updateRoundCount(_roundCount: number)
    _uiService._guiModules.gameGui:UpdateRoundCount(_roundCount)
end

local function updateRoundTimer(_time: number)
    _uiService._guiModules.gameGui:UpdateRoundTimer(_time)
end

local function updateIntermissionTimer(_time: number)
    _uiService._guiModules.gameGui:UpdateIntermissionTimer(_time)
end

local function subscribeMatchRemoteEvent()
	local callbacks = {
		[_remotes.actions.matchRemoteEvent.fromServer.updatePlayerGameData] = updatePlayerGameData,
        [_remotes.actions.matchRemoteEvent.fromServer.updateRoundCount] = updateRoundCount,
        [_remotes.actions.matchRemoteEvent.fromServer.updateRoundTimer] = updateRoundTimer,
		[_remotes.actions.matchRemoteEvent.fromServer.updateGameData] = updateGameData,
        [_remotes.actions.matchRemoteEvent.fromServer.updateIntermissionTimer] = updateIntermissionTimer,
	}
	_remotes:SubscribeMatchRemoteEvent(script.Name, callbacks)
end


local function startMatch()
    local playerData = _dataSystem:GetPlayerData()
	_gamePlayerData = {
		shootingCooldown = config.shootingCooldownLevels[playerData.Stats.ShootingCooldown.level]
			or config.shootingCooldownLevels[1],
		stickCharge = config.stickChargeLevels[playerData.Stats.StickCharge.level] or config.stickChargeLevels[1],
		shootingScore = 0,
		sprint = false,
		goals = 0,
		score = 0,
	}

    _controllers.flyingController:Track()
    _controllers.shootingController:Track()
    _uiService:SetCurrentGui().gameGui()
    subscribeMatchRemoteEvent()
end

local function finishMatch(finalData: Types.FinalDataType)
    local gameResultIsOpened = false
    local finalClosed = false

    _uiService:SetCurrentGui().finalGui()
    _uiService._guiModules.finalGui:SetFinal(finalData)

    for i = 1, settings.UI.gameResultDelay do
        if gameResultIsOpened then
            break
        else
            task.wait(1)
        end
    end

    for i = 1, settings.UI.closeFinalDelay do
        if finalClosed then
            break
        else
            task.wait(1)
        end
    end
end

local function subscribeServeRemoteEvent()
    local callbacks = {
        [_remotes.actions.matchRemoteEvent.fromServer.finishMatch] = finishMatch,
        [_remotes.actions.matchRemoteEvent.fromServer.startMatch] = startMatch,
	}
	_remotes:SubscribeServeRemoteEvent(script.Name, callbacks)
end

function MatchSystem:Initialize(ClientBootstrap: Types.ClientBootstrapType)
	_remotes = ClientBootstrap._remotes
	_dataSystem = ClientBootstrap._systems.dataSystem
    _uiService = ClientBootstrap._services.uiService
    _controllers = ClientBootstrap._controllers
	config = ClientBootstrap.config
    settings = ClientBootstrap.settings
end

function MatchSystem:Setup()
	subscribeServeRemoteEvent()
end

-- ===================== API ===================== --


return MatchSystem
