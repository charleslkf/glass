--[=[
	@script Main.server
	This script is the main entry point for the server-side game logic.
	It initializes the core managers and starts the game loop.
]=]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create the shared GameState object if it doesn't exist
local gameState = ReplicatedStorage:FindFirstChild("GameState")
if not gameState then
	gameState = Instance.new("Configuration")
	gameState.Name = "GameState"
	gameState:SetAttribute("State", "Lobby") -- Initial state
	gameState.Parent = ReplicatedStorage
end

-- Require all managers
local DataManager = require(ServerScriptService.DataManager)
local PlayerManager = require(ServerScriptService.PlayerManager)
local RoundManager = require(ServerScriptService.RoundManager)
local AbilityManager = require(ServerScriptService.AbilityManager)
local EventManager = require(ServerScriptService.EventManager)
local KillerManager = require(ServerScriptService.KillerManager)
local InteractionManager = require(ServerScriptService.InteractionManager)

-- Safely require the MachineManager to catch and log any initialization errors
local success, MachineManager = pcall(require, ServerScriptService.MachineManager)
if not success or not MachineManager then
    warn("!!! CRITICAL: MachineManager failed to load. The module will be disabled. Error:", MachineManager)
    -- Create a dummy table so the server doesn't crash on the subsequent Init call
    MachineManager = { Init = function() end }
end

-- Build the map before initializing managers that might depend on it
local MapBuilder = require(ServerScriptService.MapBuilder)
MapBuilder.BuildMap()

-- Initialize all core managers. DataManager should come first.
DataManager:Init()
PlayerManager:Init()
KillerManager:Initialize(PlayerManager)
AbilityManager:Init()
EventManager:Init()
InteractionManager:Init()
MachineManager:Init()
RoundManager:Init() -- RoundManager should generally be last

print("Main.server.lua executed: All managers have been initialized.")
