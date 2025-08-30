--!strict
--[=[
	@class RoundManager
	Manages the game rounds, including timers and player counts.
	It listens to state changes from the GameStateManager and acts accordingly.
]=]
local RoundManager = {}
RoundManager.__index = RoundManager

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameStateManager = require(ServerScriptService.GameStateManager)
local PlayerManager = require(ServerScriptService.PlayerManager)
local MachineManager = require(ServerScriptService.MachineManager)

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
	print("Now in Lobby state. Waiting for players...")

	-- Wait until there are enough players to start
	while #Players:GetPlayers() < MIN_PLAYERS_TO_START do
		print("Waiting for more players... Have " .. #Players:GetPlayers() .. "/" .. MIN_PLAYERS_TO_START)
		wait(5) -- Check every 5 seconds
	end

	print("Enough players have joined. Starting countdown...")
	-- Simple countdown loop for demonstration
	for i = LOBBY_COUNTDOWN_TIME, 1, -1 do
		print("Countdown: " .. i)
		-- Check if a player leaves during countdown
		if #Players:GetPlayers() < MIN_PLAYERS_TO_START then
			print("A player left. Halting countdown.")
			self:Lobby() -- Re-run the lobby logic
			return
		end
		wait(1)
	end

	GameStateManager:SetState("InRound")
end

--[=[
	Starts the main game round.
]=]
function RoundManager:StartRound()
	print("Round started!")

	-- Assign roles to players
	PlayerManager:AssignRoles()

	-- Main round timer
	wait(ROUND_TIME)
	GameStateManager:SetState("Intermission")
end

--[=[
	Handles the intermission logic before returning to the lobby.
]=]
function RoundManager:Intermission()
	print("Intermission.")

	-- Reset all machines for the next round
	MachineManager:ResetAllMachines()

	wait(INTERMISSION_TIME)
	GameStateManager:SetState("Lobby")
end

return RoundManager
