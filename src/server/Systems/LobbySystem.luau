local Players = game:GetService("Players")
local Types = require(script.Parent.Parent.Types)

type PadType = Part & {
	ProximityPrompt: ProximityPrompt,
	PlayerBillboardGui: BillboardGui & {
		ImageLabel: ImageLabel,
		TextLabel: TextLabel,
	},
}

local LobbySystem = {}

-- ===================== Private ===================== --
local _logger, _lobby, _remotes, _utils, settings, _zones, _queue, _teamService, _events
local cache

local function updateCounters()
	_lobby.Alien.CounterBillboardGui.TextLabel.Text = `{#_queue.alien} / {settings.maxPlayers}`
	_lobby.Human.CounterBillboardGui.TextLabel.Text = `{#_queue.human} / {settings.maxPlayers}`
	_lobby.Random.CounterBillboardGui.TextLabel.Text = `{#_queue.alien} / {#_queue.human}`
end

local function CheckValidQueueForStart(): boolean
	return _queue.alien	
end

local function updatePadBillboards()
	for teamName: Types.TeamsEnum, pads: { PadType } in _zones do
		for _, pad: PadType in pads do
			if _queue[teamName][pad.Name] then
				--@todo: надо будет закешировать все и скорее всего методы сделать
				local playerAvatar = cache[_queue[teamName][pad.Name]]
					or Players:GetUserThumbnailAsync(
						_queue[teamName][pad.Name],
						Enum.ThumbnailType.AvatarBust,
						Enum.ThumbnailSize.Size420x420
					)

				--@todo: надо будет закешировать все и скорее всего методы сделать
				local playerName = cache[_queue[teamName][pad.Name]]
					or Players:GetNameFromUserIdAsync(_queue[teamName][pad.Name])

				pad.PlayerBillboardGui.ImageLabel.Image = playerAvatar
				pad.PlayerBillboardGui.TextLabel.Text = playerName
			else
				pad.PlayerBillboardGui.ImageLabel.Image = ""
				pad.PlayerBillboardGui.TextLabel.Text = ""
			end
		end
	end
end

local function addPlayerToQueue(teamName: Types.TeamsEnum, padName: string, userId: number)
	if not _queue[teamName][padName] then
		_queue[teamName][padName] = userId
	else
		_logger:warn(`попытка дважды поставить игрока {userId} в очередь`)
	end

	updateCounters()
	updatePadBillboards()


	-- _teamService:AddLobbyQueueToTeamsData(_queue)
	-- _events:GameEventFire().startGame()
end

local function removePlayerFromQueue(teamName: Types.TeamsEnum, padName: string, userId: number)
	if _queue[teamName][padName] then
		_queue[teamName][padName] = nil
	else
		_logger:warn(`попытка удалить из очереди игрока не в очереди {userId}`)
	end

	updateCounters()
	updatePadBillboards()
end

local function setupPlayerToPad(player: Player, pad: PadType)
	if _utils:ValidatePlayer(player) then
		player.Character:PivotTo(pad.CFrame * CFrame.new(0, 5, 0))
	else
		_logger:warn(
			`попытка установить на пэд не валидного игрока {player.UserId}`
		)
	end
end

local function removePlayerFromPad(player: Player)
	if _utils:ValidatePlayer(player) then
		player.Character:PivotTo(_lobby.Random.CFrame * CFrame.new(0, 5, 0))
	else
		_logger:warn(`попытка убрать с пэда не валидного игрока {player.UserId}`)
	end
end

local function setupZones()
	local function onTriggered(player: Player, pad: PadType, teamName: Types.TeamsEnum)
		if _teamService:CanJoinToTeam(teamName) then
			addPlayerToQueue(teamName, pad.Name, player.UserId)
			setupPlayerToPad(player, pad)
			_remotes:LobbyRemoteEventFireClient(player).setToPad({ padName = pad.Name, teamName = teamName })
		else
			_remotes:ServeRemoteEventFireClient().smallNotification(
				`команда {teamName == "alien" and "Пришельцы" or "Земляне"} меньше другой команды, перейдите на другую сторону`
			)
		end
	end

	for teamName: Types.TeamsEnum, pads: { PadType } in _zones do
		for _, pad: PadType in pads do
			local function _onTriggered(player: Player)
				onTriggered(player, pad, teamName)
			end

			local conn = pad.ProximityPrompt.Triggered:Connect(_onTriggered)
			_utils:AddConnectToGameClose(`{script.Name}_{pad.Name}`, conn)
		end
	end
end

local function goToPadsZone(player: Player)
	if _utils:ValidatePlayer(player) and player.Neutral then
		player.Character:PivotTo(_lobby.Random.CFrame)
	end
end

local function goToMatch(player: Player)
	
end

local function subscribeLobbyRemoteEvent()
	local callbacks = {
		[_remotes.actions.lobbyRemoteEvent.fromClient.quitFromPad] = function(
			player: Player,
			data: {
				padName: string,
				teamName: Types.TeamsEnum,
			}
		)
			removePlayerFromQueue(data.teamName, data.padName, player.UserId)
			removePlayerFromPad(player)
		end,
		[_remotes.actions.lobbyRemoteEvent.fromClient.goToPadsZone] = goToPadsZone,
		[_remotes.actions.lobbyRemoteEvent.fromClient.goToMatch] = goToMatch,
	}
	_remotes:SubscribeLobbyRemoteEvent(script.Name, callbacks)
end

function LobbySystem:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
	_lobby = ServerBootstrap._workspace.lobby
	_remotes = ServerBootstrap._remotes
	_events = ServerBootstrap._events
	_utils = ServerBootstrap._utils
	_teamService = ServerBootstrap._services.teamService

	cache = ServerBootstrap.cache
	settings = ServerBootstrap.settings

	_zones = {
		alien = self._lobby.Alien.Pads:GetChildren(),
		human = self._lobby.Human.Pads:GetChildren(),
	}

	_queue = {
		alien = {} :: { number },
		human = {} :: { number },
	}
end

function LobbySystem:Setup()
	setupZones()
	subscribeLobbyRemoteEvent()
end

-- ===================== API ===================== --
-- @question: возможно етот метод нет смысла исопльзовать так как будет LoadCharacter()
function LobbySystem:SetPlayerToLobby(player: Player)
	if _utils:ValidatePlayer(player) then
		player.Character:PivotTo(_lobby.SpawnLocation.CFrame * CFrame.new(0, 5, 0))
	end
end

function LobbySystem:SetShowBillboards(state: boolean)
	for _, pads: { PadType } in _zones do
		for _, pad: PadType in pads do
			pad.PlayerBillboardGui.Enabled = state
		end
	end
end

function LobbySystem:ClearQueue()
	_queue.alien = {}
	_queue.human = {}
end

return LobbySystem
