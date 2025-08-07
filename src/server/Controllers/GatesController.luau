local Types = require(script.Parent.Parent.Types)

local GatesController = {}

-- ===================== Private ===================== --
local _connections = {} :: { [string]: RBXScriptConnection }
local _logger, _pucksController, _rewardService

local function changeGateMultiplier(gate: Part) 
    _logger:info(`изменение множителя ворот`)
end

local function puckTouch(gate: Part) 
	changeGateMultiplier(gate)
end

local function playerTouch(player: Player) 
	_pucksController:RemovePucksFromPlayer(player)
	_rewardService:GiveGoalReward(player)
end

function GatesController:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
	_pucksController = ServerBootstrap._controllers.pucksController
	_rewardService = ServerBootstrap._services.rewardService
end

function GatesController:Setup() end

-- ===================== API ===================== --
function GatesController:Track()
	-- чек касаний
end

function GatesController:Untrack() end

return GatesController
