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
local AbilitiesFolder = ServerScriptService:WaitForChild("CharacterAbilities")
local PlayerManager = require(ServerScriptService.PlayerManager)

-- Constants
local STUN_DURATION = 3 -- seconds
local MAX_STUN_DISTANCE = 30 -- studs

-- A dictionary to hold the loaded ability modules
local AbilityModules = {}

-- A table to track which ability is equipped by each player
local equippedAbilities = {}

--[=[
	Loads all ability modules and sets up event listeners.
]=]
function AbilityManager:Init()
	for _, moduleScript in ipairs(AbilitiesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local moduleName = moduleScript.Name
			AbilityModules[moduleName] = require(moduleScript)
			print("Loaded ability module: " .. moduleName)
		end
	end

	-- Listen for the generic "use ability" event from the client
	EventManager.UseAbilityEvent.OnServerEvent:Connect(function(player)
		self:UseAbility(player)
	end)

	-- Listen for the specific "stunner hit" event from the client
	EventManager.ReportStunnerHit.OnServerEvent:Connect(function(player, hitPlayer: Player)
		self:OnStunnerHit(player, hitPlayer)
	end)
end

--[=[
	Equips a player with a specific ability.
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
]=]
function AbilityManager:UseAbility(player: Player)
	local ability = equippedAbilities[player]
	if not ability then
		warn(player.Name .. " tried to use an ability but has none equipped.")
		return
	end

	-- The client will do the visual part. The server just needs to know it was used.
	ability:Execute(player)
end

--[=[
	Handles the server-side logic when a stunner reports a hit on another player.
]=]
function AbilityManager:OnStunnerHit(stunnerPlayer: Player, hitPlayer: Player)
	-- Security / Validation
	if not stunnerPlayer or not hitPlayer or stunnerPlayer == hitPlayer then return end
	if PlayerManager:GetRole(stunnerPlayer) ~= "Stunner" then return end
	if PlayerManager:GetRole(hitPlayer) ~= "Killer" then return end

	local stunnerChar = stunnerPlayer.Character
	local killerChar = hitPlayer.Character
	if not stunnerChar or not killerChar then return end

	-- Distance check to prevent cheating
	local distance = (stunnerChar:GetPrimaryPartCFrame().Position - killerChar:GetPrimaryPartCFrame().Position).Magnitude
	if distance > MAX_STUN_DISTANCE then
		warn(`Stunner {stunnerPlayer.Name} reported a hit on Killer {hitPlayer.Name} from too far away: {distance} studs.`)
		return
	end

	-- Apply the stun effect
	local killerHumanoid = killerChar:FindFirstChildOfClass("Humanoid")
	if killerHumanoid then
		print(`Stunner {stunnerPlayer.Name} successfully stunned Killer {hitPlayer.Name}!`)
		local originalWalkSpeed = killerHumanoid.WalkSpeed
		killerHumanoid.WalkSpeed = 0

		task.wait(STUN_DURATION)

		-- Check if humanoid still exists before restoring speed
		if killerHumanoid.Parent then
			killerHumanoid.WalkSpeed = originalWalkSpeed
			print(`Killer {hitPlayer.Name} is no longer stunned.`)
		end
	end
end

return AbilityManager
