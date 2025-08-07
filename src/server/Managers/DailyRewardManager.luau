local Types = require(script.Parent.Parent.Types)

local DailyRewardManager = {}

-- ===================== Private ===================== --
local _logger

-- ===================== API ===================== --
function DailyRewardManager:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger.new(script.Name)
    
end

return DailyRewardManager