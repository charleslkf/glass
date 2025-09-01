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
local HELPER_ABILITY_RANGE = 25 -- studs
local HEAL_AMOUNT = 25 -- health points
local SPEED_BOOST_MULTIPLIER = 1.5 -- 50% speed increase
local SPEED_BOOST_DURATION = 5 -- seconds

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

	EventManager.UseAbilityEvent.OnServerEvent:Connect(function(player)
		self:UseAbility(player)
	end)

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

	ability:Execute(player)

	if ability.Name == "HelperAbility" then
		self:ExecuteHelperAbility(player)
	end
end

--[=[
	Applies a temporary speed boost to a character.
]=]
local function applySpeedBoost(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local originalSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = originalSpeed * SPEED_BOOST_MULTIPLIER
	print(character.Name .. "'s speed boosted to " .. humanoid.WalkSpeed)

	task.delay(SPEED_BOOST_DURATION, function()
		if humanoid.Parent then
			humanoid.WalkSpeed = originalSpeed
			print(character.Name .. "'s speed returned to normal.")
		end
	end)
end

--[=[
	Executes the server-side logic for the Helper's AoE ability.
]=]
function AbilityManager:ExecuteHelperAbility(helperPlayer: Player)
	local helperChar = helperPlayer.Character
	if not helperChar then return end

	local rootPart = helperChar:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	print(helperPlayer.Name .. " used Helper ability.")

	-- Play VFX and SFX for all clients
	EventManager.PlaySoundEvent:FireAllClients("HelperAbility", rootPart.Position)
	EventManager.PlayVFXEvent:FireAllClients("HelperAbility", rootPart.Position)

	applySpeedBoost(helperChar)

	local helperPos = rootPart.Position
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= helperPlayer and PlayerManager:GetRole(player) ~= "Killer" then
			local targetChar = player.Character
			if targetChar then
				local distance = (helperPos - targetChar:GetPrimaryPartCFrame().Position).Magnitude
				if distance <= HELPER_ABILITY_RANGE then
					print("Helper ability affecting " .. player.Name)
					PlayerManager:HealPlayer(player, HEAL_AMOUNT)
					applySpeedBoost(targetChar)
				end
			end
		end
	end
end

--[=[
	Handles the server-side logic when a stunner reports a hit on another player.
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
