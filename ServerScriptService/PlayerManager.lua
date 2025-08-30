--!strict
--[=[
	@class PlayerManager
	Manages player data and roles within the game.
]=]
local PlayerManager = {}
PlayerManager.__index = PlayerManager

local Players = game:GetService("Players")

-- Constants
local DEFAULT_HEALTH = 100

-- A table to store the roles of players
local playerRoles = {}
-- A table to store the health of players
local playerHealths = {}


--[=[
	Handles a player joining the game.
]=]
function PlayerManager:OnPlayerAdded(player: Player)
	print("Player added: " .. player.Name)
	-- Assign default health
	playerHealths[player] = DEFAULT_HEALTH
	print(player.Name .. " initialized with " .. DEFAULT_HEALTH .. " health.")
end

--[=[
	Handles a player leaving the game.
]=]
function PlayerManager:OnPlayerRemoving(player: Player)
	print("Player removed: " .. player.Name)
	-- Clean up player data
	playerRoles[player] = nil
	playerHealths[player] = nil
end

--[=[
	Initializes the PlayerManager, connecting to player events.
]=]
function PlayerManager:Init()
	Players.PlayerAdded:Connect(function(player)
		self:OnPlayerAdded(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:OnPlayerRemoving(player)
	end)

	-- Handle any players who are already in the game when this initializes
	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end
end

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

--[=[
	Returns a list of all players with a specific role.
	@param role string The role to search for.
	@return {Player} A list of players with that role.
]=]
function PlayerManager:GetPlayersByRole(role: string)
	local playersWithRole = {}
	for player, playerRole in pairs(playerRoles) do
		if playerRole == role then
			table.insert(playersWithRole, player)
		end
	end
	return playersWithRole
end

--[=[
	Deals damage to a player and handles their death.
	@param player Player The player to damage.
	@param amount number The amount of damage to deal.
]=]
function PlayerManager:TakeDamage(player: Player, amount: number)
	if not playerHealths[player] then
		warn("Attempted to deal damage to a player with no health tracked: " .. player.Name)
		return
	end

	-- Don't damage players who are already eliminated
	if playerHealths[player] <= 0 then
		return
	end

	playerHealths[player] -= amount
	print(player.Name .. " took " .. amount .. " damage, health is now " .. playerHealths[player])

	if playerHealths[player] <= 0 then
		print(player.Name .. " has been eliminated!")
		-- In the future, this will handle respawning, spectating, etc.
		-- For now, we can just set their health to 0 to prevent multiple "deaths"
		playerHealths[player] = 0
	end
end

--[=[
	An action for a killer to attack a target.
	@param killer Player The player performing the attack.
	@param target Player The player receiving the attack.
]=]
function PlayerManager:KillerAttack(killer: Player, target: Player)
	if self:GetRole(killer) ~= "Killer" then
		warn(killer.Name .. " tried to use KillerAttack, but they are not a Killer.")
		return
	end

	print(killer.Name .. " (Killer) is attacking " .. target.Name)
	-- The damage amount can be a constant or based on killer stats later.
	self:TakeDamage(target, 50)
end

return PlayerManager
