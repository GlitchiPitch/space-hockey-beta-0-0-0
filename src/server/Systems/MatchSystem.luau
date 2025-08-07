local Players = game:GetService("Players")
local Types = require(script.Parent.Parent.Types)

local MatchSystem = {}

-- ===================== Private ===================== --
local _logger, _inventorySystem, _teamService, _rewardService, _dataSystem, _badgeService, _isDropped, _utils, _remotes, _gameInstances
local config, settings

local function getMiddleRating(): number
	local middleRating = 0
	for _, team: Types.TeamDataType in _teamService._teamsData do
		for _, userId in team.players do
			middleRating += _dataSystem:GetPlayerRating(userId)
		end
	end

	_logger:info(
		`средний рейтинг {#_teamService._teamsData.alien.players + #_teamService._teamsData.human.players} игроков {middleRating}`
	)
	return middleRating
end

local function getWinner(): Types.TeamsEnum?
	local winner: Types.TeamsEnum
	if _teamService._teamsData.alien.score > _teamService._teamsData.human.score then
		winner = "alien"
	elseif _teamService._teamsData.human.score > _teamService._teamsData.alien.score then
		winner = "human"
	end
	_logger:info(`команда победитель {winner}`)
	return winner
end

local function giveRewards(winner: Types.TeamsEnum?, middleRating: number)
	for teamName: Types.TeamsEnum, team: Types.TeamDataType in _teamService._teamsData do
		local gameRewards = if not winner or winner == teamName
			then config.roundRewards.winner
			else config.roundRewards.loosers

		for index, userId in team.players do
			local reward = gameRewards[index] or gameRewards.overrated
			local playerRating = _dataSystem:GetPlayerRating(userId)
			reward.rating = (middleRating - playerRating) * 0.15 + reward.rating
			_rewardService:GiveGameReward(userId, reward.pucks, reward.rating)
		end
	end
end

local function validatePlayers()
	for _: Types.TeamsEnum, team: Types.TeamDataType in _teamService._teamsData do
		for index, userId in team.players do
			if not _utils:ValidatePlayer(userId) then
				_rewardService:GiveMulct(userId)
				table.remove(team.players, index)
			end
		end
	end
end

local function finishMatch(winner: Types.TeamsEnum?)
	local finalData: Types.FinalDataType = {
		teams = {
			alien = {},
			human = {},
		},
		winner = winner,
	}

	for teamName: Types.TeamsEnum, team: Types.TeamDataType in _teamService._teamsData do
		for _, userId in team.players do
			local playerFinalData = _teamService:GetPlayerFinalData(userId)
			table.insert(finalData.teams[teamName], playerFinalData)
		end
	end

	for teamName: Types.TeamsEnum, team: Types.TeamDataType in _teamService._teamsData do
		for _, userId in team.players do
			local player = Players:GetPlayerByUserId(userId)
			finalData.playerTeam = teamName
			_remotes:ServeRemoteEventFireClient(player).finishMatch(finalData)
			-- _inventorySystem:Unequip(userId)
			-- _lobbySystem:SetPlayerToLobby(player)
			player:LoadCharacter()
			player.Neutral = true
		end
	end

	_teamService:ResetData()
end

local function dropGame()
	for _, team: Types.TeamDataType in _teamService._teamsData do
		for _, userId in team.players do
			if _utils:ValidatePlayer(userId) then
				local player = Players:GetPlayerByUserId(userId)
				player:LoadCharacter()
				player.Neutral = true
			end
		end
	end
	_teamService:ResetData()
end

local function getFreeSpawnPoint(teamName: Types.TeamsEnum): Part?
	local spawnPoints = {
		alien = _gameInstances.SpawnPoints.Alien,
		human = _gameInstances.SpawnPoints.Human,
	}

	for _, spawnPoint: Part in spawnPoints[teamName]:GetChildren() do
		if #spawnPoint:GetChildren() == 0 then
			return spawnPoint
		end
	end
end

local function setupGameRequirement(player: Player)
	local playerSpawn = player.Character.Parent
	local flightHold = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyPosition")
	local flightPower = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
	local flightSpin = player.Character.HumanoidRootPart:FindFirstChildOfClass("BodyGyro")
