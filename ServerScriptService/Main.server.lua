--[=[
	@script Main.server
	This script is the main entry point for the server-side game logic.
	It initializes the core managers and starts the game loop.
]=]

local ServerScriptService = game:GetService("ServerScriptService")
local PlayerManager = require(ServerScriptService.PlayerManager)
local RoundManager = require(ServerScriptService.RoundManager)

-- Initialize all core managers
PlayerManager:Init()
RoundManager:Init()

print("Main.server.lua executed: All managers have been initialized.")
