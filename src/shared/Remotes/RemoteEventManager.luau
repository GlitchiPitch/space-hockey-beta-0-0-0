local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--[[
    RemoteEventManager - модуль для управления клиент-серверной коммуникацией в Roblox
    Вдохновлено практиками из Unity (NetworkBehaviour, RPC и т.д.)
    
    Основные возможности:
    - Регистрация обработчиков событий на клиенте и сервере
    - Типизированные сообщения
    - Автоматическая очистка соединений
    - Логирование сетевых событий
]]

type CallbacksType = { [string]: (data: any) -> () } | { [string]: (player: Player, data: any) -> () }

local RemoteEventManager = {
	actions = {
		lobbyRemoteEvent = {
			-- client -> server
			fromClient = {
				quitFromPad = "quitFromPad",
				goToPadsZone = "goToPadsZone",
				goToMatch = "goToMatch",
			},
			-- server -> client
			fromServer = {
				setToPad = "setToPad",
			},
		},
		matchRemoteEvent = {
			-- client -> server
			fromClient = {
				playerFly = "playerFly",
				playerSprint = "playerSprint",
				playerShooting = "playerShooting",
			},
			fromServer = {
				updateGameData = "updateGameData",
				updatePlayerGameData = "updatePlayerGameData",
				updateRoundTimer = "updateRoundTimer",
				updateRoundCount = "updateRoundCount",
				updateIntermissionTimer = "updateIntermissionTimer",
				updateTimeOutTimer = "updateTimeOutTimer",
				dropGameTimer = "dropGameTimer",
			},
		},
		serveRemoteEvent = {
			-- server -> client
			fromServer = {
				startMatch = "startMatch",
				finishMatch = "finishMatch",
				disableControl = "disableControl",
				smallNotification = "smallNotification",
			},
		},
		uiRemoteEvent = {},
		dataRemoteEvent = {
			fromClient = {
				getData = "getData",
			},
			fromServer = {
				receiveData = "receiveData",
			},
		},
	},
}

-- ===================== Private ===================== --
local _logger = require(ReplicatedStorage.Shared.Logger).new(script.Name)
local _connections = {} :: { [string]: RBXScriptConnection }
local _instances = {
	matchRemoteEvent = script.Parent.MatchRemoteEvent,
	lobbyRemoteEvent = script.Parent.LobbyRemoteEvent,
	serveRemoteEvent = script.Parent.ServeRemoteEvent,
	uiRemoteEvent = script.Parent.UIRemoteEvent,
	dataRemoteEvent = script.Parent.DataRemoteEvent,
}

local function registerConnect(remoteEvent: RemoteEvent, connectName: string, callbacks: CallbacksType)
	if not _connections[connectName] then
		if RunService:IsServer() then
			local function remoteConnect(player: Player, action: string, data: any)
				if callbacks[action] then
					callbacks[action](player, data)
				end
			end
			_connections[connectName] = remoteEvent.OnServerEvent:Connect(remoteConnect)
		else
			local function remoteConnect(action: string, data: any)
				if callbacks[action] then
					callbacks[action](data)
				end
			end

			_connections[connectName] = remoteEvent.OnClientEvent:Connect(remoteConnect)
		end
	else
		_logger:warn(`подписка {connectName} на {remoteEvent.Name} уже существует`)
	end
end

local function unsubscribe(remoteEvent: RemoteEvent, connectName: string)
	if _connections[connectName] then
		_connections[connectName]:Disconnect()
		_connections[connectName] = nil
	else
		_logger:warn(
			`неудачная отписка {connectName} на {remoteEvent} события не существует`
		)
	end
end

-- ===================== API ===================== --
-- subscribe
function RemoteEventManager:SubscribeMatchRemoteEvent(connectName: string, callbacks: CallbacksType)
	registerConnect(_instances.matchRemoteEvent, connectName, callbacks)
end

function RemoteEventManager:SubscribeLobbyRemoteEvent(connectName: string, callbacks: CallbacksType)
	registerConnect(_instances.lobbyRemoteEvent, connectName, callbacks)
end

function RemoteEventManager:SubscribeServeRemoteEvent(connectName: string, callbacks: CallbacksType)
	registerConnect(_instances.serveRemoteEvent, connectName, callbacks)
end

function RemoteEventManager:SubscribeUIRemoteEvent(connectName: string, callbacks: CallbacksType)
	registerConnect(_instances.uiRemoteEvent, connectName, callbacks)
end

