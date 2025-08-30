--!strict
--[=[
	@class RoundManager
	Manages the game rounds, including timers and player counts.
	It listens to state changes from the GameStateManager and acts accordingly.
]=]
local RoundManager = {}
RoundManager.__index = RoundManager

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameStateManager = require(ServerScriptService.GameStateManager)

-- Constants
local MIN_PLAYERS_TO_START = 2
local LOBBY_COUNTDOWN_TIME = 10 -- 10 seconds
local INTERMISSION_TIME = 5 -- 5 seconds
local ROUND_TIME = 120 -- 2 minutes

--[=[
	Initializes the RoundManager, connecting it to the GameStateManager's events.
]=]
function RoundManager:Init()
	GameStateManager.StateChanged:Connect(function(newState)
		self:OnStateChanged(newState)
	end)
end

--[=[
	Handles the logic for different game states.
	@param newState string The new state from the GameStateManager.
]=]
function RoundManager:OnStateChanged(newState: string)
	if newState == "Lobby" then
		self:Lobby()
	elseif newState == "InRound" then
		self:StartRound()
	elseif newState == "Intermission" then
		self:Intermission()
	end
end

--[=[
	Handles the lobby logic, starting a countdown if enough players are present.
]=]
function RoundManager:Lobby()
	print("Now in Lobby state.")
	-- Simple countdown loop for demonstration
	for i = LOBBY_COUNTDOWN_TIME, 1, -1 do
		print("Countdown: " .. i)
		wait(1)
	end
	GameStateManager:SetState("InRound")
end

--[=[
	Starts the main game round.
]=]
function RoundManager:StartRound()
	print("Round started!")
	-- Main round timer
	wait(ROUND_TIME)
	GameStateManager:SetState("Intermission")
end

--[=[
	Handles the intermission logic before returning to the lobby.
]=]
function RoundManager:Intermission()
	print("Intermission.")
	wait(INTERMISSION_TIME)
	GameStateManager:SetState("Lobby")
end

return RoundManager
