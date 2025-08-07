local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerBootstrap = require(script.Parent.ServerBootstrap)
local SharedTypes = require(ReplicatedStorage.Shared.Types)

export type ServerBootstrapType = ServerBootstrap.ServerBootstrapType
export type TeamsEnum = SharedTypes.TeamsEnum
export type TeamDataType = { score: number, players: { number } }

export type TopClubOrderedDataType = SharedTypes.TopClubOrderedDataType
export type TopPlayerOrderedDataType = SharedTypes.TopPlayerOrderedDataType
export type TopClubsDataType = SharedTypes.TopClubsDataType
export type TopPlayersDataType = SharedTypes.TopPlayersDataType
export type PlayerDataType = SharedTypes.PlayerDataType
export type GamePlayerDataType = SharedTypes.GamePlayerDataType
export type FinalDataType = SharedTypes.FinalDataType

return {}
