--!strict
--[=[
	@class AbilityManager
	Acts as a controller to load, equip, and trigger character perks.
	This manager is designed to be generic and not contain any perk-specific logic.
]=]
local AbilityManager = {}
AbilityManager.__index = AbilityManager

local ServerScriptService = game:GetService("ServerScriptService")
local EventManager = require(ServerScriptService.EventManager)
local PerksFolder = ServerScriptService:WaitForChild("Perks")

-- A dictionary to hold the loaded perk modules, indexed by perk name
local PerkModules = {}

-- A table to track which perks are equipped by each player
local equippedPerks = {}

--[=[
	Recursively loads all perk modules from the Perks folder.
]=]
local function loadPerksRecursive(directory)
	for _, item in ipairs(directory:GetChildren()) do
		if item:IsA("ModuleScript") then
			local moduleName = item.Name
			PerkModules[moduleName] = require(item)
			print("Loaded perk module: " .. moduleName)
		elseif item:IsA("Folder") then
			loadPerksRecursive(item)
		end
	end
end

-- Load all perks immediately when the module is required
loadPerksRecursive(PerksFolder)

--[=[
	Sets up event listeners.
]=]
function AbilityManager:Init()
	EventManager.UseAbilityEvent.OnServerEvent:Connect(function(player, ...)
		AbilityManager:UseAbility(player, ...)
	end)
	print("AbilityManager initialized.")
end

--[=[
	Equips a player with a specific perk.
]=]
function AbilityManager:EquipPerk(player: Player, perkName: string)
	local module = PerkModules[perkName]
	if not module then
		warn("Attempted to equip an invalid or non-existent perk: " .. perkName)
		return
	end

	equippedPerks[player] = module.new()
	print(player.Name .. " has been equipped with perk: " .. perkName)
end

--[=[
	Uses the perk currently equipped by the player.
]=]
function AbilityManager:UseAbility(player: Player, ...)
	local perk = equippedPerks[player]
	if not perk then
		warn(player.Name .. " tried to use a perk but has none equipped.")
		return
	end

	perk:Execute(player, ...)
end

return AbilityManager
