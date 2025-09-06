--!strict
--[=[
	@class DefaultKillerAbility
	The default, basic ability for the Killer.
]=]
local DefaultKillerAbility = {}
DefaultKillerAbility.__index = DefaultKillerAbility

--[=[
	Creates a new DefaultKillerAbility instance.
]=]
function DefaultKillerAbility.new()
	local self = setmetatable({}, DefaultKillerAbility)
	self.Name = "DefaultKillerAbility"
	self.Cooldown = 1
	return self
end

--[=[
	Executes the ability for the given player.
]=]
function DefaultKillerAbility:Execute(player: Player)
	print(`{player.Name} used ability: Default Killer Ability`)
	-- The actual attack logic is handled by PlayerManager:KillerAttack
	-- This event is just a placeholder or for potential future use
end

return DefaultKillerAbility
