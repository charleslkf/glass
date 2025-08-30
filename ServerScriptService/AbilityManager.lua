--!strict
--[=[
	@class AbilityManager
	Acts as a controller to load, equip, and trigger character abilities.
]=]
local AbilityManager = {}
AbilityManager.__index = AbilityManager

local ServerScriptService = game:GetService("ServerScriptService")
local EventManager = require(ServerScriptService.EventManager)
local AbilitiesFolder = ServerScriptService:WaitForChild("CharacterAbilities")

-- A dictionary to hold the loaded ability modules
local AbilityModules = {}

-- A table to track which ability is equipped by each player
local equippedAbilities = {}

--[=[
	Loads all ability modules from the CharacterAbilities folder.
]=]
function AbilityManager:Init()
	for _, moduleScript in ipairs(AbilitiesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local moduleName = moduleScript.Name
			AbilityModules[moduleName] = require(moduleScript)
			print("Loaded ability module: " .. moduleName)
		end
	end

	-- Listen for the event from the client
	EventManager.UseAbilityEvent.OnServerEvent:Connect(function(player)
		self:UseAbility(player)
	end)
end

--[=[
	Equips a player with a specific ability.
	@param player Player The player to equip.
	@param abilityName string The name of the ability module.
]=]
function AbilityManager:EquipAbility(player: Player, abilityName: string)
	local module = AbilityModules[abilityName]
	if not module then
		warn("Attempted to equip an invalid ability: " .. abilityName)
		return
	end

	equippedAbilities[player] = module.new()
	print(player.Name .. " has been equipped with ability: " .. abilityName)
end

--[=[
	Uses the ability currently equipped by the player.
	@param player Player The player using the ability.
]=]
function AbilityManager:UseAbility(player: Player)
	local ability = equippedAbilities[player]
	if not ability then
		warn(player.Name .. " tried to use an ability but has none equipped.")
		return
	end

	-- In the future, we would check for cooldowns here.

	ability:Execute(player)
end

return AbilityManager
