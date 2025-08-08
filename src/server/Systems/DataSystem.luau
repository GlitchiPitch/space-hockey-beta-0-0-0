--!nocheck
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Types = require(script.Parent.Parent.Types)
local PlayerDataTemplate = require(ReplicatedStorage.Shared.PlayerDataTemplate)

local DataSystem = {}

-- ===================== Private ===================== --
local _logger, _utils, _stores, _sessionData, _canPost, _currentWeek, _remotes

local function getCurrentWeek(): number
	local schedule = {
		--[1] = {s = os.time({ year = 2025, month = 6, day = 30 }), e = os.time({ year = 2025, month = 7, day = 6 }) },
		[1] = {
			s = os.time({ year = 2025, month = 7, day = 7, hour = 0 }),
			e = os.time({ year = 2025, month = 7, day = 13, hour = 0 }),
		},
		[2] = {
			s = os.time({ year = 2025, month = 7, day = 14, hour = 0 }),
			e = os.time({ year = 2025, month = 7, day = 20, hour = 0 }),
		},
		[3] = {
			s = os.time({ year = 2025, month = 7, day = 21, hour = 0 }),
			e = os.time({ year = 2025, month = 7, day = 27, hour = 0 }),
		},
		[4] = {
			s = os.time({ year = 2025, month = 7, day = 28, hour = 0 }),
			e = os.time({ year = 2025, month = 8, day = 3, hour = 0 }),
		},
		[5] = {
			s = os.time({ year = 2025, month = 8, day = 4, hour = 24 }),
			e = os.time({ year = 2025, month = 8, day = 10, hour = 24 }),
		},
		[6] = {
			s = os.time({ year = 2025, month = 8, day = 11, hour = 24 }),
			e = os.time({ year = 2025, month = 8, day = 17, hour = 24 }),
		},
		[7] = {
			s = os.time({ year = 2025, month = 8, day = 18, hour = 24 }),
			e = os.time({ year = 2025, month = 8, day = 24, hour = 24 }),
		},
		[8] = {
			s = os.time({ year = 2025, month = 8, day = 25, hour = 24 }),
			e = os.time({ year = 2025, month = 8, day = 25, hour = 24 }),
		},
	}
	local currentWeek = 1

	for i, v in schedule do
		local t = os.time()
		if t > v.s and t < v.e then
			currentWeek = i
			print("currentWeek", i)
			break
		end
	end

	return currentWeek
end

-- получает дату из базы и грузит в кэш
local function getOrderedPlayersData(orderedStore: OrderedDataStore, pageSize: number): Types.TopPlayersDataType
	local pages = orderedStore:GetSortedAsync(false, pageSize)
	local top = pages:GetCurrentPage()
	local _data = {}
	for rank, data in top do
		local userId = data.key
		local rating = data.value
		_data[rank] = { userId = userId, rating = rating }
	end

	return _data
end

local function getOrderedClubsData(orderedStore: OrderedDataStore, pageSize: number): Types.TopClubsDataType
	local pages = orderedStore:GetSortedAsync(false, pageSize)
	local top = pages:GetCurrentPage()
	local _data = {}
	for rank, data in top do
		local clubName = data.key
		local rating = data.value
		_data[rank] = { clubName = clubName, rating = rating }
	end

	return _data
end

local function getData(player: Player)
	local playerData = DataSystem:GetPlayerData(player.UserId)
	_remotes:DataRemoteEventFireClient(player).receiveData(playerData)
end

local function subscribeDataRemoteEvent()
	local callbacks = {
		[_remotes.actions.dataRemoteEvent.fromClient.getData] = getData,
	}
	_remotes:SubscribeDataRemoteEvent(script.Name, callbacks)
end

function DataSystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	-- depends
	_logger = ServerBootstrap._logger.new(script.Name)
	_utils = ServerBootstrap._utils
	_remotes = ServerBootstrap._remotes

	_currentWeek = getCurrentWeek()

	_stores = {
		_playerStore = DataStoreService:GetDataStore("Player"), -- стата игроков
		_clubStore = DataStoreService:GetDataStore("Club"), -- мемберы клубов
		_championshipStore = {
			lastWeek = {
				clubs = { -- топ клубов
					store = DataStoreService:GetOrderedDataStore("Championship" .. "Club" .. _currentWeek - 1),
					pageSize = 5,
				},
				players = { -- топ игроков
					store = DataStoreService:GetOrderedDataStore("Championship" .. "Player" .. _currentWeek - 1),
					pageSize = 50,
				},
			},
			currentWeek = {
				clubs = { -- топ клубов
					store = DataStoreService:GetOrderedDataStore("Championship" .. "Club" .. _currentWeek),
					pageSize = 5,
				},
				players = { -- топ игроков
					store = DataStoreService:GetOrderedDataStore("Championship" .. "Player" .. _currentWeek),
					pageSize = 50,
				},
			},
		},
	}

	_sessionData = {
		_championshipStore = {
			lastWeek = {
				clubs = {} :: { [string]: number },
				players = {} :: { [number]: number },
			},
			currentWeek = {
				clubs = {} :: { [string]: number },
				players = {} :: { [number]: number },
			},
		},
		_playerStore = {} :: { [number]: PlayerDataTemplate.PlayerDataTemplateType },
		_clubStore = {} :: { [string]: { members: { number } } },
		_clubTopPlayersStore = {} :: { [string]: { userId: number, rating: number } },
	}

	_canPost = false

	-- public
	self.currentWeek = _currentWeek
end

function DataSystem:Setup()
	subscribeDataRemoteEvent()
end

-- ===================== Player API ===================== --
function DataSystem:GetPlayerData(userId: number): Types.PlayerDataType
	if not _sessionData._playerStore[userId] then
		_logger:warn(`данных игрока {userId} не было в момент вызова`)
		_sessionData._playerStore[userId] = _stores._playerStore:GetAsync(userId) or table.clone(PlayerDataTemplate)
	end

	_logger:info(`данные игрока {userId} успешно получены`)
	return _sessionData._playerStore[userId]
end

function DataSystem:PostPlayerData(userId: number)
	if _sessionData._playerStore[userId] then
		if _canPost then
			_stores._playerStore:SetAsync(userId, _sessionData._playerStore[userId])
		end
	else
		_logger:warn(`данных игрока {userId} не было в момент записи`)
	end

	_sessionData._playerStore[userId] = nil
end

function DataSystem:UpdatePlayerData(userId: number, playerData: PlayerDataTemplate.PlayerDataTemplateType)
	-- if not _sessionData._playerStore[userId] then
	-- 	_sessionData._playerStore[userId] = _stores._playerStore:GetAsync(userId)
	-- 		or table.clone(PlayerDataTemplate)
	-- end

	_sessionData._playerStore[userId] = playerData

	-- если игрока нет в игре то записываем дату после выхода и снова сохраняем
	if not _utils:ValidatePlayer(userId) then
		self:PostPlayerData(userId)
		_logger:info(
			`данные игрока {userId} были обновлены после выхода игрока`
		)
	else
		_logger:warn(`данные игрока {userId} обновлены`)
		local player = Players:GetPlayerByUserId(userId)
		_remotes:DataRemoteEventFireClient(player).receiveData(playerData)
	end
end

-- ===================== Club API ===================== --
function DataSystem:GetClubMembers(clubName: string): { number }
	if not _sessionData._clubStore[clubName] then
		_sessionData._clubStore[clubName] = _stores._clubStore:GetAsync(clubName) or { members = {} }
	end

	return _sessionData._clubStore[clubName].members
end

function DataSystem:PostClubMembers(clubName: string)
	if _sessionData._clubStore[clubName] then
		if _canPost then
			_stores._clubStore:SetAsync(clubName, _sessionData._clubStore[clubName])
		end
	end

	_sessionData._clubStore[clubName] = nil
end

function DataSystem:UpdateClubMembers(clubName: string, members: { number })
	_sessionData._clubStore[clubName] = { members = members }
	_logger:info(`участники клуба {clubName} обновлены, текущее кол-во : {#members}`)
end

-- ===================== Championship API ===================== --
function DataSystem:GetClubRating(clubName: string): number
	if not _sessionData._championshipStore.currentWeek.clubs[clubName] then
		_sessionData._championshipStore.currentWeek.clubs[clubName] = _stores._championshipStore.currentWeek.clubs.store:GetAsync(
			clubName
		) or 0
	end

	return _sessionData._championshipStore.currentWeek.clubs[clubName]
end

function DataSystem:PostClubRating(clubName: string)
	if _sessionData._championshipStore.currentWeek.clubs[clubName] then
		if _canPost then
			_stores._championshipStore.currentWeek.clubs.store:UpdateAsync(clubName, function(_)
				return _sessionData._championshipStore.currentWeek.clubs[clubName]
			end)
		end
	end

	_sessionData._championshipStore.currentWeek.clubs[clubName] = nil
end

