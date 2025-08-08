local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)

local ClubsGuiModule = {}

-- ===================== Private ===================== --
local _clubsGui, clubsRegistry, clubLeaderboardTemplate, player

local function setupUI()
	for clubType: string, clubs: { [string]: { icon: number } } in clubsRegistry do
        for clubName, icon in clubs do
			-- template:Clone()
        end
    end
end

-- ===================== API ===================== --
function ClubsGuiModule:Initialize(ClientBootstrap: Types.ClientBootstrapType)
	_clubsGui = ClientBootstrap._clientAssets.UI.Clubs

	clubsRegistry = ClientBootstrap.clubsRegistry
	clubLeaderboardTemplate = ClientBootstrap._assets.UI.ClubLeaderboardTemplate
	player = ClientBootstrap.player
end

function ClubsGuiModule:Setup()
	_clubsGui.Parent = player.PlayerGui
	setupUI()
end

function ClubsGuiModule:UpdateClubsMember(clubsMember: { [string]: { number } }) 
    for clubName: string, members: { number } in clubsMember do
        -- findFirstChild
	end
end

function ClubsGuiModule:UpdateClubsRating(clubsRating: { [string]: number }) 
    for clubName: string, rating: number in clubsRating do
        -- findFirstChild
	end
end


return ClubsGuiModule
