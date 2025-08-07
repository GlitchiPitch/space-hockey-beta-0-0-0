local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = {}

local _logger = require(ReplicatedStorage.Shared.Logger).new(script.Name)
local _onGameCloseConnections = {} :: { [string]: RBXScriptConnection }

local function onGameClose()
	for name, conn in _onGameCloseConnections do
		conn:Disconnect()
		_onGameCloseConnections[name] = nil
	end
end

function Utils:InitializeModules(
	moduleList: { [string]: { Initialize: (self: any, params: any?) -> () } },
	logger: _logger.LoggerType?,
	params: any?
)
	for name, module in moduleList do
		local success, result = pcall(function()
			module:Initialize(params)
		end)

		if logger then
			if not success then
				logger:error(`{name} : {result}`)
			else
				logger:info(`{name} : Initialize`)
			end
		end
	end
end

function Utils:SetupModules(moduleList: { [string]: { Setup: (self: any) -> () } }, logger: _logger.LoggerType)
	for name, module in moduleList do
		local success, result = pcall(function()
			module:Setup()
		end)

		if logger then
			if not success then
				logger:error(`{name} : {result}`)
			else
				logger:info(`{name} : Setup`)
			end
		end
	end
end

function Utils:ValidatePlayer(player: Player | number): boolean
	if type(player) == "number" then
		player = Players:GetPlayerByUserId(player)
		if not player then
			return false
		end
	end

	return player.Parent == Players and player.Character
end

function Utils:AddConnectToGameClose(connectName: string, connect: RBXScriptConnection)
	if not _onGameCloseConnections[connectName] then
		_onGameCloseConnections[connectName] = connect
	else
		_logger:warn()
	end
end

function Utils:ClearConnections(connections: { [string]: RBXScriptConnection }, whiteList: { string }?)
	for connectName, connect in connections do
		if whiteList and table.find(whiteList, connectName) then
			continue
		end

		connect:Disconnect()
	end
end

game:BindToClose(onGameClose)

return Utils
