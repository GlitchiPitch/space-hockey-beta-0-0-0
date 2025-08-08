local Types = require(script.Parent.Parent.Types)

local ClubSystem = {}

-- ===================== Private ===================== --
local _logger, _dataSystem, _remotes, clubsRegistry

local function onGameClose()
	for _, clubs: { [string]: { icon: number } } in clubsRegistry do
		for clubName: string, _ in clubs do
			_dataSystem:PostClubMembers(clubName)
		end
	end
end

local function getClubsMembers()
	for _, clubs: { [string]: { icon: number } } in clubsRegistry do
		for clubName: string, _ in clubs do
			_dataSystem:GetClubMembers(clubName)
		end
	end
end

-- ===================== API ===================== --
function ClubSystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
	_dataSystem = ServerBootstrap._systems.dataSystem
	_remotes = ServerBootstrap._remotes
	clubsRegistry = ServerBootstrap.clubsRegistry
end

function ClubSystem:Setup()
	getClubsMembers()
	game:BindToClose(onGameClose)
end

function ClubSystem:GetClubMembers(clubName: string): { number }
	return _dataSystem:GetClubMembers(clubName)
end

function ClubSystem:AddMember(clubName: string, player: Player)
	local clubMembers = _dataSystem:GetClubMembers(clubName)
	if not table.find(clubMembers, player.UserId) then
		table.insert(clubMembers, player.UserId)
		_dataSystem:UpdateClubMembers(clubName, clubMembers)
		_remotes:DataRemoteEventFireAllClients().receiveClubMembers({ clubName = clubName, members = #clubMembers })
		_logger:info(`игрок {player.UserId} успешно добавлен в клуб {clubName}`)
	else
		_logger:warn(
			`попытка добавить в клуб существующего игрока {player.UserId}`
		)
	end
end

function ClubSystem:RemoveMember(clubName: string, player: Player)
	local clubMembers = _dataSystem:GetClubMembers(clubName)
	local playerIndex = table.find(clubMembers, player.UserId)
	if playerIndex then
		table.remove(clubMembers, playerIndex)
		_dataSystem:UpdateClubMembers(clubName, clubMembers)
		_remotes:DataRemoteEventFireAllClients().receiveClubMembers({ clubName = clubName, members = #clubMembers })
		_logger:info(`игрок {player.UserId} успешно удален из клуба {clubName}`)
	else
		_logger:warn(
			`попытка удалить из клуба несуществующего игрока {player.UserId}`
		)
	end
end

return ClubSystem
