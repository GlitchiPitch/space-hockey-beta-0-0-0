local Players = game:GetService("Players")
--!nocheck
local Types = require(script.Parent.Parent.Types)

local ChampionshipSystem = {}

-- ===================== Private ===================== --
local _dataSystem, _logger, _remotes, clubsRegistry, cache, _updateRatingsTime

local function savePlayersRating()
	while true do
		for _, player: Player in Players:GetPlayers() do
			_dataSystem:SavePlayerRating(player.UserId)
			task.wait(0.1)
		end

		for clubName: string, _ in clubsRegistry do
			_dataSystem:SaveClubRating(clubName)
			task.wait(0.1)
		end

		task.wait(_updateRatingsTime)
	end
end

-- ===================== API ===================== --
function ChampionshipSystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_dataSystem = ServerBootstrap._systems.dataSystem
	_logger = ServerBootstrap._logger.new(script.Name)
	_remotes = ServerBootstrap._remotes
	clubsRegistry = ServerBootstrap.clubsRegistry
	cache = ServerBootstrap.cache

	_updateRatingsTime = 5
end

function ChampionshipSystem:Setup()
	coroutine.wrap(savePlayersRating)()
end

function ChampionshipSystem:GetPlayerRating(player: Player)
	return _dataSystem:GetPlayerRating()
end

function ChampionshipSystem:GetClubRating() end

function ChampionshipSystem:PostPlayerRating() end

function ChampionshipSystem:PostClubRating() end

function ChampionshipSystem:UpdateClubRating(clubName: string, value: number)
	-- local clubRating = _dataSystem:GetClubRating(clubName)
	-- -- ???
	-- clubRating += value
	_dataSystem:UpdateClubRating(clubName, value)
	_remotes:DataRemoteEventFireAllClients().receiveClubRating({ clubName = clubName, rating = value })
end

function ChampionshipSystem:UpdatePlayerRating(userId: number, value: number)
	_dataSystem:UpdatePlayerRating(userId, value)
end

function ChampionshipSystem:GetCurrentWeekTopClubs()
	return _dataSystem:GetCurrentWeekTopClubs()
end

function ChampionshipSystem:GetLastWeekTopClubs()
	return _dataSystem:GetLastWeekTopClubs()
end

function ChampionshipSystem:GetCurrentWeekTopPlayers()
	return _dataSystem:GetCurrentWeekTopPlayers()
end
function ChampionshipSystem:GetLastWeekTopPlayers()
	return _dataSystem:GetLastWeekTopPlayers()
end

return ChampionshipSystem
