--[=[
	@script Main.server
	This script is the main entry point for the server-side game logic.
	It initializes the core managers and starts the game loop.
]=]

local ServerScriptService = game:GetService("ServerScriptService")

-- Require all managers
local DataManager = require(ServerScriptService.DataManager)
local PlayerManager = require(ServerScriptService.PlayerManager)
local RoundManager = require(ServerScriptService.RoundManager)
local AbilityManager = require(ServerScriptService.AbilityManager)
local EventManager = require(ServerScriptService.EventManager)

-- Safely require the MachineManager to catch and log any initialization errors
local success, MachineManager = pcall(require, ServerScriptService.MachineManager)
if not success or not MachineManager then
    warn("!!! CRITICAL: MachineManager failed to load. The module will be disabled. Error:", MachineManager)
    -- Create a dummy table so the server doesn't crash on the subsequent Init call
    MachineManager = { Init = function() end }
end

-- Initialize all core managers. DataManager should come first.
DataManager:Init()
PlayerManager:Init()
AbilityManager:Init()
EventManager:Init()
MachineManager:Init()
RoundManager:Init() -- RoundManager should generally be last

print("Main.server.lua executed: All managers have been initialized.")
