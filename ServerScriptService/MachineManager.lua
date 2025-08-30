--!strict
--[=[
	@class MachineManager
	Acts as a controller to load, create, and manage all machine minigame instances.
]=]
local MachineManager = {}
MachineManager.__index = MachineManager

local ServerScriptService = game:GetService("ServerScriptService")
local EventManager = require(ServerScriptService.EventManager)
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

	-- Create a physical representation of the machine in the workspace
	self:_CreateMachinePart(newMachine, machineType)

	return newMachine
end

--[=[
	Creates and configures the physical part for a machine.
	@param machineInstance table The logical machine object.
	@param machineType string The type of the machine.
]=]
function MachineManager:_CreateMachinePart(machineInstance: table, machineType: string)
	print("Creating physical machine part of type: " .. machineType)
	local part = Instance.new("Part")
	part.Size = Vector3.new(5, 5, 5)
	part.Anchored = true
	part.Position = Vector3.new(math.random(-50, 50), 2.5, math.random(-50, 50))
	part.BrickColor = BrickColor.random()
	part.Name = machineType .. " (Machine)"
	part.Parent = workspace

	-- Link the physical part to the logical object
	machineInstance.Part = part

	-- Add a ProximityPrompt for player interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Repair Machine"
	prompt.ObjectText = machineType
	prompt.HoldDuration = 2 -- Player must hold the key for 2 seconds
	prompt.Parent = part

	-- When the prompt is triggered, complete the machine
	prompt.Triggered:Connect(function(player)
		print(player.Name .. " interacted with a " .. machineType)
		-- For now, interacting instantly completes the machine.
		-- Later, this will open the minigame UI.
		self:Debug_CompleteMachine(machineInstance)
	end)
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

		-- Fire the remote event to all clients to play the sound
		EventManager.PlaySoundEvent:FireAllClients("MachineComplete")

		-- Fire the remote event to all clients to play the VFX
		if machineInstance.Part then
			EventManager.PlayVFXEvent:FireAllClients("MachineComplete", machineInstance.Part.Position)
		end
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
		-- Reset the logical state
		if machineInstance.Reset then
			machineInstance:Reset()
		end
		-- Destroy the physical part
		if machineInstance.Part then
			machineInstance.Part:Destroy()
			machineInstance.Part = nil
		end
	end
	-- Clear the table of active machines for the new round
	table.clear(activeMachines)
	print("All active machines have been reset and their parts destroyed.")
end

return MachineManager
