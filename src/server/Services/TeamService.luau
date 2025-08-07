local Teams = game:GetService("Teams")
local Types = require(script.Parent.Parent.Types)

local TeamService = {}

-- ===================== Private ===================== --
local _logger
local settings

function TeamService:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
	settings = ServerBootstrap.settings
	-- только для визуала
	self._teams = {
		alien = Teams["Пришельцы"],
		human = Teams["Земляне"],
	}

	self._teamsData = {
		alien = {
			score = 0,
			players = {} :: { number },
		},
		human = {
			score = 0,
			players = {} :: { number },
		},
	}

	self._playersData = {} :: { [number]: Types.GamePlayerDataType }
end

function TeamService:Setup() end

--@todo: возможно также сделать методы для доступа к полям класса

-- ===================== API ===================== --
function TeamService:CanJoinToTeam(teamName: string): boolean
	return #self._teamsData[teamName].players <= #self._teamsData[teamName == "alien" and "human" or "alien"].players
end

function TeamService:CheckValidTeamsForStart(): boolean
	return (#self._teamsData.alien.players > 1) and (#self._teamsData.human.players > 1)
end

function TeamService:CheckNoEmptyTeam(): boolean
	return #self._teamsData.alien.players + #self._teamsData.human.players >= settings.minPlayers
end

function TeamService:SortTeamsByScore()
	for _, team: Types.TeamDataType in self._teamsData do
		table.sort(team.players, function(a0: number, a1: number)
			return self._playersData[a0].score > self._playersData[a1].score
		end)
	end
end

function TeamService:GetPlayerFinalData(userId: number): Types.GamePlayerDataType
	return {
		userId = userId,
		score = self._playersData[userId].score,
		shootingScore = self._playersData[userId].shootingScore,
		goals = self._playersData[userId].goals,
	}
end

function TeamService:AddLobbyQueueToTeamsData(queue: { alien: { number }, human: { number } })
	self._teamsData.alien.players = queue.alien
	self._teamsData.human.players = queue.human
end

function TeamService:ResetData()
	self._teamsData.alien.score = 0
	self._teamsData.human.score = 0
	self._teamsData.alien.players = {}
	self._teamsData.human.players = {}
	self._playersData = {}
end

return TeamService
