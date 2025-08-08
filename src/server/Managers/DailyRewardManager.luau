local Types = require(script.Parent.Parent.Types)

local DailyRewardManager = {}

-- ===================== Private ===================== --
local _logger, _rewardService

-- ===================== API ===================== --
function DailyRewardManager:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger.new(script.Name)
    _rewardService = ServerBootstrap._services.rewardService
end



return DailyRewardManager