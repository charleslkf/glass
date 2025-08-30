--!strict
--[=[
	@class PlayerManager
	Manages player data and roles within the game.
]=]
local PlayerManager = {}
PlayerManager.__index = PlayerManager

local Players = game:GetService("Players")

-- A table to store the roles of players
local playerRoles = {}

--[=[
	Assigns roles to all players currently in the game.
	It randomly selects one player as the "Killer" and the rest as "Survivors".
]=]
function PlayerManager:AssignRoles()
	local allPlayers = Players:GetPlayers()
	if #allPlayers == 0 then return end

	-- Reset roles
	for player, _ in pairs(playerRoles) do
		playerRoles[player] = nil
	end

	-- Select a random killer
	local killerIndex = math.random(1, #allPlayers)
	local killer = allPlayers[killerIndex]

	-- Assign roles
	for i, player in ipairs(allPlayers) do
		if i == killerIndex then
			playerRoles[player] = "Killer"
			print(player.Name .. " has been chosen as the Killer.")
		else
			playerRoles[player] = "Survivor"
			print(player.Name .. " is a Survivor.")
		end
	end
end

--[=[
	Returns the role of a specific player.
	@param player Player The player whose role is being requested.
	@return string The role of the player ("Killer", "Survivor", or "Unknown").
]=]
function PlayerManager:GetRole(player: Player)
	return playerRoles[player] or "Unknown"
end

return PlayerManager
