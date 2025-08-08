local Types = require(script.Parent.Parent.Types)

local InventorySystem = {}

-- ===================== Private ===================== --
local _logger, _dataSystem

-- ===================== API ===================== --
function InventorySystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
	_dataSystem = ServerBootstrap._systems.dataSystem
end

function InventorySystem:Setup() end

function InventorySystem:Equip(userId: number, teamName: Types.TeamsEnum)
	-- equipSkin
	-- equipStick
	-- equipTrail?
	-- equipAnimations?
end

-- @question: возможно етот метод нет смысла исопльзовать так как будет LoadCharacter()
function InventorySystem:Unequip(userId: number) end

function InventorySystem:AddInventoryItemToPlayer(
	userId: number,
	itemType: Types.InventoryItemEnum,
	itemName: string
)
end

function InventorySystem:RemoveInventoryItemFromPlayer(
	userId: number,
	itemType: Types.InventoryItemEnum,
	itemName: string
)
end

function InventorySystem:SetCurrentItem(userId: number, itemType: Types.InventoryItemEnum, itemName: string) end

return InventorySystem
