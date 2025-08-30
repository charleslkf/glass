-- ServerScriptService/Main.server.lua

-- This script is the single entry point for all server-side logic.
-- It ensures that modules are loaded in the correct order to prevent
-- race conditions and dependency issues.

local ServerScriptService = game:GetService("ServerScriptService")

-- Load all necessary modules first.
-- EventSetup must be first as it creates events other scripts might use immediately.
require(ServerScriptService:WaitForChild("EventSetup"))

-- GameState and Round logic are the core systems.
local GameStateManager = require(ServerScriptService:WaitForChild("GameStateManager"))
local RoundManager = require(ServerScriptService:WaitForChild("RoundManager"))

-- Managers for specific game elements.
local PlayerManager = require(ServerScriptService:WaitForChild("PlayerManager"))
local MachineManager = require(ServerScriptService:WaitForChild("MachineManager"))

print("All server modules loaded.")

-- Create a table of loaded modules to pass as dependencies.
-- This makes dependencies explicit and avoids circular require() issues.
local modules = {
    GameStateManager = GameStateManager,
    RoundManager = RoundManager,
    PlayerManager = PlayerManager,
    MachineManager = MachineManager
}

-- Start the services in a controlled order.
-- PlayerManager can start listening for players immediately.
PlayerManager.Start()
-- MachineManager needs the core modules to be loaded.
MachineManager.Start(modules)
-- RoundManager starts the main game loop and needs all other modules to be ready.
RoundManager:Start(modules)

print("All server systems started correctly via Main.server.lua.")
