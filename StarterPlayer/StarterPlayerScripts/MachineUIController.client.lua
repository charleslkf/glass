-- StarterPlayer/StarterPlayerScripts/MachineUIController.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local ThemeManager = require(script.Parent:WaitForChild("ThemeManager"))
local SkillCheck = require(script.Parent.MiniGames:WaitForChild("SkillCheck"))
local MemoryGame = require(script.Parent.MiniGames:WaitForChild("MemoryGame"))
local NumberLink = require(script.Parent.MiniGames:WaitForChild("NumberLink"))

-- Remote Events
local startSkillCheckEvent = ReplicatedStorage:WaitForChild("StartSkillCheckMiniGame")
local startMemoryEvent = ReplicatedStorage:WaitForChild("StartMemoryMiniGame")
local startNumberLinkEvent = ReplicatedStorage:WaitForChild("StartNumberLinkMiniGame")
local cancelEvent = ReplicatedStorage:WaitForChild("CancelMiniGame")
local miniGameCompleteEvent = ReplicatedStorage:WaitForChild("MiniGameComplete")

local MAX_INTERACTION_DISTANCE = 12

-- UI Creation
local screenGui = playerGui:FindFirstChild("MachineGUIs") or Instance.new("ScreenGui", playerGui)
screenGui.Name = "MachineGUIs"
screenGui.ResetOnSpawn = false

local mainFrame = screenGui:FindFirstChild("MainFrame") or Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.BackgroundTransparency = 1

-- Create all mini-game UIs
SkillCheck.Create(mainFrame, ThemeManager)
MemoryGame.Create(mainFrame, ThemeManager)
NumberLink.Create(mainFrame, ThemeManager)

-- Logic
local activeGame = nil

local function closeAllGames()
    if activeGame then
        activeGame.Close()
        activeGame = nil
    end
end

-- Event Connections
startSkillCheckEvent.OnClientEvent:Connect(function(machine, currentProgress, neededProgress)
    closeAllGames()
    activeGame = SkillCheck
    SkillCheck.Run(machine, currentProgress, neededProgress, closeAllGames, ThemeManager)
end)

startMemoryEvent.OnClientEvent:Connect(function(machine, gridSize, pattern, currentProgress, neededProgress)
    closeAllGames()
    activeGame = MemoryGame
    MemoryGame.Run(machine, gridSize, pattern, currentProgress, neededProgress, closeAllGames, ThemeManager)
end)

startNumberLinkEvent.OnClientEvent:Connect(function(machine, puzzleData, currentProgress, neededProgress)
    closeAllGames()
    activeGame = NumberLink
    NumberLink.Run(machine, puzzleData, currentProgress, neededProgress, closeAllGames, ThemeManager)
end)

cancelEvent.OnClientEvent:Connect(closeAllGames)
miniGameCompleteEvent.OnClientEvent:Connect(function()
    print("Client received MiniGameComplete signal.")
    closeAllGames()
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent or not activeGame then return end
    if input.KeyCode == Enum.KeyCode.Backspace then
        cancelEvent:FireServer(activeGame.CurrentMachine)
        closeAllGames()
    end
end)

RunService.RenderStepped:Connect(function()
    if activeGame and activeGame.CurrentMachine then
        local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not rootPart then closeAllGames(); return end
        if typeof(activeGame.CurrentMachine) ~= "Instance" or not activeGame.CurrentMachine.Parent then closeAllGames(); return end

        local success, distance = pcall(function()
            return (rootPart.Position - activeGame.CurrentMachine.Position).Magnitude
        end)

        if success and distance > MAX_INTERACTION_DISTANCE then
            cancelEvent:FireServer(activeGame.CurrentMachine)
            closeAllGames()
        elseif not success then
            closeAllGames()
        end
    end
end)

print("MachineUIController initialized and refactored.")
