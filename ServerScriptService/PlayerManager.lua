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
	local humanoid = character:WaitForChild("Humanoid", 6)
	if not humanoid then
		warn("Could not find Humanoid for " .. player.Name .. " after waiting.")
		return
	end

	-- Add a ClickDetector to the Humanoid to allow other players to attack them.
	-- Parenting to the Humanoid is more reliable than parenting to a specific part.
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = humanoid

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

	for _, player in ipairs(Players:GetPlayers()) do
		self:OnPlayerAdded(player)
	end
end

--[=[
	Assigns roles to all players currently in the game.
]=]
function PlayerManager:AssignRoles()
	local allPlayers = Players:GetPlayers()
	table.sort(allPlayers, function(a, b) return a.Name < b.Name end)

	if #allPlayers == 0 then return end

	local AbilityManager = require(game:GetService("ServerScriptService").AbilityManager)

	for player, _ in pairs(playerRoles) do playerRoles[player] = nil end
	playerRolesContainer:ClearAllChildren()

	local function setRole(player, role)
		playerRoles[player] = role
		playerRolesContainer:SetAttribute(tostring(player.UserId), role)
		print(player.Name .. " is the " .. role)
	end

	local testRoles = {"Killer", "Stunner", "Helper", "Survivor"}

	for i, player in ipairs(allPlayers) do
		local role = testRoles[i] or "Survivor"
		setRole(player, role)

		if role == "Killer" then
			AbilityManager:EquipAbility(player, "DefaultKillerAbility")
		elseif role == "Stunner" then
			AbilityManager:EquipAbility(player, "StunnerAbility")
		elseif role == "Helper" then
			AbilityManager:EquipAbility(player, "HelperAbility")
		else -- Survivor
			AbilityManager:EquipAbility(player, "DefaultSurvivorAbility")
		end
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
