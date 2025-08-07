local Types = require(script.Parent.Parent.Types)

local TutorialHandler = {}

-- ===================== Private ===================== --
local _logger, _dataSystem

local function teleportPlayerToTutorial(player: Player)
    --@notImplemented
end

-- ===================== API ===================== --
function TutorialHandler:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger.new(script.Name)
    _dataSystem = ServerBootstrap._systems.dataSystem
end

function TutorialHandler:Setup()
    
end

function TutorialHandler:CheckPlayerCompleteTutorial(player: Player)
    local playerData = _dataSystem:GetPlayerData(player.UserId)
    if not playerData.Tutorial.visited then
        teleportPlayerToTutorial(player)
    end
end

return TutorialHandler