local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")
local PlayerDataTemplate = require(ReplicatedStorage.Shared.PlayerDataTemplate)
local ClientBootstrap = require(StarterPlayer.StarterPlayerScripts.Client.ClientBootstrap)

export type ClientBootstrapType = ClientBootstrap.ClientBootstrapType
export type TeamsEnum = "alien" | "human"

export type PlayerDataType = PlayerDataTemplate.PlayerDataTemplateType
export type TopClubOrderedDataType = { clubName: string, rating: number }
export type TopPlayerOrderedDataType = { userId: number, rating: number }
export type TopClubsDataType = { [number]: TopClubOrderedDataType }
export type TopPlayersDataType = { [number]: TopPlayerOrderedDataType }

export type GamePlayerDataType = {
	shootingCooldown: number,
	stickCharge: number,
	shootingScore: number,
	sprint: boolean,
	goals: number,
	score: number,
}

export type GameDataType = {
    score: {
        alien: number,
        human: number,
    },
    -- @question: надо подумать есть ли смысл отправлять винера
    -- currentRound: number,
    -- winner: string?
}

export type FinalPlayerDataType = { userId: number, score: number, shootingScore: number, goals: number }
export type FinalTeamDataType = { FinalPlayerDataType }
export type FinalDataType = {
    teams: {
        alien: FinalTeamDataType,
        human: FinalTeamDataType,
    },
    winner: TeamsEnum?,
    playerTeam: TeamsEnum,
}

return {}
