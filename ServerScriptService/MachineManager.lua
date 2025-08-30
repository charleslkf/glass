--!strict
--[=[
	@class MachineManager
	Acts as a controller to load, create, and manage all machine minigame instances.
]=]
local MachineManager = {}
MachineManager.__index = MachineManager

local ServerScriptService = game:GetService("ServerScriptService")
local MinigamesFolder = ServerScriptService:WaitForChild("MachineMinigames")

-- A dictionary to hold the loaded minigame modules, e.g., { ClassicMachine = require(...) }
local MinigameModules = {}

-- A table to keep track of all active machine instances in the game
local activeMachines = {}

-- A BindableEvent that fires when any machine is completed
MachineManager.MachineCompleted = Instance.new("BindableEvent")

--[=[
	Loads all minigame modules from the MachineMinigames folder.
	This should be called once when the server starts.
]=]
function MachineManager:Init()
	for _, moduleScript in ipairs(MinigamesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local moduleName = moduleScript.Name
			MinigameModules[moduleName] = require(moduleScript)
			print("Loaded minigame module: " .. moduleName)
		end
	end
end

--[=[
	Creates a new instance of a specific machine minigame.
	@param machineType string The name of the machine module (e.g., "ClassicMachine").
	@param puzzleData table The data needed to initialize the minigame.
	@return table | nil The new machine instance, or nil if the type is invalid.
]=]
function MachineManager:CreateMachine(machineType: string, puzzleData: table)
	local module = MinigameModules[machineType]
	if not module then
		warn("Attempted to create an invalid machine type: " .. machineType)
		return nil
	end

	local newMachine = module.new(puzzleData)
	table.insert(activeMachines, newMachine)

	-- In a real game, the machine instance itself would fire an event.
	-- For now, we'll use a debug function to simulate this.

	return newMachine
end

--[=[
	A debug function to simulate a player completing a machine.
	This will be replaced by actual player interaction logic later.
	@param machineInstance table The machine that was completed.
]=]
function MachineManager:Debug_CompleteMachine(machineInstance: table)
	if machineInstance and not machineInstance.IsCompleted then
		-- In a real implementation, we'd call machineInstance:ValidateSolution()
		machineInstance.IsCompleted = true
		print("A machine has been completed (via debug)!")
		self.MachineCompleted:Fire(machineInstance)
	end
end

--[=[
	Gets all the active machine instances.
	@return {table} A list of all active machines.
]=]
function MachineManager:GetActiveMachines()
	return activeMachines
end

--[=[
	Resets all active machines to their initial state.
	This is called by the RoundManager during intermission.
]=]
function MachineManager:ResetAllMachines()
	for _, machineInstance in ipairs(activeMachines) do
		if machineInstance.Reset then
			machineInstance:Reset()
		end
	end
	print("All active machines have been reset.")
end

return MachineManager
