local Types = require(script.Parent.Parent.Types)

local PucksController = {}

-- ===================== Private ===================== --
local _logger

local function setPuckToPlayer(player: Player, pucksAmount: number) end

local function touchPuck(puck: Model) end
local function removePucksFromPlayer(player: Player) end

function PucksController:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
end

function PucksController:Setup() end

-- ===================== API ===================== --
function PucksController:SpawnPucks() end

function PucksController:ClearPucks() end

function PucksController:DropPucksFromPlayer(player: Player)
	removePucksFromPlayer(player)
end
function PucksController:RemovePucksFromPlayer(player: Player)
	removePucksFromPlayer(player)
end

return PucksController
