-- ServerScriptService/Main.server.lua
-- This script is the main entry point for the server-side game logic.

local ServerScriptService = game:GetService("ServerScriptService")

-- We require the RoundManager module, which in turn requires the GameStateManager.
-- We require all major manager modules to ensure they are loaded and running.
local PlayerManager = require(ServerScriptService:WaitForChild("PlayerManager"))
local RoundManager = require(ServerScriptService:WaitForChild("RoundManager"))

-- Initialize the managers
PlayerManager:Init()

-- Start the game loop.
RoundManager:Start()

print("Main.server.lua: Game loop started.")