function RemoteEventManager:SubscribeDataRemoteEvent(connectName: string, callbacks: CallbacksType)
	registerConnect(_instances.dataRemoteEvent, connectName, callbacks)
end

-- unsubscribe
function RemoteEventManager:UnsubscribeMatchRemoteEvent(connectName: string)
	unsubscribe(_instances.matchRemoteEvent, connectName)
end

if RunService:IsServer() then
	function RemoteEventManager:LobbyRemoteEventFireClient(player: Player)
		return {
			setToPad = function(data: { padName: string, teamName: string })
				_instances.lobbyRemoteEvent:FireClient(
					player,
					RemoteEventManager.actions.lobbyRemoteEvent.fromServer.setToPad,
					data
				)
			end,
		}
	end

	function RemoteEventManager:DataRemoteEventFireClient(player: Player)
		return {
			receiveData = function(data)
				_instances.dataRemoteEvent:FireClient(
					player,
					RemoteEventManager.actions.dataRemoteEvent.fromServer.receiveData,
					data
				)
			end,
		}
	end

	function RemoteEventManager:MatchRemoteEventFireAllClients()
		return {
			updateGameData = function(data: any)
				_instances.matchRemoteEvent:FireAllClients(
					RemoteEventManager.actions.matchRemoteEvent.fromServer.updateGameData,
					data
				)
			end,
			updatePlayerGameData = function(data: any)
				_instances.matchRemoteEvent:FireAllClients(
					RemoteEventManager.actions.matchRemoteEvent.fromServer.updatePlayerGameData,
					data
				)
			end,
			updateRoundTimer = function(data: any)
				_instances.matchRemoteEvent:FireAllClients(
					RemoteEventManager.actions.matchRemoteEvent.fromServer.updateRoundTimer,
					data
				)
			end,
			updateRoundCount = function(data: any)
				_instances.matchRemoteEvent:FireAllClients(
					RemoteEventManager.actions.matchRemoteEvent.fromServer.updateRoundCount,
					data
				)
			end,
			updateIntermissionTimer = function(data: any)
				_instances.matchRemoteEvent:FireAllClients(
					RemoteEventManager.actions.matchRemoteEvent.fromServer.updateIntermissionTimer,
					data
				)
			end,
			updateTimeOutTimer = function(data: any)
				_instances.matchRemoteEvent:FireAllClients(
					RemoteEventManager.actions.matchRemoteEvent.fromServer.updateTimeOutTimer,
					data
				)
			end,
			dropGameTimer = function(data: any)
				_instances.matchRemoteEvent:FireAllClients(
					RemoteEventManager.actions.matchRemoteEvent.fromServer.dropGameTimer,
					data
				)
			end,
		}
	end

	function RemoteEventManager:ServeRemoteEventFireClient(player: Player)
		return {
			disableControl = function()
				_instances.serveRemoteEvent:FireClient(
					player,
					RemoteEventManager.actions.serveRemoteEvent.fromServer.disableControl
				)
			end,
			finishMatch = function(data: any)
				_instances.serveRemoteEvent:FireClient(
					player,
					RemoteEventManager.actions.serveRemoteEvent.fromServer.finishMatch,
					data
				)
			end,
			startMatch = function()
				_instances.serveRemoteEvent:FireClient(
					player,
					RemoteEventManager.actions.serveRemoteEvent.fromServer.startMatch
				)
			end,
			smallNotification = function(data: string)
				_instances.serveRemoteEvent:FireClient(
					player,
					RemoteEventManager.actions.serveRemoteEvent.fromServer.smallNotification,
					data
				)
			end,
		}
	end

	function RemoteEventManager:ServeRemoteEventFireAllClients(action: string, data: any)
		_instances.serveRemoteEvent:FireAllClients(action, data)
	end
else
	function RemoteEventManager:LobbyRemoteEventFireServer()
		return {
			quitFromPad = function(data)
				_instances.lobbyRemoteEvent:FireServer(
					RemoteEventManager.actions.lobbyRemoteEvent.fromClient.goToPadsZone,
					data
				)
			end,
			goToPadsZone = function()
				_instances.lobbyRemoteEvent:FireServer(
					RemoteEventManager.actions.lobbyRemoteEvent.fromClient.goToPadsZone
				)
			end,
			goToMatch = function()
				_instances.lobbyRemoteEvent:FireServer(
					RemoteEventManager.actions.lobbyRemoteEvent.fromClient.goToMatch
				)
			end
		}
	end
end

return RemoteEventManager
