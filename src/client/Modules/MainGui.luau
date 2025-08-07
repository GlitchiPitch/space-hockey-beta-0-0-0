local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local MainUIModule = {}

-- ===================== Private ===================== --
local _mainGui, _utils, _lobbySystem
local player
local _lobbyQuitPadCallback: () -> ()
local _connections: {
	onPadQuitButtonClick: RBXScriptConnection,
	onGoToPadZoneButtonClick: RBXScriptConnection,
}

local function setupUI()
	local function onPadQuitButtonClick()
		_lobbyQuitPadCallback()
		_mainGui.PadQuitButton.Visible = false
	end

	local function onGoToPadZoneButtonClick()
		_lobbySystem:GoToPadsZone()
	end

	_connections.onPadQuitButtonClick = _mainGui.PadQuitButton.MouseButton1Click:Connect(onPadQuitButtonClick)
	_connections.onGoToPadZoneButtonClick =
		_mainGui.GoToPadZone.GoToPadZoneButton.MouseButton1Click:Connect(onGoToPadZoneButtonClick)
end

-- ===================== API ===================== --
function MainUIModule:Initialize(ClientBootstrap: Types.ClientBootstrapType)
	_mainGui = ClientBootstrap._clientAssets.UI.Main
	_utils = ClientBootstrap._utils
	_lobbySystem = ClientBootstrap._systems.lobbySystem
	player = ClientBootstrap.player
end

function MainUIModule:Setup()
	_mainGui.Parent = player.PlayerGui
	setupUI()
end

function MainUIModule:ShowPadQuitButton(lobbyQuitPadCallback: () -> ())
	_mainGui.PadQuitButton.Visible = true
	_lobbyQuitPadCallback = lobbyQuitPadCallback
end

function MainUIModule:SetPrepareMatchTimer(_time: number)
	_mainGui.PrepareToMatch.Visible = _time > 0
	_mainGui.PrepareToMatch.TextLabel.Text = `Матч начнется через: {_time}`
end

function MainUIModule:SetActive(state: boolean)
	_mainGui.Enabled = state
end

return MainUIModule
