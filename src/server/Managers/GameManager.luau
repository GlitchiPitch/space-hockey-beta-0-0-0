local Types = require(script.Parent.Parent.Types)

--[[
]]
local GameManager = {}

-- ===================== Private ===================== --
local _matchSystem, _events, _lobbySystem

local function startGame()
	if not GameManager._isRunning then
		GameManager._isRunning = true
		_lobbySystem:SetShowBillboards(true)

		_matchSystem:Start()
		_matchSystem:Round()
		_matchSystem:Finish()

		_lobbySystem:SetShowBillboards(false)
		_lobbySystem:ClearQueue()

		GameManager._isRunning = false
	end
end

local function connectToGameEvent()
	local callbacks = {
		[_events.actions.gameEvent.startGame] = startGame,
	}
	_events:ConnectToGameEvent(script.Name, callbacks)
end

function GameManager:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_matchSystem = ServerBootstrap._systems.matchSystem
	_lobbySystem = ServerBootstrap._systems.lobbySystem
	_events = ServerBootstrap._events

	self._isRunning = false
end

function GameManager:Setup()
	connectToGameEvent()
end

-- ===================== API ===================== --

return GameManager
