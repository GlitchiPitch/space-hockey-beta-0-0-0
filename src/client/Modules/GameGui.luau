local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local GameGuiModule = {}

-- ===================== Private ===================== --
local _gameGuiTemplate, player
local _gameGui

local function setupUI()
    --@notImplemented
end

function GameGuiModule:Initialize(ClientBootstrap: Types.ClientBootstrapType)
    player = ClientBootstrap.player
    _gameGuiTemplate = ClientBootstrap._assets.UI.Game
end

function GameGuiModule:Setup()
end

-- ===================== API ===================== --
function GameGuiModule:SetActive(state: boolean)
    if state then
        _gameGui = _gameGuiTemplate:Clone()
        _gameGui.Parent = player.PlayerGui
        setupUI()
    else
        _gameGui:Destroy()
    end
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