--[=[
	@script Main.server
	This script is the main entry point for the server-side game logic.
	It initializes the core managers and starts the game loop.
]=]

local ServerScriptService = game:GetService("ServerScriptService")
local DataManager = require(ServerScriptService.DataManager)
local PlayerManager = require(ServerScriptService.PlayerManager)
local RoundManager = require(ServerScriptService.RoundManager)
local AbilityManager = require(ServerScriptService.AbilityManager)
local EventManager = require(ServerScriptService.EventManager)

-- Initialize all core managers. DataManager should come first.
DataManager:Init()
PlayerManager:Init()
AbilityManager:Init()
EventManager:Init()
RoundManager:Init() -- RoundManager should generally be last

print("Main.server.lua executed: All managers have been initialized.")
