local Types = require(script.Parent.Parent.Types)

local InventorySystem = {}

-- ===================== Private ===================== --
local _logger, _dataSystem

function InventorySystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _logger = ServerBootstrap._logger.new(script.Name)
    _dataSystem = ServerBootstrap._systems.dataSystem
end

function InventorySystem:Setup()
end

-- ===================== API ===================== --
function InventorySystem:Equip(userId: number, teamName: Types.TeamsEnum)
    -- equipSkin
    -- equipStick
    -- equipTrail?
    -- equipAnimations?
end

-- @question: возможно етот метод нет смысла исопльзовать так как будет LoadCharacter()
function InventorySystem:Unequip(userId: number)
    
end

return InventorySystem