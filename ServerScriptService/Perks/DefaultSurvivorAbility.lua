--!strict
--[=[
	@class DefaultSurvivorAbility
	Placeholder for a default survivor ability.
]=]
local DefaultSurvivorAbility = {}
DefaultSurvivorAbility.__index = DefaultSurvivorAbility

--[=[
	Creates a new ability instance.
	@return DefaultSurvivorAbility
]=]
function DefaultSurvivorAbility.new()
	local self = setmetatable({}, DefaultSurvivorAbility)
	self.Name = "Default Survivor Ability"
	self.Cooldown = 30 -- seconds
	return self
end

--[=[
	Executes the ability for the given player.
	@param player Player The player using the ability.
]=]
function DefaultSurvivorAbility:Execute(player: Player)
	print(player.Name .. " used ability: " .. self.Name)
	-- Placeholder for actual ability logic (e.g., speed boost, etc.)
end

return DefaultSurvivorAbility
