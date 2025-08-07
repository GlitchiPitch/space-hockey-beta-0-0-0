local Types = require(script.Parent.Parent.Types)

local RewardService = {}

-- ===================== Private ===================== --
local _logger, _dataSystem
local settings

function RewardService:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger
    _dataSystem = ServerBootstrap._systems.dataSystem
    settings = ServerBootstrap.settings
end

function RewardService:Setup()
    
end

-- ===================== API ===================== --
function RewardService:GiveWeeklyReward(player: Player)
    
end

function RewardService:GiveClubWeeklyReward(player: Player)
    
end

function RewardService:GiveDailyReward(player: Player)

end

function RewardService:GiveGameReward(userId: number, pucks: number, rating: number)
    local playerData = _dataSystem:GetPlayerData(userId)
    local playerRating = _dataSystem:GetPlayerRating(userId)

    playerRating += rating
    playerData.Currency.Pucks += pucks

    _dataSystem:UpdatePlayerRating(userId, playerRating)
    _dataSystem:UpdatePlayerData(userId, playerData)

    if playerData.Club then
        local clubRating = _dataSystem:GetClubRating(playerData.Club)
        clubRating += rating
        _dataSystem:UpdateClubRating(playerData.Club, clubRating)
    end
end

function RewardService:GiveMulct(userId: number)
    local playerData = _dataSystem:GetPlayerData(userId)
    local playerRating = _dataSystem:GetPlayerRating(userId)

    playerData.Currency.Pucks -= settings.mulct.pucks
    playerRating -= settings.mulct.rating

    _dataSystem:UpdatePlayerRating(userId, playerRating)
    _dataSystem:UpdatePlayerData(userId, playerData)

    _logger:warn(`игрок {userId} покинул игру до завершения`)
end

return RewardService