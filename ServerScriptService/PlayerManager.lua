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
-- A table to store the state of players
local playerStates = {}

-- Create a container in ReplicatedStorage for roles
local playerRolesContainer = Instance.new("Configuration")
playerRolesContainer.Name = "PlayerRoles"
playerRolesContainer.Parent = ReplicatedStorage

-- Create a container in ReplicatedStorage for states
local playerStatesContainer = Instance.new("Configuration")
playerStatesContainer.Name = "PlayerStates"
playerStatesContainer.Parent = ReplicatedStorage

--[=[
	Sets the state for a player and replicates it.
]=]
function PlayerManager:SetPlayerState(player: Player, state: string)
	playerStates[player] = state
	playerStatesContainer:SetAttribute(tostring(player.UserId), state)
	print(player.Name .. "'s state changed to: " .. state)

	-- Handle character state
	local character = player.Character
	if character and character:FindFirstChildOfClass("Humanoid") then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if state == "Downed" then
			humanoid.WalkSpeed = 5 -- Slowed down
			humanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding) -- Forces them to the ground
		elseif state == "Carried" then
			humanoid.WalkSpeed = 0
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		elseif state == "Carrying" then
			humanoid.WalkSpeed = 14 -- Slightly slower than default 16
		elseif state == "Hooked" then
			humanoid.WalkSpeed = 0
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		elseif state == "Healthy" or state == "Injured" then
			humanoid.WalkSpeed = 16 -- Default speed
		end
	end

	-- Fire an event for other systems to listen to
	EventManager.PlayerStateChangedEvent:FireAllClients(player, state)
end

--[=[
	Gets the state of a specific player.
]=]
function PlayerManager:GetPlayerState(player: Player)
	return playerStates[player]
end

--[=[
	Handles a player joining the game.
]=]
function PlayerManager:OnPlayerAdded(player: Player)
	print("Player added: " .. player.Name)
	-- Assign default health
	playerHealths[player] = DEFAULT_HEALTH
	self:SetPlayerState(player, "Healthy")
	print(player.Name .. " initialized with " .. DEFAULT_HEALTH .. " health.")

	-- Handle character loading
	player.CharacterAdded:Connect(function(character)
		self:OnCharacterAdded(player, character)
		-- Re-apply state when character respawns
		local currentState = self:GetPlayerState(player)
		if currentState then
			self:SetPlayerState(player, currentState)
		end
	end)

	-- Handle character if it's already loaded
	if player.Character then
		self:OnCharacterAdded(player, player.Character)
		local currentState = self:GetPlayerState(player)
		if currentState then
			self:SetPlayerState(player, currentState)
		end
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
	playerStates[player] = nil
	playerRolesContainer:SetAttribute(tostring(player.UserId), nil)
	playerStatesContainer:SetAttribute(tostring(player.UserId), nil)
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

	-- Updated to use the new Survivor classes
	local testRoles = {"Killer", "Sentinel", "Support", "Survivalist"}

	for i, player in ipairs(allPlayers) do
		local role = testRoles[i] or "Survivalist" -- Default to Survivalist
		setRole(player, role)

		if role == "Killer" then
			AbilityManager:EquipPerk(player, "DefaultKillerAbility")
		elseif role == "Sentinel" then
			AbilityManager:EquipPerk(player, "Stun")
		elseif role == "Support" then
			AbilityManager:EquipPerk(player, "BotanyKnowledge")
		else -- Survivalist or any other survivor role
			AbilityManager:EquipPerk(player, "DefaultSurvivorAbility")
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
	if self:GetPlayerState(player) == "Downed" then return end -- Don't damage downed players

	playerHealths[player] -= amount
	print(player.Name .. " took " .. amount .. " damage, health is now " .. playerHealths[player])

	if playerHealths[player] <= 0 then
		print(player.Name .. " has been downed!")
		playerHealths[player] = 0
		self:SetPlayerState(player, "Downed")
	else
		self:SetPlayerState(player, "Injured")
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
	if not playerHealths[player] or self:GetPlayerState(player) == "Downed" then return end

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	playerHealths[player] = math.min(playerHealths[player] + amount, humanoid.MaxHealth)
	print(player.Name .. " was healed for " .. amount .. ", health is now " .. playerHealths[player])

	if playerHealths[player] >= humanoid.MaxHealth then
		self:SetPlayerState(player, "Healthy")
	else
		self:SetPlayerState(player, "Injured")
	end
end

return PlayerManager
