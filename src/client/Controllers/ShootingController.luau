local Types = require(script.Parent.Parent.Types)

local ShootingController = {}

-- ===================== Private ===================== --
local _logger, _remotes, _pucksController, _utils, _rewardService

local function createPuckBulletVFX()
	_logger:info(`пуля создана`)
	-- спавн чисто визуала без балистики
end

local function playerWasShooted(player: Player)
	_pucksController:DropPucksFromPlayer(player)
end

local function playerShooting(player: Player, cameraCFrame: CFrame)
	if _utils:ValidatePlayer(player) then
		_logger:info(`игрок {player.Name} выстрелил`)
		createPuckBulletVFX()
		-- local ray = Ray.new(player.Character.HumanoidRootPart.Position, cameraCFrame.LookVector)
		-- RaycastParams.new()
		local shootedPlayer: Player
		if shootedPlayer then
			playerWasShooted(shootedPlayer)
			_rewardService:GiveShootingReward(player)
		end
	else
		_logger:warn(`не валидный игрок {player.Name} для выстрела`)
	end
end

function ShootingController:Initialize(ServerBootstrap: Types.ServerBootstrapType)
	_logger = ServerBootstrap._logger.new(script.Name)
	_utils = ServerBootstrap._utils
	_pucksController = ServerBootstrap._controllers.pucksController
	_rewardService = ServerBootstrap._services.rewardService
	_remotes = ServerBootstrap._remotes
end

function ShootingController:Setup() end

-- ===================== API ===================== --
function ShootingController:Track()
	local callbacks = {
		[_remotes.actions.matchRemoteEvent.fromClient.playerShooting] = playerShooting,
	}
	_remotes:SubscribeMatchRemoteEvent(script.Name, callbacks)
end

function ShootingController:Untrack()
	_remotes:UnsubscribeMatchRemoteEvent(script.Name)
end

return ShootingController
