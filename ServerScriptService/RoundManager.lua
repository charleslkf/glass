--!strict
--[=[
	@class RoundManager
	Manages the game rounds, including timers and player counts.
	It listens to state changes from the GameStateManager and acts accordingly.
]=]
local RoundManager = {}
RoundManager.__index = RoundManager

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local GameStateManager = require(ServerScriptService.GameStateManager)
local PlayerManager = require(ServerScriptService.PlayerManager)
local MachineManager = require(ServerScriptService.MachineManager)

-- Constants
local MIN_PLAYERS_TO_START = 2
local LOBBY_COUNTDOWN_TIME = 10 -- 10 seconds
local INTERMISSION_TIME = 5 -- 5 seconds
local ROUND_TIME = 120 -- 2 minutes

local completedMachines = 0
local machinesToComplete = 0
local roundTimerThread = nil

--[=[
	Handles the completion of a single machine.
]=]
function RoundManager:OnMachineCompleted(machineInstance: table)
	completedMachines += 1
	print("RoundManager: A machine was completed! Progress: " .. completedMachines .. "/" .. machinesToComplete)

	if completedMachines >= machinesToComplete then
		print("All machines completed! Survivors win the round.")
		if roundTimerThread then
			task.cancel(roundTimerThread)
			roundTimerThread = nil
		end
		GameStateManager:SetState("Intermission")
	end
end

--[=[
	Initializes the RoundManager, connecting it to the GameStateManager's events.
]=]
function RoundManager:Init()
	-- Initialize other managers first
	MachineManager:Init()

	GameStateManager.StateChanged.Event:Connect(function(newState)
		self:OnStateChanged(newState)
	end)

	MachineManager.MachineCompleted.Event:Connect(function(machineInstance)
		self:OnMachineCompleted(machineInstance)
	end)

	-- Manually trigger the logic for the initial state to kick-start the game
	self:OnStateChanged(GameStateManager.State)
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

	while #Players:GetPlayers() < MIN_PLAYERS_TO_START do
		print("Waiting for more players... Have " .. #Players:GetPlayers() .. "/" .. MIN_PLAYERS_TO_START)
		wait(5)
	end

	print("Enough players have joined. Starting countdown...")
	for i = LOBBY_COUNTDOWN_TIME, 1, -1 do
		print("Countdown: " .. i)
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

	PlayerManager:AssignRoles()

	-- Set up the round goal
	completedMachines = 0
	local activeMachines = MachineManager:GetActiveMachines()
	if #activeMachines == 0 then
		print("No machines found, creating one for the round.")
		MachineManager:CreateMachine("ClassicMachine", {GridSize=3, Dots={{1,1,3,3}}})
	end
	machinesToComplete = #MachineManager:GetActiveMachines()
	print("Round goal: Complete " .. machinesToComplete .. " machine(s).")

	-- Start a timer that can be cancelled
	roundTimerThread = task.spawn(function()
		wait(ROUND_TIME)
		print("Round timer finished. Killer wins.")
		-- Ensure the round hasn't already ended
		if GameStateManager.State == "InRound" then
			GameStateManager:SetState("Intermission")
		end
	end)

	-- DEBUG: Auto-complete the machine after 10 seconds to test the sound event
	task.delay(10, function()
		if GameStateManager.State == "InRound" then
			local machine = MachineManager:GetActiveMachines()[1]
			if machine then
				MachineManager:Debug_CompleteMachine(machine)
			end
		end
	end)
end

--[=[
	Handles the intermission logic before returning to the lobby.
]=]
function RoundManager:Intermission()
	print("Intermission.")

	MachineManager:ResetAllMachines()

	wait(INTERMISSION_TIME)
	GameStateManager:SetState("Lobby")
end

return RoundManager
