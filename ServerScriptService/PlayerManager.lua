--!strict
--[=[
	@class PlayerManager
	Manages player data and roles within the game.
]=]
local PlayerManager = {}
PlayerManager.__index = PlayerManager

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Constants
local DEFAULT_HEALTH = 100

-- A table to store the roles of players
local playerRoles = {}
-- A table to store the health of players
local playerHealths = {}

-- Create a container in ReplicatedStorage for roles
local playerRolesContainer = Instance.new("Configuration")
playerRolesContainer.Name = "PlayerRoles"
playerRolesContainer.Parent = ReplicatedStorage

--[=[
	Handles a player joining the game.
]=]
function PlayerManager:OnPlayerAdded(player: Player)
	print("Player added: " .. player.Name)
	-- Assign default health
	playerHealths[player] = DEFAULT_HEALTH
	print(player.Name .. " initialized with " .. DEFAULT_HEALTH .. " health.")

	-- Handle character loading
	player.CharacterAdded:Connect(function(character)
		self:OnCharacterAdded(player, character)
	end)

	-- Handle character if it's already loaded
	if player.Character then
		self:OnCharacterAdded(player, player.Character)
	end
end

--[=[
	Handles a player's character spawning into the game.
]=]
function PlayerManager:OnCharacterAdded(player: Player, character: Model)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 6)
	if not humanoidRootPart then
		warn("Could not find HumanoidRootPart for " .. player.Name .. " after waiting.")
		return
	end

	-- Add a ClickDetector to allow other players to interact with this character
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = humanoidRootPart

	clickDetector.MouseClick:Connect(function(attackerPlayer)
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
	-- Clean up replicated role
	local roleValue = playerRolesContainer:FindFirstChild(tostring(player.UserId))
	if roleValue then
		roleValue:Destroy()
	end
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

	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end
end

--[=[
	Assigns roles to all players currently in the game.
]=]
function PlayerManager:AssignRoles()
	local allPlayers = Players:GetPlayers()
	local playerCount = #allPlayers
	if playerCount == 0 then return end

	local AbilityManager = require(game:GetService("ServerScriptService").AbilityManager)

	-- Reset all current roles
	for player, _ in pairs(playerRoles) do playerRoles[player] = nil end
	playerRolesContainer:ClearAllChildren()

	local availablePlayers = {}
	for _, p in ipairs(allPlayers) do table.insert(availablePlayers, p) end

	-- Helper to set and replicate role
	local function setRole(player, role)
		playerRoles[player] = role
		playerRolesContainer:SetAttribute(tostring(player.UserId), role)
		print(player.Name .. " is the " .. role)
	end

	-- 1. Select the Killer
	local killerIndex = math.random(1, playerCount)
	local killer = availablePlayers[killerIndex]
	setRole(killer, "Killer")
	AbilityManager:EquipAbility(killer, "DefaultKillerAbility")
	table.remove(availablePlayers, killerIndex)

	-- 2. Select a Stunner
	if #availablePlayers > 0 then
		local stunnerIndex = math.random(1, #availablePlayers)
		local stunner = availablePlayers[stunnerIndex]
		setRole(stunner, "Stunner")
		AbilityManager:EquipAbility(stunner, "StunnerAbility")
		table.remove(availablePlayers, stunnerIndex)
	end

	-- 3. Select a Helper
	if #availablePlayers > 0 then
		local helperIndex = math.random(1, #availablePlayers)
		local helper = availablePlayers[helperIndex]
		setRole(helper, "Helper")
		AbilityManager:EquipAbility(helper, "HelperAbility")
		table.remove(availablePlayers, helperIndex)
	end

	-- 4. Assign the rest as Survivors
	for _, player in ipairs(availablePlayers) do
		setRole(player, "Survivor")
		AbilityManager:EquipAbility(player, "DefaultSurvivorAbility")
	end
end

--[=[
	Returns the role of a specific player.
]=]
function PlayerManager:GetRole(player: Player)
	return playerRoles[player] or "Unknown"
end

--[=[
	Returns a list of all players with a specific role.
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
]=]
function PlayerManager:TakeDamage(player: Player, amount: number)
	if not playerHealths[player] or playerHealths[player] <= 0 then return end

	playerHealths[player] -= amount
	print(player.Name .. " took " .. amount .. " damage, health is now " .. playerHealths[player])

	if playerHealths[player] <= 0 then
		print(player.Name .. " has been eliminated!")
		playerHealths[player] = 0
	end
end

--[=[
	An action for a killer to attack a target.
]=]
function PlayerManager:KillerAttack(killer: Player, target: Player)
	if self:GetRole(killer) ~= "Killer" then
		warn(killer.Name .. " tried to use KillerAttack, but they are not a Killer.")
		return
	end

	print(killer.Name .. " (Killer) is attacking " .. target.Name)
	self:TakeDamage(target, 50)
end

--[=[
	Heals a player for a given amount, capping at their max health.
	@param player Player The player to heal.
	@param amount number The amount of health to restore.
]=]
function PlayerManager:HealPlayer(player: Player, amount: number)
	if not playerHealths[player] or playerHealths[player] <= 0 then return end

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	playerHealths[player] = math.min(playerHealths[player] + amount, humanoid.MaxHealth)
	print(player.Name .. " was healed for " .. amount .. ", health is now " .. playerHealths[player])
end

return PlayerManager
