local Types = require(script.Parent.Parent.Types)
local _BadgeService = game:GetService("BadgeService")

local BadgeService = {}

-- ===================== Private ===================== --
local _logger
local constants

function BadgeService:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger
    constants = ServerBootstrap.constants
    
end

function BadgeService:Setup()
    
end

-- ===================== API ===================== --
function BadgeService:MaxPlayersInGame(alien: { number }, human: { number })
    if #alien + #human == 10 then
        for _, team: { number } in { alien, human } do
            for _, userId in team do
                if not _BadgeService:UserHasBadgeAsync(userId, constants.BADGES.maxPlayersInGame) then
                    _BadgeService:AwardBadge(userId, constants.BADGES.maxPlayersInGame)
                    _logger:info(`игрок {userId} получил бейдж [maxPlayersInGame]`)
                end
            end
        end
    end
end

return BadgeService