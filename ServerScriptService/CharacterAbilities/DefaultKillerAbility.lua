--!strict
--[=[
	@class DefaultKillerAbility
	Placeholder for a default killer ability.
]=]
local DefaultKillerAbility = {}
DefaultKillerAbility.__index = DefaultKillerAbility

--[=[
	Creates a new ability instance.
	@return DefaultKillerAbility
]=]
function DefaultKillerAbility.new()
	local self = setmetatable({}, DefaultKillerAbility)
	self.Name = "Default Killer Ability"
	self.Cooldown = 60 -- seconds
	return self
end

--[=[
	Executes the ability for the given player.
	@param player Player The player using the ability.
]=]
function DefaultKillerAbility:Execute(player: Player)
	print(player.Name .. " used ability: " .. self.Name)
	-- Placeholder for actual ability logic (e.g., reveal survivors, etc.)
end

return DefaultKillerAbility
