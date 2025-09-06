--!strict
--[=[
	@class StunnerAbility
	This ability allows the Stunner to fire a short-range projectile
	that can freeze the Killer for a few seconds.
]=]
local StunnerAbility = {}
StunnerAbility.__index = StunnerAbility

--[=[
	Creates a new StunnerAbility instance.
]=]
function StunnerAbility.new()
	local self = setmetatable({}, StunnerAbility)
	self.Name = "StunnerAbility"
	self.Cooldown = 30 -- seconds
	return self
end

--[=[
	Executes the ability for the given player.
	On the server, this validates the hit. On the client, it fires the projectile.
	@param player Player The player using the ability.
	@param ... any Additional arguments, such as the target of the hit.
]=]
function StunnerAbility:Execute(player: Player, ...)
	-- The core logic will be split between client and server.
	-- The client will fire the projectile and report a hit.
	-- The server will validate the hit and apply the stun.
	print(`{self.Name} executed by {player.Name}`)
end

return StunnerAbility
