-- StarterPlayer/StarterPlayerScripts/MachineUIController.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local startSkillCheckEvent = ReplicatedStorage:WaitForChild("StartSkillCheckMiniGame")
local skillCheckResultEvent = ReplicatedStorage:WaitForChild("SkillCheckResult")
local startMemoryEvent = ReplicatedStorage:WaitForChild("StartMemoryMiniGame")
local memoryResultEvent = ReplicatedStorage:WaitForChild("MemoryResult")
local startNumberLinkEvent = ReplicatedStorage:WaitForChild("StartNumberLinkMiniGame")
local numberLinkResultEvent = ReplicatedStorage:WaitForChild("NumberLinkResult")
local cancelEvent = ReplicatedStorage:WaitForChild("CancelMiniGame")
local miniGameCompleteEvent = ReplicatedStorage:WaitForChild("MiniGameComplete")

-- Mini-Game Modules
local MiniGames = script.Parent:WaitForChild("MiniGames")
local SkillCheck = require(MiniGames:WaitForChild("SkillCheck"))
local MemoryGame = require(MiniGames:WaitForChild("MemoryGame"))
local NumberLink = require(MiniGames:WaitForChild("NumberLink"))

local MAX_INTERACTION_DISTANCE = 12

-- UI Creation
local screenGui = playerGui:FindFirstChild("MachineGUIs") or Instance.new("ScreenGui", playerGui)
screenGui.Name = "MachineGUIs"
screenGui.ResetOnSpawn = false

local mainFrame = screenGui:FindFirstChild("MainFrame") or Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1

-- --- Logic ---
local isGameActive = false
local currentMachine = nil
local activeGameModule = nil

-- Initialize Mini-Game Modules
local skillCheckGame = SkillCheck.new(mainFrame, skillCheckResultEvent)
local memoryGame = MemoryGame.new(mainFrame, memoryResultEvent)
local numberLinkGame = NumberLink.new(mainFrame, numberLinkResultEvent)

local function closeCurrentGame()
	if not isGameActive then return end

	isGameActive = false
	currentMachine = nil
	if activeGameModule then
		activeGameModule:Close()
		activeGameModule = nil
	end
end

-- --- Event Connections ---
startSkillCheckEvent.OnClientEvent:Connect(function(machine, currentProgress, neededProgress)
	closeCurrentGame() -- Ensure no other game is running
	isGameActive = true
	currentMachine = machine
	activeGameModule = skillCheckGame
	skillCheckGame:Run(machine, currentProgress, neededProgress)
end)

startMemoryEvent.OnClientEvent:Connect(function(machine, gridSize, pattern, currentProgress, neededProgress)
	closeCurrentGame()
	isGameActive = true
	currentMachine = machine
	activeGameModule = memoryGame
	memoryGame:Run(machine, gridSize, pattern, currentProgress, neededProgress)
end)

startNumberLinkEvent.OnClientEvent:Connect(function(machine, puzzleData, currentProgress, neededProgress)
	closeCurrentGame()
	isGameActive = true
	currentMachine = machine
	activeGameModule = numberLinkGame
	numberLinkGame:Run(machine, puzzleData, currentProgress, neededProgress)
end)

cancelEvent.OnClientEvent:Connect(closeCurrentGame)
miniGameCompleteEvent.OnClientEvent:Connect(function()
	print("Client received MiniGameComplete signal.")
	closeCurrentGame()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent or not isGameActive then return end
	if input.KeyCode == Enum.KeyCode.Backspace then
		cancelEvent:FireServer(currentMachine)
		closeCurrentGame()
	end
end)

RunService.RenderStepped:Connect(function()
	if isGameActive and currentMachine then
		local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not rootPart then closeCurrentGame(); return end

		-- Use a pcall to prevent errors if the machine is destroyed mid-frame
		local success, distance = pcall(function()
			return (rootPart.Position - currentMachine.Position).Magnitude
		end)

		if success and distance > MAX_INTERACTION_DISTANCE then
			cancelEvent:FireServer(currentMachine)
			closeCurrentGame()
		elseif not success then
			-- This can happen if the machine instance is destroyed.
			closeCurrentGame()
		end
	end
end)

print("MachineUIController (Refactored) initialized.")
