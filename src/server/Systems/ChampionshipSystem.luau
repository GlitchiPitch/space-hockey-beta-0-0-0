--!nocheck
local Types = require(script.Parent.Parent.Types)

local ChampionshipSystem = {}

-- ===================== Private ===================== --
local _dataSystem, _logger, _remotes, clubsRegistry, cache

-- ===================== API ===================== --
function ChampionshipSystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_dataSystem = ServerBootstrap._systems.dataSystem
	_logger = ServerBootstrap._logger.new(script.Name)
	_remotes = ServerBootstrap._remotes
    clubsRegistry = ServerBootstrap.clubsRegistry
	cache = ServerBootstrap.cache
end

function ChampionshipSystem:Setup() end

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

--@todo: возможно есть смысл сделать какой цикл, который будет обновлять дату через интервал и возможно привязаться к глобальному апдейту, если он есть

function ChampionshipSystem:UpdateClubsRating()
    cache.clubsRating = {} :: { [string]: number }
    for _, clubs: { [string]: { icon: number } } in clubsRegistry do
        for clubName, _ in clubs do
            local clubRating = _dataSystem:GetClubRating(clubName)
            cache.clubsRating[clubName] = clubRating
        end
    end

    _remotes:DataRemoteEventFireAllClients().receiveClubsRating(cache.clubsRating)
end

function ChampionshipSystem:UpdatePlayersRating()
	
end

return ChampionshipSystem
