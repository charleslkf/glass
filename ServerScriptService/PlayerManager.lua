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
-- A table to store player items and their charges
local playerItems = {}

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
			humanoid.WalkSpeed = 0 -- Set to 0 as PlatformStand disables movement anyway
			humanoid.PlatformStand = true
		elseif state == "Carried" or state == "Hooked" then
			humanoid.WalkSpeed = 0
			humanoid.PlatformStand = false
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		elseif state == "Carrying" then
			humanoid.WalkSpeed = 14
			humanoid.PlatformStand = false
		elseif state == "Healthy" or state == "Injured" then
			humanoid.WalkSpeed = 16
			humanoid.PlatformStand = false
		elseif state == "Escaped" then
			-- No physical state, character should be destroyed
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
	playerItems[player] = nil
	playerRolesContainer:SetAttribute(tostring(player.UserId), nil)
	playerStatesContainer:SetAttribute(tostring(player.UserId), nil)
	playerRolesContainer:SetAttribute(tostring(player.UserId) .. "_Item", nil)
end

--[=[
	Gives an item to a player.
	@param player Player The player to give the item to.
	@param itemName string The name of the item.
	@param charges number The number of uses the item has.
]=]
function PlayerManager:GiveItem(player: Player, itemName: string, charges: number)
	if not player then return end
	playerItems[player] = {
		Name = itemName,
		Charges = charges,
	}
	playerRolesContainer:SetAttribute(tostring(player.UserId) .. "_Item", itemName)
	print("Gave " .. itemName .. " to " .. player.Name)
end

--[=[
	Checks if a player currently has an item.
]=]
function PlayerManager:HasItem(player: Player): boolean
	return playerItems[player] ~= nil
end

--[=[
	Consumes one charge of a player's item. If charges reach zero, the item is removed.
]=]
function PlayerManager:UseItemCharge(player: Player)
	if not self:HasItem(player) then return end

	local item = playerItems[player]
	item.Charges -= 1
	print(player.Name .. " used a charge of " .. item.Name .. ". " .. item.Charges .. " charges remaining.")

	if item.Charges <= 0 then
		playerItems[player] = nil
		playerRolesContainer:SetAttribute(tostring(player.UserId) .. "_Item", nil)
		print(player.Name .. "'s " .. item.Name .. " was depleted.")
	end
end

--[=[
	Handles a player's request to use their currently held item.
]=]
function PlayerManager:UseItem(player: Player)
	if not self:HasItem(player) then
		print(player.Name .. " tried to use an item, but has none.")
		return
	end

	local item = playerItems[player]

	if item.Name == "Med-Kit" then
		if self:GetPlayerState(player) == "Injured" then
			print(player.Name .. " is using a Med-Kit to heal.")
			-- For now, the heal is instant. A channel time could be added later.
			self:HealPlayer(player, 50) -- Heal for 50 to go from Injured to Healthy
			self:UseItemCharge(player)
		else
			print(player.Name .. " tried to use a Med-Kit, but is not injured.")
		end
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

	EventManager.PlayerAttackEvent.OnServerEvent:Connect(function(attackerPlayer, targetPlayer)
		self:KillerAttack(attackerPlayer, targetPlayer)
	end)

	EventManager.UseItemEvent.OnServerEvent:Connect(function(player)
		self:UseItem(player)
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
	Returns a list of all survivors who are still in the round (not escaped).
]=]
function PlayerManager:GetActiveSurvivors()
	local activeSurvivors = {}
	for player, role in pairs(playerRoles) do
		if role ~= "Killer" then
			local state = self:GetPlayerState(player)
			if state ~= "Escaped" then
				table.insert(activeSurvivors, player)
			end
		end
	end
	return activeSurvivors
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

	if self:GetPlayerState(target) == "Downed" then
		return -- Don't attack players who are already downed
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
