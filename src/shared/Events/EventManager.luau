local ReplicatedStorage = game:GetService("ReplicatedStorage")

type CallbacksType = { [string]: (data: any) -> () }

local EventManager = {
	actions = {
		gameEvent = {
			startGame = "startGame",
		},
	},
}

-- ===================== Private ===================== --
local _logger = require(ReplicatedStorage.Shared.Logger).new(script.Name)
local _instances = {
	gameEvent = script.Parent.GameEvent,
}
local _connections = {} :: { [string]: RBXScriptConnection }

local function registerConnect(event: BindableEvent, connectName: string, callbacks: CallbacksType)
	if not _connections[connectName] then
		local function eventConnect(action: string, data: any)
			if callbacks[action] then
				callbacks[action](data)
			end
		end
		_connections[connectName] = _instances.gameEvent.Event:Connect(eventConnect)
	else
		_logger:warn(`подписка {connectName} на {event.Name} уже существует`)
	end
end

-- ===================== API ===================== --
function EventManager:ConnectToGameEvent(connectName: string, callbacks: CallbacksType)
	registerConnect(_instances.gameEvent, connectName, callbacks)
end

function EventManager:GameEventFire()
	return {
		startGame = function()
			_instances.gameEvent:Fire(EventManager.actions.gameEvent.startGame)
		end,
	}
end

return EventManager