function DataSystem:SaveClubRating(clubName: string)
	if _sessionData._championshipStore.currentWeek.clubs[clubName] then
		if _canPost then
			_stores._championshipStore.currentWeek.clubs.store:UpdateAsync(clubName, function(_)
				return _sessionData._championshipStore.currentWeek.clubs[clubName]
			end)
		end
	end
end

function DataSystem:UpdateClubRating(clubName: string, value: number)
	if _sessionData._championshipStore.currentWeek.clubs[clubName] then
		_sessionData._championshipStore.currentWeek.clubs[clubName] = value
	end
end

function DataSystem:GetPlayerRating(userId: number): number
	if not _sessionData._championshipStore.currentWeek.players[userId] then
		_sessionData._championshipStore.currentWeek.players[userId] = _stores._championshipStore.currentWeek.players.store:GetAsync(
			userId
		) or 0
	end

	return _sessionData._championshipStore.currentWeek.players[userId]
end

function DataSystem:PostPlayerRating(userId: number)
	if _sessionData._championshipStore.currentWeek.players[userId] then
		if _canPost then
			_stores._championshipStore.currentWeek.players.store:UpdateAsync(userId, function(_)
				return _sessionData._championshipStore.currentWeek.players[userId]
			end)
		end
	end

	_sessionData._championshipStore.currentWeek.players[userId] = nil
end

function DataSystem:SavePlayerRating(userId: number)
	if _sessionData._championshipStore.currentWeek.players[userId] then
		if _canPost then
			_stores._championshipStore.currentWeek.players.store:UpdateAsync(userId, function(_)
				return _sessionData._championshipStore.currentWeek.players[userId]
			end)
		end
	end
end

function DataSystem:UpdatePlayerRating(userId: number, value: number)
	if not _sessionData._championshipStore.currentWeek.players[userId] then
		_sessionData._championshipStore.currentWeek.players[userId] = _stores._championshipStore.currentWeek.players.store:GetAsync(
			userId
		) or 0
	end

	if _sessionData._championshipStore.currentWeek.players[userId] then
		_sessionData._championshipStore.currentWeek.players[userId] = value
	end
end

function DataSystem:GetClubTopPlayers(clubName: string)
	-- отдельная бд для каждого клуба с рейтингом игроков
	if not _sessionData._clubTopPlayersStore[clubName] then
		_sessionData._clubTopPlayersStore[clubName] =
			getOrderedPlayersData(DataStoreService:GetOrderedDataStore(clubName .. _currentWeek), 50)
	end

	return _sessionData._clubTopPlayersStore[clubName]
end

function DataSystem:UpdateClubTopPlayers(clubName: string)
	if not _sessionData._clubTopPlayersStore[clubName] then
		_sessionData._clubTopPlayersStore[clubName] =
			getOrderedPlayersData(DataStoreService:GetOrderedDataStore(clubName .. _currentWeek), 50)
	end

	-- _sessionData._clubTopPlayersStore[clubName] =
	-- 	getOrderedPlayersData(DataStoreService:GetOrderedDataStore(clubName .. _currentWeek), 50)
end

function DataSystem:GetCurrentWeekTopPlayers()
	if not _sessionData._championshipStore.currentWeek.players then
		_sessionData._championshipStore.currentWeek.players = getOrderedPlayersData(
			_stores._championshipStore.currentWeek.players.store,
			_stores._championshipStore.currentWeek.players.pageSize
		)
	end

	return _sessionData._championshipStore.currentWeek.players
end

function DataSystem:GetLastWeekTopPlayers()
	if not _sessionData._championshipStore.lastWeek.players then
		_sessionData._championshipStore.lastWeek.players = getOrderedPlayersData(
			_stores._championshipStore.lastWeek.players.store,
			_stores._championshipStore.lastWeek.players.pageSize
		)
	end

	return _sessionData._championshipStore.lastWeek.players
end

function DataSystem:GetCurrentWeekTopClubs()
	if not _sessionData._championshipStore.currentWeek.clubs then
		_sessionData._championshipStore.currentWeek.clubs = getOrderedClubsData(
			_stores._championshipStore.currentWeek.clubs.store,
			_stores._championshipStore.currentWeek.clubs.pageSize
		)
	end

	return _sessionData._championshipStore.currentWeek.clubs
end

function DataSystem:GetLastWeekTopClubs()
	if not _sessionData._championshipStore.lastWeek.clubs then
		_sessionData._championshipStore.lastWeek.clubs = getOrderedClubsData(
			_stores._championshipStore.lastWeek.clubs.store,
			_stores._championshipStore.lastWeek.clubs.pageSize
		)
	end

	return _sessionData._championshipStore.lastWeek.clubs
end

return DataSystem
