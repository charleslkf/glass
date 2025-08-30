--[=[
	@script Main.server
	This script is the main entry point for the server-side game logic.
	It initializes the core managers and starts the game loop.
]=]

local ServerScriptService = game:GetService("ServerScriptService")
local RoundManager = require(ServerScriptService.RoundManager)

-- Start the game!
RoundManager:Init()

print("Main.server.lua executed: RoundManager has been initialized.")
