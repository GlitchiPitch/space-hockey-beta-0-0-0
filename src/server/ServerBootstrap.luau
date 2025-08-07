--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerBootstrap = {}

function ServerBootstrap:Initialize()
	self._systems = {
		lobbySystem = require(script.Parent.Systems.LobbySystem),
		dataSystem = require(script.Parent.Systems.DataSystem),
		inventorySystem = require(script.Parent.Systems.InventorySystem),
		matchSystem = require(script.Parent.Systems.MatchSystem),
		clubSystem = require(script.Parent.Systems.ClubSystem),
		championshipSystem = require(script.Parent.Systems.ChampionshipSystem),
	}

	self._services = {
		playerService = require(script.Parent.Services.PlayerService),
		leaderboardService = require(script.Parent.Services.LeaderboardService),
		teamService = require(script.Parent.Services.TeamService),
		rewardService = require(script.Parent.Services.RewardService),
		badgeService = require(script.Parent.Services.BadgeService),
	}

	self._controllers = {
		flyingController = require(script.Parent.Controllers.FlyingController),
		gatesController = require(script.Parent.Controllers.GatesController),
		pucksController = require(script.Parent.Controllers.PucksController),
		shootingController = require(script.Parent.Controllers.ShootingController),
	}

	self._managers = {
		gameManager = require(script.Parent.Managers.GameManager),
	}

	self._remotes = require(ReplicatedStorage.Shared.Remotes.RemoteEventManager)
	self._events = require(ReplicatedStorage.Shared.Events.EventManager)

	self._workspace = {
		clubLeaderboard = workspace.ClubLeaderboard,
		playerLeaderboard = workspace.PlayerLeaderboard,
		lobby = workspace.Lobby,
		game = workspace.Game,
	}

	self._assets = ReplicatedStorage.Shared.Assets

	self._utils = require(ReplicatedStorage.Shared.Utils)
	self._logger = require(ReplicatedStorage.Shared.Logger)
	self.settings = require(ReplicatedStorage.Shared.Settings)
	self.config = require(ReplicatedStorage.Shared.Config)
	self.constants = require(ReplicatedStorage.Shared.Constants)
	self.cache = require(ReplicatedStorage.Shared.Cache)

	self.__mainLogger = self._logger.new(script.Name)
	self.__mainLogger:info(`Initialize`)
end

function ServerBootstrap:Setup()
	-- initialize all modules
    self._utils:InitializeModules(self._systems, self.__mainLogger, self)
    self._utils:InitializeModules(self._services, self.__mainLogger, self)
	
	-- setup all modules
	self._utils:SetupModules(self._systems, self.__mainLogger)
	self._utils:SetupModules(self._services, self.__mainLogger)
	self.__mainLogger:info(`Setup`)
end

export type ServerBootstrapType = typeof(ServerBootstrap)

return ServerBootstrap
