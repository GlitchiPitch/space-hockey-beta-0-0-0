local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local GameGuiModule = {}

-- ===================== Private ===================== --
local player
local _gameGui

local function setupUI()
    --@notImplemented
end

-- ===================== API ===================== --
function GameGuiModule:Initialize(ClientBootstrap: Types.ClientBootstrapType)
    player = ClientBootstrap.player
    _gameGui = ClientBootstrap._clientAssets.UI.Game
end

function GameGuiModule:Setup()
    _gameGui.Parent = player.PlayerGui
end

function GameGuiModule:SetActive(state: boolean)
    _gameGui.Enabled = state
end

function GameGuiModule:UpdateGameData(gameData: Types.GameDataType)
    _gameGui.Panel.AlienScoreLabel.Text = gameData.score.alien
    _gameGui.Panel.HumanScoreLabel.Text = gameData.score.human
end

function GameGuiModule:UpdateRoundTimer(_time: number)
    
end

function GameGuiModule:UpdateRoundCount(_roundCount: number)
    
end

return GameGuiModule