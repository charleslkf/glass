-- ServerScriptService/Main.server.lua
-- This script is the main entry point for the server-side game logic.

local ServerScriptService = game:GetService("ServerScriptService")

-- We require the RoundManager module, which in turn requires the GameStateManager.
-- This ensures all necessary modules are loaded before we start the game.
local RoundManager = require(ServerScriptService:WaitForChild("RoundManager"))

-- Start the game loop.
RoundManager:Start()

print("Main.server.lua: Game loop started.")
