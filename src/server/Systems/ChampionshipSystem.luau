--!nocheck
local Types = require(script.Parent.Parent.Types)

local ChampionshipSystem = {}

-- ===================== Private ===================== --
local _dataSystem, _logger

function ChampionshipSystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_dataSystem = ServerBootstrap._systems.dataSystem
	_logger = ServerBootstrap._logger.new(script.Name)
end

function ChampionshipSystem:Setup() end

-- ===================== API ===================== --
function ChampionshipSystem:GetPlayerRating(player: Player)
	return _dataSystem:GetPlayerRating()
end

function ChampionshipSystem:GetClubRating() end

function ChampionshipSystem:PostPlayerRating() end

function ChampionshipSystem:PostClubRating() end

function ChampionshipSystem:UpdateClubRating(clubName: string, value: number) end

function ChampionshipSystem:UpdatePlayerRating(userId: number, value: number) end

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
