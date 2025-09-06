--!strict
--[=[
	@class DefaultSurvivorAbility
	The default, basic ability for a Survivor with no special class.
]=]
local DefaultSurvivorAbility = {}
DefaultSurvivorAbility.__index = DefaultSurvivorAbility

--[=[
	Creates a new DefaultSurvivorAbility instance.
]=]
function DefaultSurvivorAbility.new()
	local self = setmetatable({}, DefaultSurvivorAbility)
	self.Name = "DefaultSurvivorAbility"
	self.Cooldown = 0
	return self
end

--[=[
	Executes the ability for the given player.
]=]
function DefaultSurvivorAbility:Execute(player: Player)
	print(`{player.Name} has no special ability to use.`)
	-- This is a placeholder for survivors without a specific class ability
end

return DefaultSurvivorAbility
