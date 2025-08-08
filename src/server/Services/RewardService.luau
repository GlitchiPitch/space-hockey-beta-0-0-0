local Types = require(script.Parent.Parent.Types)

local RewardService = {}

-- ===================== Private ===================== --
local _logger, _championshipSystem, _playerService
local settings

-- ===================== API ===================== --
function RewardService:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger
    _championshipSystem = ServerBootstrap._systems.championshipSystem
    _playerService = ServerBootstrap._services.playerService
    settings = ServerBootstrap.settings
end

function RewardService:Setup()
    
end


function RewardService:GiveWeeklyReward(player: Player)
    
end

function RewardService:GiveClubWeeklyReward(player: Player)
    
end

function RewardService:GiveDailyReward(player: Player)

end

function RewardService:GiveGameReward(userId: number, pucks: number, rating: number)
    local playerData = _playerService:GetPlayerData(userId)
    local playerRating = _championshipSystem:GetPlayerRating(userId)

    playerRating += rating
    playerData.Currency.Pucks += pucks

    _championshipSystem:UpdatePlayerRating(userId, playerRating)
    _playerService:UpdatePlayerData(userId, playerData)

    if playerData.Club then
        local clubRating = _championshipSystem:GetClubRating(playerData.Club)
        clubRating += rating
        _championshipSystem:UpdateClubRating(playerData.Club, clubRating)
    end
end

function RewardService:GiveMulct(userId: number)
    local playerData = _playerService:GetPlayerData(userId)
    local playerRating = _championshipSystem:GetPlayerRating(userId)

    playerData.Currency.Pucks -= settings.mulct.pucks
    playerRating -= settings.mulct.rating

    _championshipSystem:UpdatePlayerRating(userId, playerRating)
    _playerService:UpdatePlayerData(userId, playerData)

    _logger:warn(`игрок {userId} покинул игру до завершения`)
end

return RewardService