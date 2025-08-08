--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ServerBootstrap = {}

-- ===================== Private ===================== --
local onRender: RBXScriptConnection
local _updatePool = {
	updateClubsRating = {
		updateTime = 5,
		deltaTime = 0,
		action = function()
			ServerBootstrap._systems.championshipSystem:UpdateClubsRating()
		end,
	},
} :: { [string]: { updateTime: number, deltaTime: number, action: () -> () } }

local function _onRender(deltaTime: number)
	for _, v in _updatePool do
		v.deltaTime += deltaTime
		if v.deltaTime >= v.updateTime then
			v.deltaTime = 0
			v.action()
		end
	end
end

-- ===================== API ===================== --
function ServerBootstrap:Initialize()
	self._systems = {
		lobbySystem = require(script.Parent.Systems.LobbySystem),
		dataSystem = require(script.Parent.Systems.DataSystem),
		inventorySystem = require(script.Parent.Systems.InventorySystem),
		matchSystem = require(script.Parent.Systems.MatchSystem),
		clubSystem = require(script.Parent.Systems.ClubSystem),
		championshipSystem = require(script.Parent.Systems.ChampionshipSystem),
		miniGamesSystem = require(script.Parent.Systems.MiniGamesSystem),
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
		aeroHockeyController = require(script.Parent.Controllers.AeroHockeyController),
		mazeController = require(script.Parent.Controllers.MazeController),
	}

	self._managers = {
		gameManager = require(script.Parent.Managers.GameManager),
		dailyRewardManager = require(script.Parent.Managers.DailyRewardManager),
	}

	self._handlers = {
		tutorialHandler = require(script.Parent.Handlers.TutorialHandler),
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
	self.clubsRegistry = require(ReplicatedStorage.Shared.ClubsRegistry)

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

	onRender = RunService.Heartbeat:Connect(_onRender)
	self._utils:AddConnectToGameClose(`{script.Name}_onRender`, onRender)
end

export type ServerBootstrapType = typeof(ServerBootstrap)

return ServerBootstrap
