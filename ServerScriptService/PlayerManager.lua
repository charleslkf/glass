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

	-- Handle character loading
	print("[Debug] Setting up CharacterAdded connection for " .. player.Name)
	player.CharacterAdded:Connect(function(character)
		print("[Debug] CharacterAdded event fired for " .. player.Name)
		self:OnCharacterAdded(player, character)
	end)

	-- Handle character if it's already loaded
	if player.Character then
		print("[Debug] Character for " .. player.Name .. " already exists. Firing OnCharacterAdded manually.")
		self:OnCharacterAdded(player, player.Character)
	else
		print("[Debug] Character for " .. player.Name .. " does not exist yet.")
	end
end

--[=[
	Handles a player's character spawning into the game.
]=]
function PlayerManager:OnCharacterAdded(player: Player, character: Model)
	print("[Debug] OnCharacterAdded called for " .. player.Name)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 6) -- Wait up to 6 seconds

	if not humanoidRootPart then
		warn("[Debug] Could not find HumanoidRootPart for " .. player.Name .. " after waiting.")
		return
	end
	print("[Debug] Found HumanoidRootPart for " .. player.Name)

	-- Add a ClickDetector to allow other players to interact with this character
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10 -- How close the attacker must be
	clickDetector.Parent = humanoidRootPart

	clickDetector.MouseClick:Connect(function(attackerPlayer)
		-- When a player clicks on this character, treat it as an attack
		self:KillerAttack(attackerPlayer, player)
	end)

	print("Added ClickDetector to " .. player.Name)
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
	It selects one Killer, then assigns Stunner and Helper roles from the remaining players if possible.
]=]
function PlayerManager:AssignRoles()
	local allPlayers = Players:GetPlayers()
	local playerCount = #allPlayers
	if playerCount == 0 then return end

	-- Reset all current roles
	for player, _ in pairs(playerRoles) do
		playerRoles[player] = nil
	end

	-- Create a temporary list of players to pick from
	local availablePlayers = {}
	for _, p in ipairs(allPlayers) do
		table.insert(availablePlayers, p)
	end

	-- 1. Select the Killer
	local killerIndex = math.random(1, playerCount)
	local killer = availablePlayers[killerIndex]
	playerRoles[killer] = "Killer"
	table.remove(availablePlayers, killerIndex)
	print(killer.Name .. " has been chosen as the Killer.")

	-- 2. Select a Stunner if there are enough players left
	if #availablePlayers > 0 then
		local stunnerIndex = math.random(1, #availablePlayers)
		local stunner = availablePlayers[stunnerIndex]
		playerRoles[stunner] = "Stunner"
		table.remove(availablePlayers, stunnerIndex)
		print(stunner.Name .. " is the Stunner.")
	end

	-- 3. Select a Helper if there are enough players left
	if #availablePlayers > 0 then
		local helperIndex = math.random(1, #availablePlayers)
		local helper = availablePlayers[helperIndex]
		playerRoles[helper] = "Helper"
		table.remove(availablePlayers, helperIndex)
		print(helper.Name .. " is the Helper.")
	end

	-- 4. Assign the rest as Survivors
	for _, player in ipairs(availablePlayers) do
		playerRoles[player] = "Survivor"
		print(player.Name .. " is a Survivor.")
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