end

local function setPlayerToSpawnPoint(player: Player, teamName: Types.TeamsEnum)
	local playerParent = player.Character.Parent
	local playerSpawn = if playerParent:IsA("Part") then playerParent else getFreeSpawnPoint(teamName) :: Part

	if playerSpawn then
		player.Character.Parent = playerSpawn
		player.Character:PivotTo(playerSpawn.CFrame)
		setupGameRequirement(player)
	else
		_logger:error(`для игрока {player.Name} не нашлось спавн поинта в игре`)
	end
end

local function setPlayersToSpawn()
	for _, teamData: Types.TeamDataType in _teamService._teamsData do
		for index, userId: number in teamData.players do
			if _utils:ValidatePlayer(userId) then
				local player = Players:GetPlayerByUserId(userId)
				setupGameRequirement(player)
			else
				table.remove(teamData.players, index)
			end
		end
	end
end

function MatchSystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_inventorySystem = ServerBootstrap._systems.inventorySystem
	_rewardService = ServerBootstrap._services.rewardService
	_badgeService = ServerBootstrap._services.badgeService
	_teamService = ServerBootstrap._services.teamService
	_logger = ServerBootstrap._logger.new(script.Name)
	_dataSystem = ServerBootstrap._systems.dataSystem
	_gameInstances = ServerBootstrap._workspace.game
	_remotes = ServerBootstrap._remotes
	_utils = ServerBootstrap._utils

	config = ServerBootstrap.config
	settings = ServerBootstrap.settings
end

function MatchSystem:Setup() end

-- ===================== API ===================== --
function MatchSystem:Start()
	_isDropped = false

	for teamName: Types.TeamsEnum, teamData: Types.TeamDataType in _teamService._teamsData do
		for _, userId: number in teamData.players do
			self:SetupPlayerToMatch(teamName, userId)
		end
	end
end

function MatchSystem:Round()
	for i = 1, settings.roundCount do
		setPlayersToSpawn()
		_remotes:MatchRemoteEventFireAllClients().updateRoundCount(i)
		-- intermission
		for j = settings.intermissionTimer, 0, -1 do
			_remotes:MatchRemoteEventFireAllClients().updateIntermissionTimer(j)
			task.wait(1)
		end

		-- round
		for j = settings.roundTimer, 0, -1 do
			-- check can continue
			if not _teamService:CheckNoEmptyTeam() then
				_isDropped = true
				break
			end
			_remotes:MatchRemoteEventFireAllClients().updateRoundTimer(j)
			task.wait(1)
		end

		if i < 3 and not _isDropped then
			-- timeOut
			for j = settings.timeOutTimer, 0, -1 do
				_remotes:MatchRemoteEventFireAllClients().updateTimeOutTimer(j)
				task.wait(1)
			end
		end
	end
end

function MatchSystem:Finish()
	validatePlayers()

	if not _isDropped then
		_teamService:SortTeamsByScore()

		local middleRating = getMiddleRating()
		local winner = getWinner()

		_logger:info(
			`финальный результат: прищельцы = {_teamService._teamsData.alien.score} | земляне = {_teamService._teamsData.human.score} `
		)
		_badgeService:MaxPlayersInGame(_teamService._teamsData.alien.players, _teamService._teamsData.human.players)
		giveRewards(winner, middleRating)
		finishMatch(winner)
	else
		for i = settings.dropGameTimer, 0, -1 do
			_remotes:MatchRemoteEventFireAllClients().dropGameTimer(i)
			task.wait(1)
		end
		dropGame()
	end

	_teamService:ResetData()
end

function MatchSystem:SetupPlayerToMatch(teamName: Types.TeamsEnum, userId: number)
	if _utils:ValidatePlayer(userId) then
		local player = Players:GetPlayerByUserId(userId)
		player.Team = _teamService._teams[teamName]
		_inventorySystem:Equip(userId, teamName)
		setPlayerToSpawnPoint(player, teamName)
		_remotes:ServeRemoteEventFireClient(player).startMatch()
	end
end

return MatchSystem
