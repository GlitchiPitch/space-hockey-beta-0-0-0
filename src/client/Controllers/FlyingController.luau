local Types = require(script.Parent.Parent.Types)

local FlyingController = {}
local _logger, _remotes

-- ===================== Private ===================== --
local function playerFly(player: Player, cameraCFrame: CFrame)
    
end

local function playerSprint(player: Player, activated: boolean)
    _logger:info(`игрок {player.Name} активировал спринт`)
end

function FlyingController:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger.new(script.Name)
    _remotes = ServerBootstrap._remotes
end

function FlyingController:Setup()
    
end

-- ===================== API ===================== --
function FlyingController:Track()
    
end

function FlyingController:Untrack()
end

return FlyingController