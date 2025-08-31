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

-- A dictionary to hold the loaded minigame modules
local MinigameModules = {}

-- FIX: Use a dictionary to store active machines by a unique ID
local activeMachines: {[string]: table} = {}
local machineIdCounter = 0

-- A BindableEvent that fires when any machine is completed
MachineManager.MachineCompleted = Instance.new("BindableEvent")

--[=[
	Loads all minigame modules and sets up event listeners.
]=]
function MachineManager:Init()
	for _, moduleScript in ipairs(MinigamesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local moduleName = moduleScript.Name
			MinigameModules[moduleName] = require(moduleScript)
			print("Loaded minigame module: " .. moduleName)
		end
	end

	-- FIX: Listen for solution submissions using a machineID
	EventManager.SubmitClassicMachineSolution.OnServerEvent:Connect(function(player, machineID: string, solution: table)
		local machineInstance = activeMachines[machineID]

		if not machineInstance or machineInstance.IsCompleted then
			warn(player.Name .. " submitted a solution for an invalid or already completed machine: " .. machineID)
			return
		end

		local isCorrect = machineInstance:ValidateSolution(solution)

		if isCorrect then
			print("Solution for " .. machineInstance.Part.Name .. " by " .. player.Name .. " is correct!")
			self:CompleteMachine(machineInstance)
		else
			print("Solution for " .. machineInstance.Part.Name .. " by " .. player.Name .. " is incorrect.")
		end
	end)
end

--[=[
	Creates a new instance of a specific machine minigame.
]=]
function MachineManager:CreateMachine(machineType: string, puzzleData: table)
	local module = MinigameModules[machineType]
	if not module then
		warn("Attempted to create an invalid machine type: " .. machineType)
		return nil
	end

	local newMachine = module.new(puzzleData)

	-- FIX: Generate and assign a unique ID
	machineIdCounter += 1
	local machineID = "Machine" .. tostring(machineIdCounter)
	newMachine.ID = machineID

	activeMachines[machineID] = newMachine

	-- Create a physical representation of the machine in the workspace
	self:_CreateMachinePart(newMachine, machineType)

	return newMachine
end

--[=[
	Creates and configures the physical part for a machine.
]=]
function MachineManager:_CreateMachinePart(machineInstance: table, machineType: string)
	print("Creating physical machine part of type: " .. machineType)
	local part = Instance.new("Part")
	part.Size = Vector3.new(5, 5, 5)
	part.Anchored = true
	part.Position = Vector3.new(math.random(-50, 50), 2.5, math.random(-50, 50))
	part.BrickColor = BrickColor.random()
	part.Name = machineType .. " (" .. machineInstance.ID .. ")"
	part.Parent = workspace

	machineInstance.Part = part

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Repair Machine"
	prompt.ObjectText = machineType
	prompt.HoldDuration = 2
	prompt.Parent = part

	prompt.Triggered:Connect(function(player)
		print(player.Name .. " interacted with a " .. machineType)

		if machineType == "ClassicMachine" then
			-- FIX: Send the simple machineID to the client, not the whole instance
			print("Firing ShowMachineUI for " .. machineInstance.ID .. " to " .. player.Name)
			EventManager.ShowMachineUI:FireClient(player, machineType, machineInstance.ID)
		else
			print("Default interaction: auto-completing machine.")
			self:CompleteMachine(machineInstance)
		end
	end)
end

--[=[
	Handles the completion of a machine.
]=]
function MachineManager:CompleteMachine(machineInstance: table)
	if machineInstance and not machineInstance.IsCompleted then
		machineInstance.IsCompleted = true
		print("A machine has been completed!")
		self.MachineCompleted:Fire(machineInstance)

		-- Fire the remote event to all clients to play the sound
		EventManager.PlaySoundEvent:FireAllClients("MachineComplete")

		if machineInstance.Part then
			EventManager.PlayVFXEvent:FireAllClients("MachineComplete", machineInstance.Part.Position)
		end
	end
end

--[=[
	Gets all the active machine instances.
]=]
function MachineManager:GetActiveMachines()
	return activeMachines
end

--[=[
	Resets all active machines to their initial state.
]=]
function MachineManager:ResetAllMachines()
	-- FIX: Iterate over a dictionary with pairs
	for id, machineInstance in pairs(activeMachines) do
		if machineInstance.Reset then
			machineInstance:Reset()
		end
		if machineInstance.Part then
			machineInstance.Part:Destroy()
			machineInstance.Part = nil
		end
	end
	-- Clear the table for the new round
	activeMachines = {}
	print("All active machines have been reset and their parts destroyed.")
end

return MachineManager
