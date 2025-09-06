--!strict
--[=[
	@class BotanyKnowledge
	This perk allows a Support to heal and speed up nearby teammates.
	This is a refactored version of the old HelperAbility.
]=]
local BotanyKnowledge = {}
BotanyKnowledge.__index = BotanyKnowledge

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local PlayerManager = require(ServerScriptService.PlayerManager)
local EventManager = require(ServerScriptService.EventManager)

-- Constants moved from AbilityManager
local HEAL_AMOUNT = 25
local ABILITY_RANGE = 25
local SPEED_BOOST_MULTIPLIER = 1.5
local SPEED_BOOST_DURATION = 5

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
	Creates a new BotanyKnowledge perk instance.
]=]
function BotanyKnowledge.new()
	local self = setmetatable({}, BotanyKnowledge)
	self.Name = "BotanyKnowledge"
	self.Cooldown = 45 -- seconds
	return self
end

--[=[
	Executes the perk's logic.
	@param player Player The player using the perk.
]=]
function BotanyKnowledge:Execute(player: Player)
	print(`{self.Name} executed by {player.Name}`)

	local character = player.Character
	if not character then return end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Fire events for client-side feedback
	EventManager.PlaySoundEvent:FireAllClients("HelperAbility", rootPart.Position)
	EventManager.PlayVFXEvent:FireAllClients("HelperAbility", rootPart.Position)

	-- Apply boost to self
	applySpeedBoost(character)

	-- Apply boost and heal to nearby players
	local playerPos = rootPart.Position
	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= player and PlayerManager:GetRole(otherPlayer) ~= "Killer" then
			local targetChar = otherPlayer.Character
			if targetChar then
				local distance = (playerPos - targetChar:GetPrimaryPartCFrame().Position).Magnitude
				if distance <= ABILITY_RANGE then
					print("BotanyKnowledge affecting " .. otherPlayer.Name)
					PlayerManager:HealPlayer(otherPlayer, HEAL_AMOUNT)
					applySpeedBoost(targetChar)
				end
			end
		end
	end
end

return BotanyKnowledge
