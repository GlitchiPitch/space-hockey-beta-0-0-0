local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local StateMachine = {
	Variables = ReplicatedStorage.Shared.Variables,
	connections = {} :: { [string]: RBXScriptConnection },
	_logger = require(ReplicatedStorage.Shared.Logger).new(script.Name),
}

if RunService:IsServer() then
	function StateMachine:SetGameState(state: boolean)
		self.Variables.GameRunning.Value = state
	end
end

function StateMachine:GameIsRunning(): boolean
	return self.Variables.GameRunning.Value
end

function StateMachine:Subscribe(connectName: string, actions: { active: () -> (), inactive: () -> () })
	if not self.connections then
		local function onGameRunningChanged(value: boolean)
			if value and actions.active then
				actions.active()
			elseif not value and actions.inactive then
				actions.inactive()
			end
		end

		self.connections[connectName] = self.Variables.GameRunning.Changed:Connect(onGameRunningChanged)
		self._logger:info(`произошла подписка на изменение GameRunning от {connectName}`)
	else
		self._logger:warn(`неудачная попытка подписки для события {connectName}`)
	end
end

function StateMachine:Unsubscribe(connectName: string)
	if self.connections[connectName] then
		self.connections[connectName]:Disconnect()
		self.connections[connectName] = nil
	else
		self._logger:warn(`неудачная попытка отписки для события {connectName}`)
	end
end

return StateMachine
