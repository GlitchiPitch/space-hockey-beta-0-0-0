local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local PlayerService = {}

-- ===================== Private ===================== --
local _logger, _remotes, _playerControl

function PlayerService:Initialize(ClientBootstrap: Types.ClientBootstrapType)
	_logger = ClientBootstrap._logger.new(script.Name)
	_remotes = ClientBootstrap._remotes
	_playerControl = require(ClientBootstrap.player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end

function PlayerService:Setup() end


-- ===================== API ===================== --
function PlayerService:SetControl(state: boolean)
	if state then
		_playerControl:Enable()
	else
		_playerControl:Disable()
	end
end

return PlayerService
