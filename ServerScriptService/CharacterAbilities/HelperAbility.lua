--!strict
--[=[
	@class HelperAbility
	This ability allows the Helper to emit an AoE pulse that heals
	nearby survivors and grants a speed boost to them and the Helper.
]=]
local HelperAbility = {}
HelperAbility.__index = HelperAbility

--[=[
	Creates a new HelperAbility instance.
]=]
function HelperAbility.new()
	local self = setmetatable({}, HelperAbility)
	self.Name = "HelperAbility"
	self.Cooldown = 45 -- seconds
	return self
end

--[=[
	Executes the ability for the given player.
]=]
function HelperAbility:Execute(player: Player)
	-- The server will handle the AoE logic.
	-- The client will handle the VFX/SFX.
	print(`{self.Name} executed by {player.Name}`)
end

return HelperAbility
