local Players = game:GetService("Players")
local Types = require(script.Parent.Parent.Types)

local PlayerService = {}

-- ===================== Private ===================== --
local _dataSystem, _tutorialHandler, cache
local function onCharacterAdded(character: Model)
    local player = Players:GetPlayerFromCharacter(character)
    _tutorialHandler:CheckPlayerCompleteTutorial(player)
end

local function onPlayerAdded(player: Player)
    _dataSystem:GetPlayerData(player.UserId)
    cache[player.Name] = {
        onCharacterAdded = player.CharacterAdded:Connect(onCharacterAdded)
    }
end

local function onPlayerRemoving(player: Player)
    _dataSystem:PostPlayerData(player.UserId)
end

local function updatePlayersBoost()
    while task.wait(1) do
		for _, player in Players:GetPlayers() do
            local playerData = _dataSystem:GetPlayerData(player.UserId)
            for statName, statData in playerData.Stats do
                if statData.boostTimer > 0 then
                    statData.boostTimer -= 1
                    _dataSystem:UpdatePlayerData(player.UserId, playerData)
                end
            end
			-- local stats = self.IPlayer:GetStats(player)
			-- if stats then
			-- 	for _, stat in stats:GetChildren() :: { IntValue } do
			-- 		local boostTimer = stat:GetAttribute(self.constants.ATTRIBUTES.TIMER) :: number
			-- 		local multiplier = stat:GetAttribute(self.constants.ATTRIBUTES.BOOST_MULTIPLIER) :: number

			-- 		-- print(stat, boostTimer, multiplier)
			-- 		if boostTimer and (multiplier and multiplier > (stat.Name == "Health" and 0 or 1)) then
			-- 			local playerData = self.dataSystem:GetCache(player)
			-- 			if boostTimer > 0 then
			-- 				stat:SetAttribute(self.constants.ATTRIBUTES.TIMER, boostTimer - 1)
			-- 			else
			-- 				stat:SetAttribute(self.constants.ATTRIBUTES.TIMER, 0)
			-- 				stat:SetAttribute(self.constants.ATTRIBUTES.BOOST_MULTIPLIER, if stat.Name == "Health" then 0 else 1)
			-- 				stat:SetAttribute(self.constants.ATTRIBUTES.LAST_BOOST, "")
			-- 			end
			-- 			playerData.Stats[stat.Name].boostTimer =
			-- 				stat:GetAttribute(self.constants.ATTRIBUTES.TIMER)
			-- 			playerData.Stats[stat.Name].boostMultiplier =
			-- 				stat:GetAttribute(self.constants.ATTRIBUTES.BOOST_MULTIPLIER)
			-- 		end
			-- 	end
			-- end
		end
	end
end

function PlayerService:Initialize(ServerBootstrap: Types.ServerBootstrapType)
    _dataSystem = ServerBootstrap._systems.dataSystem
    _tutorialHandler = ServerBootstrap._handlers.tutorialHandler
    cache = ServerBootstrap.cache
end

function PlayerService:Setup()
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    coroutine.wrap(updatePlayersBoost)()
end

return PlayerService