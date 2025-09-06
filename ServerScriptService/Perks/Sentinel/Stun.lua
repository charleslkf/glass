--!strict
--[=[
	@class Stun
	This perk allows a Sentinel to stun the Killer.
]=]
local Stun = {}
Stun.__index = Stun

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerManager = require(ServerScriptService.PlayerManager)

-- Constants
local STUN_DURATION = 3
local MAX_STUN_DISTANCE = 30

--[=[
	Creates a new Stun perk instance.
]=]
function Stun.new()
	local self = setmetatable({}, Stun)
	self.Name = "Stun"
	self.Cooldown = 30
	return self
end

--[=[
	Executes the perk's logic.
]=]
function Stun:Execute(stunnerPlayer: Player, hitPlayer: Player)
	if not hitPlayer then return end -- Guard against untargeted calls

	print(`{self.Name} executed by {stunnerPlayer.Name} on {hitPlayer.Name}`)

	if not stunnerPlayer or stunnerPlayer == hitPlayer then return end
	if PlayerManager:GetRole(hitPlayer) ~= "Killer" then
		warn(`{self.Name} can only be used on the Killer.`)
		return
	end

	local stunnerChar = stunnerPlayer.Character
	local killerChar = hitPlayer.Character
	if not stunnerChar or not killerChar then return end

	local distance = (stunnerChar:GetPrimaryPartCFrame().Position - killerChar:GetPrimaryPartCFrame().Position).Magnitude
	if distance > MAX_STUN_DISTANCE then
		warn(`Stunner {stunnerPlayer.Name} reported a hit on Killer {hitPlayer.Name} from too far away: {distance} studs.`)
		return
	end

	local killerHumanoid = killerChar:FindFirstChildOfClass("Humanoid")
	if killerHumanoid and killerHumanoid.WalkSpeed > 0 then
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

return Stun
