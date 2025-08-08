local Types = require(script.Parent.Parent.Types)

local FlyingController = {}

-- ===================== Private ===================== --
local _logger, _remotes

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
    local callbacks = {
        [_remotes.actions.matchRemoteEvent.fromClient.playerFly] = playerFly,
        [_remotes.actions.matchRemoteEvent.fromClient.playerSprint] = playerSprint
    }
    _remotes:SubscribeMatchRemoteEvent(script.Name, callbacks)
end

function FlyingController:Untrack()
    _remotes:UnsubscribeMatchRemoteEvent(script.Name)
end

return FlyingController