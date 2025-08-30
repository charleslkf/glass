--!strict
--[=[
	@class MachineManager
	Manages the state and interactions of all machines in the game.
]=]
local MachineManager = {}
MachineManager.__index = MachineManager

local ServerScriptService = game:GetService("ServerScriptService")
local RoundManager = require(ServerScriptService.RoundManager)

-- A table to keep track of all machines
local machines = {}

--[=[
	Initializes a new machine and adds it to the manager.
	@param machinePart Part The part representing the machine.
	@return table The machine object.
]=]
function MachineManager:New(machinePart: Part)
	local machine = {
		Part = machinePart,
		IsCompleted = false,
	}
	table.insert(machines, machine)
	return machine
end

--[=[
	Handles the logic when a machine is completed by a player.
	@param machine table The machine object that was completed.
]=]
function MachineManager:CompleteMachine(machine)
	if machine.IsCompleted then return end

	machine.IsCompleted = true
	print("A machine has been completed!")

	-- Notify the RoundManager about the completion
	-- This part is a placeholder for future implementation, as per the roadmap.
	-- For now, it just prints a message.
	print("Notifying RoundManager...")
	-- RoundManager:OnMachineCompleted()
end

--[=[
	Resets all machines to their initial state.
]=]
function MachineManager:ResetAllMachines()
	for _, machine in ipairs(machines) do
		machine.IsCompleted = false
	end
	print("All machines have been reset.")
end

return MachineManager
