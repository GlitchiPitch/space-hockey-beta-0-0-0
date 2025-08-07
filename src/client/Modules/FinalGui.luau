local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local FinalGuiModule = {}

-- ===================== Private ===================== --
-- @todo: надо привести в порядок приватные переменные
local _logger, _finalLocationTemplate, _characterTemplate, _utils
local _finalLocation, _finalGuiTemplate, _finalGui, player


local function setCharacters(finalData: Types.FinalDataType)
    for teamName: Types.TeamsEnum, team: Types.FinalTeamDataType in finalData.teams do
        for index, playerData in team do
            if teamName == finalData.playerTeam then
                if _utils:ValidatePlayer(playerData.userId) then
                    local character = _characterTemplate:Clone()
                    --@notImplemented
                end
            end
        end
    end
end

local function setLocation(state: boolean)
    if state then
        _finalLocation = _finalLocationTemplate:Clone()
        _finalLocation.Parent = workspace
    else
        _finalLocation:Destroy()
    end
end

local function setData(finalData: Types.FinalDataType)
    for teamName: Types.TeamsEnum, team: Types.FinalTeamDataType in finalData.teams do
        for index, playerData in team do
            -- setLeaderboard(teamName, index, playerData)
            --@notImplemented
        end
    end
end

function FinalGuiModule:Initialize(ClientBootstrap: Types.ClientBootstrapType)
    _utils = ClientBootstrap._utils
    _finalLocationTemplate = ClientBootstrap._assets.FinalLocation.Location
    _characterTemplate = ClientBootstrap._assets.FinalLocation.CharacterTemplate

    _finalGuiTemplate = ClientBootstrap._assets.UI.Final

    player = ClientBootstrap.player
end

function FinalGuiModule:Setup()
    
end

-- ===================== API ===================== --
function FinalGuiModule:SetFinal(finalData: Types.FinalDataType)
    setLocation(true)
    setData(finalData)
    setCharacters(finalData)
end

function FinalGuiModule:SetActive(state: boolean)
    if state then
        _finalGui = _finalGuiTemplate:Clone()
        _finalGui.Parent = player.PlayerGui
    else
        _finalGui:Destroy()
    end
end

return FinalGuiModule