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

-- A dictionary to store active machines by a unique ID
local activeMachines: {[string]: table} = {}
local machineIdCounter = 0

-- A BindableEvent that fires when any machine is completed
MachineManager.MachineCompleted = Instance.new("BindableEvent")

-- FIX: Load all minigame modules immediately when this script is required
for _, moduleScript in ipairs(MinigamesFolder:GetChildren()) do
	if moduleScript:IsA("ModuleScript") then
		local moduleName = moduleScript.Name
		MinigameModules[moduleName] = require(moduleScript)
		print("Loaded minigame module: " .. moduleName)
	end
end

--[=[
	Sets up event listeners. This should be called once from Main.server.lua.
]=]
function MachineManager:Init()
	EventManager.SubmitClassicMachineSolution.OnServerEvent:Connect(function(player, machineID: string, solution: table)
		local machineInstance = activeMachines[machineID]

		if not machineInstance or machineInstance.IsCompleted then
			warn(player.Name .. " submitted a solution for an invalid or already completed machine: " .. machineID)
			return
		end

		local isCorrect = machineInstance:ValidateSolution(solution)

		if isCorrect then
			print("Solution for " .. machineInstance.Part.Name .. " by " .. player.Name .. " is correct!")

			-- The RoundManager is listening for this event. This is a much cleaner way to decouple the managers.
			machineInstance.IsCompleted = true -- Mark as completed to prevent re-submission
			MachineManager.MachineCompleted:Fire(machineInstance)
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
		-- This error is now more meaningful because we know modules should be loaded.
		warn("Attempted to create an invalid or not-loaded machine type: " .. machineType)
		return nil
	end

	local newMachine = module.new(puzzleData)

	machineIdCounter += 1
	local machineID = "Machine" .. tostring(machineIdCounter)
	newMachine.ID = machineID

	activeMachines[machineID] = newMachine

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
			print("Firing ShowMachineUI for " .. machineInstance.ID .. " to " .. player.Name)
			EventManager.ShowMachineUI:FireClient(player, machineType, machineInstance.ID)
		else
			print("Default interaction: auto-completing machine.")
			machineInstance.IsCompleted = true
			MachineManager.MachineCompleted:Fire(machineInstance)
		end
	end)
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
	for id, machineInstance in pairs(activeMachines) do
		if machineInstance.Reset then
			machineInstance:Reset()
		end
		if machineInstance.Part then
			machineInstance.Part:Destroy()
			machineInstance.Part = nil
		end
	end
	activeMachines = {}
	print("All active machines have been reset and their parts destroyed.")
end

return MachineManager
