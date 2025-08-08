local Types = require(script.Parent.Parent.Types)

local WeeklyRewardManager = {}

-- ===================== Private ===================== --
local _dataSystem, _weeklyRewardInstances

local function setPrompts(v)
    if tonumber(v.Name) <_dataSystem.currentWeek then
    end
end

local function setStands()
    for i, v in _weeklyRewardInstances:GetChildren() do
        setPrompts(v)
        
    end
end

-- ===================== API ===================== --
function WeeklyRewardManager:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _weeklyRewardInstances = ServerBootstrap._workspace.weeklyReward
    _dataSystem = ServerBootstrap._systems.dataSystem
end

function WeeklyRewardManager:Setup()
    setStands()
end

return WeeklyRewardManager