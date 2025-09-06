--!strict
--[=[
	@class AbilityManager
	Acts as a controller to load, equip, and trigger character abilities.
]=]
local AbilityManager = {}
AbilityManager.__index = AbilityManager

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local EventManager = require(ServerScriptService.EventManager)
-- UPDATED: Point to the new Perks folder
local PerksFolder = ServerScriptService:WaitForChild("Perks")
local PlayerManager = require(ServerScriptService.PlayerManager)

-- REMOVED: Helper constants
local STUN_DURATION = 3 -- seconds
local MAX_STUN_DISTANCE = 30 -- studs

-- A dictionary to hold the loaded ability modules
local PerkModules = {}

-- A table to track which ability is equipped by each player
local equippedPerks = {}

--[=[
	-- UPDATED: Now recursive to handle class subfolders
	Loads all perk modules from the Perks folder.
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

--[=[
	Loads all ability modules and sets up event listeners.
]=]
function AbilityManager:Init()
	-- UPDATED: Call the new recursive loader
	loadPerksRecursive(PerksFolder)

	EventManager.UseAbilityEvent.OnServerEvent:Connect(function(player, ...)
		self:UseAbility(player, ...)
	end)

	-- Note: Stunner event is still here but will be removed in the next phase
	EventManager.ReportStunnerHit.OnServerEvent:Connect(function(player, hitPlayer: Player)
		self:OnStunnerHit(player, hitPlayer)
	end)
end

--[=[
	-- RENAMED: from EquipAbility to EquipPerk
	Equips a player with a specific perk.
]=]
function AbilityManager:EquipPerk(player: Player, abilityName: string)
	local module = PerkModules[abilityName]
	if not module then
		-- It's possible the module isn't loaded yet if this is called before Init.
		-- Let's try requiring it directly as a fallback.
		-- This is not ideal, but makes testing easier.
		local moduleScript = PerksFolder:FindFirstChild(abilityName, true)
		if moduleScript and moduleScript:IsA("ModuleScript") then
			module = require(moduleScript)
			PerkModules[abilityName] = module
		else
			warn("Attempted to equip an invalid or non-existent perk: " .. abilityName)
			return
		end
	end

	equippedPerks[player] = module.new()
	print(player.Name .. " has been equipped with perk: " .. abilityName)
end

--[=[
	Uses the ability currently equipped by the player.
]=]
function AbilityManager:UseAbility(player: Player, ...)
	local perk = equippedPerks[player]
	if not perk then
		warn(player.Name .. " tried to use a perk but has none equipped.")
		return
	end

	-- UPDATED: No more hardcoded checks, just execute.
	perk:Execute(player, ...)
end

-- REMOVED: applySpeedBoost function

-- REMOVED: ExecuteHelperAbility function

--[=[
	Handles the server-side logic when a stunner reports a hit on another player.
	-- This will be removed in the next phase of refactoring.
]=]
function AbilityManager:OnStunnerHit(stunnerPlayer: Player, hitPlayer: Player)
	if not stunnerPlayer or not hitPlayer or stunnerPlayer == hitPlayer then return end
	if PlayerManager:GetRole(stunnerPlayer) ~= "Stunner" then return end
	if PlayerManager:GetRole(hitPlayer) ~= "Killer" then return end

	local stunnerChar = stunnerPlayer.Character
	local killerChar = hitPlayer.Character
	if not stunnerChar or not killerChar then return end

	local distance = (stunnerChar:GetPrimaryPartCFrame().Position - killerChar:GetPrimaryPartCFrame().Position).Magnitude
	if distance > MAX_STUN_DISTANCE then
		warn(`Stunner {stunnerPlayer.Name} reported a hit on Killer {hitPlayer.Name} from too far away: {distance} studs.`)
		return
	end

	local killerHumanoid = killerChar:FindFirstChildOfClass("Humanoid")
	if killerHumanoid then
		print(`Stunner {stunnerPlayer.Name} successfully stunned Killer {hitPlayer.Name}!`)
		local originalWalkSpeed = killerHumanoid.WalkSpeed
		killerHumanoid.WalkSpeed = 0

		task.wait(STUN_DURATION)

		if killerHumanoid.Parent then
			killerHumanoid.WalkSpeed = originalWalkSpeed
			print(`Killer {hitPlayer.Name} is no longer stunned.`)
		end
	end
end

return AbilityManager
