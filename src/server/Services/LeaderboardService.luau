--!nocheck
local RunService = game:GetService("RunService")
local Types = require(script.Parent.Parent.Types)

local LeaderboardService = {}

-- ===================== Private ===================== --
local _logger, _championshipSystem, _settings, _workspace, _assets, _utils,
clubLeaderboard, playerLeaderboard, clubLeaderboardTemplate, playerLeaderboardTemplate,
onRender: RBXScriptConnection

local function fillLeaderboard(
	leaderboardData: Types.TopClubsDataType | Types.TopPlayersDataType,
	setup: (
		rank: number,
		data: Types.TopClubOrderedDataType | Types.TopPlayerOrderedDataType
	) -> ()
)
	for rank, data in leaderboardData do
		setup(rank, data)
	end
end

local function fillCurrentWeekClubRating()
	fillLeaderboard(
		_championshipSystem:GetCurrentWeekTopClubs(),
		function(rank: number, data: Types.TopClubOrderedDataType)
			-- @notImplemented
		end
	)
end

local function fillLastWeekClubRating()
	fillLeaderboard(
		_championshipSystem:GetLastWeekTopClubs(),
		function(rank: number, data: Types.TopClubOrderedDataType)
			-- @notImplemented
		end
	)
end

local function fillCurrentWeekPlayerRating()
	fillLeaderboard(
		_championshipSystem:GetCurrentWeekTopPlayers(),
		function(rank: number, data: Types.TopPlayerOrderedDataType)
			-- @notImplemented
		end
	)
end

local function fillLastWeekPlayerRating()
	fillLeaderboard(
		_championshipSystem:GetLastWeekTopPlayers(),
		function(rank: number, data: Types.TopPlayerOrderedDataType)
			-- @notImplemented
		end
	)
end

local function switchClubLeaderboard()
	clubLeaderboard.CurrentWeek.Enabled = not clubLeaderboard.CurrentWeek.Enabled
	clubLeaderboard.LastWeek.Enabled = not clubLeaderboard.CurrentWeek.Enabled
end

local function update()
	local function _onRender(deltaTime: number)
		for _, v in _settings do
			v.deltaTime += deltaTime
			if v.deltaTime >= v.target then
				v.deltaTime = 0
				v.action()
			end
		end
	end

	onRender = RunService.PreRender:Connect(_onRender)
	_utils:AddConnectToGameClose(`{script.Name}_onRender`, onRender)
end

-- ===================== API ===================== --
function LeaderboardService:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
	_championshipSystem = ServerBootstrap._systems.championshipSystem
	_utils = ServerBootstrap._utils
	clubLeaderboard = ServerBootstrap._workspace.clubLeaderboard
	playerLeaderboard = ServerBootstrap._workspace.playerLeaderboard

	clubLeaderboardTemplate = ServerBootstrap._assets.UI.ClubLeaderboardTemplate
	playerLeaderboardTemplate = ServerBootstrap._assets.UI.PlayerLeaderboardTemplate

	_settings = {
		clubLeaderboardUpdateTime = {
			target = 5,
			deltaTime = 0,
			action = function()
				fillCurrentWeekClubRating()
			end,
		},
		switchClubLeaderboardTime = {
			target = 5,
			deltaTime = 0,
			action = function()
				switchClubLeaderboard()
			end,
		},
		playerLeaderboardUpdateTime = {
			target = 5,
			deltaTime = 0,
			action = function()
				fillCurrentWeekPlayerRating()
			end,
		},
	}
end

function LeaderboardService:Setup()
	fillCurrentWeekClubRating()
	fillCurrentWeekPlayerRating()
	fillLastWeekClubRating()
	fillLastWeekPlayerRating()

	update()
end

return LeaderboardService
