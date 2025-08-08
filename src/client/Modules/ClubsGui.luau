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

local function updateClubMemberUI() end

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

function ClubsGuiModule:UpdateClubMembers(data: Types.receiveClubMembersType)
	local clubFrame = _clubsGui:FindFirstChild(data.clubName)
	clubFrame.MembersLabel.Text = data.clubMembers
	-- updateClubMemberUI()
end

function ClubsGuiModule:UpdateClubRating(data: Types.receiveClubRatingType)
	local clubFrame = _clubsGui:FindFirstChild(data.clubName)
	clubFrame.RatingLabel.Text = data.rating
end

return ClubsGuiModule
