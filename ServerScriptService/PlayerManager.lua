--!strict
--[=[
	@class PlayerManager
	Manages player data and roles within the game.
]=]
local PlayerManager = {}
PlayerManager.__index = PlayerManager

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local EventManager = require(ServerScriptService.EventManager)

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
	-- This function is now empty. The ClickDetector logic has been removed
	-- and replaced with a client-side detection system.
end

--[=[
	Handles a player leaving the game.
]=]
function PlayerManager:OnPlayerRemoving(player: Player)
	print("Player removed: " .. player.Name)
	playerRoles[player] = nil
	playerHealths[player] = nil
	playerRolesContainer:SetAttribute(tostring(player.UserId), nil)
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

	EventManager.PlayerAttackEvent.OnServerEvent:Connect(function(attackerPlayer, targetPlayer)
		self:KillerAttack(attackerPlayer, targetPlayer)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end
end

--[=[
	Assigns roles to all players currently in the game.
	It randomly selects one player to be the Killer and the rest to be Survivors.
]=]
function PlayerManager:AssignRoles()
	local allPlayers = Players:GetPlayers()
	if #allPlayers == 0 then
		print("No players to assign roles to.")
		return
	end

	-- Clear out old roles
	for player, _ in pairs(playerRoles) do
		playerRoles[player] = nil
	end
	playerRolesContainer:ClearAllChildren()

	local AbilityManager = require(game:GetService("ServerScriptService").AbilityManager)

	-- Create a temporary copy to avoid modifying the original list from GetPlayers()
	local playersToAssign = {}
	for _, p in ipairs(allPlayers) do
		table.insert(playersToAssign, p)
	end

	-- Select a random Killer
	if #playersToAssign > 0 then
		local killerIndex = math.random(1, #playersToAssign)
		local killerPlayer = table.remove(playersToAssign, killerIndex)

		-- Assign Killer role
		playerRoles[killerPlayer] = "Killer"
		playerRolesContainer:SetAttribute(tostring(killerPlayer.UserId), "Killer")
		AbilityManager:EquipAbility(killerPlayer, "DefaultKillerAbility")
		print(killerPlayer.Name .. " is the Killer")
	end

	-- Assign Survivor role to the rest
	for _, survivorPlayer in ipairs(playersToAssign) do
		playerRoles[survivorPlayer] = "Survivor"
		playerRolesContainer:SetAttribute(tostring(survivorPlayer.UserId), "Survivor")
		AbilityManager:EquipAbility(survivorPlayer, "DefaultSurvivorAbility")
		print(survivorPlayer.Name .. " is a Survivor")
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

	-- Play sound effect for the attack
	if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		EventManager.PlaySoundEvent:FireAllClients("KillerAttack", target.Character.HumanoidRootPart.Position)
	end
end

--[=[
	Heals a player for a given amount, capping at their max health.
]=]
function PlayerManager:HealPlayer(player: Player, amount: number)
	if not playerHealths[player] or playerHealths[player] <= 0 then return end

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	playerHealths[player] = math.min(playerHealths[player] + amount, humanoid.MaxHealth)
	print(player.Name .. " was healed for " .. amount .. ", health is now " .. playerHealths[player])
end

return PlayerManager
