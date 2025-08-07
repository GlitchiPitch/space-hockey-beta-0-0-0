local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

--[[
    -- есть неявная зависимость для модулей, в модули передается ClientBootstrap
]]
local UIService = {}

-- ===================== Private ===================== --
local _logger, _remotes, _utils, _clientBootstrap
local player

local _validScreensForButtonsCooldown = {
    "Game"
}

local function subscribeUIRemoteEvent()
	local callbacks = {}
	_remotes:SubscribeUIRemoteEvent(script.Name, callbacks)
end

local function setupUI()
   _utils:InitializeModules(UIService._guiModules, _logger, _clientBootstrap)
   _utils:SetupModules(UIService._guiModules, _logger)
end

local function setButtonsCooldown()
    local function onPlayerGuiChildAdded(child: ScreenGui)
        if not table.find(_validScreensForButtonsCooldown, child.Name) then
            for _, v in child:GetDescendants() do
                if v:IsA("GuiButton") then
                    local function onClick()
                        v.Interactable = false
                        task.wait(1)
                        v.Interactable = true
                    end
                    v.MouseButton1Click:Connect(onClick)
                end
            end
        end
    end
    player.PlayerGui.ChildAdded:Connect(onPlayerGuiChildAdded)
end

local function setCurrentGui(guiName: string)
    if UIService._guiModules[guiName] then
        for _guiName: string, guiModule: { SetActive: (_: any, state: boolean) -> () } in UIService._guiModules do
            guiModule:SetActive(_guiName == guiName)
        end
    else
        _logger:warn(`попытка переключится на несуществующий гуи {guiName}`)
    end
end

function UIService:Initialize(ClientBootstrap: Types.ClientBootstrapType)
    _clientBootstrap = ClientBootstrap
	_logger = ClientBootstrap._logger.new(script.Name)
    _utils = ClientBootstrap._utils
	_remotes = ClientBootstrap._remotes

    player = ClientBootstrap.player

    self._guiModules = {
        mainGui = require(script.Parent.Parent.Modules.MainGui),
        gameGui = require(script.Parent.Parent.Modules.GameGui),
        finalGui = require(script.Parent.Parent.Modules.FinalGui),
    }
end

function UIService:Setup()
    setupUI()
    subscribeUIRemoteEvent()
    setButtonsCooldown()
end

-- ===================== API ===================== --
function UIService:SetCurrentGui()
    return {
        mainGui = function()
            setCurrentGui("mainGui")
        end,
        gameGui = function()
            setCurrentGui("gameGui")
        end,
        finalGui = function()
            setCurrentGui("finalGui")
        end,
    }
end

function UIService:SetTransition(state: boolean)
    --@notImplemented
end

return UIService
