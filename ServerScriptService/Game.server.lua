-- Game.server.lua
local ServerScriptService = game:GetService("ServerScriptService")
local RoundManager = require(ServerScriptService:WaitForChild("RoundManager"))

RoundManager:Start()
