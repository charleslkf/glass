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
local EventManager = require(ServerScriptService.EventManager)

-- Constants
local MIN_PLAYERS_TO_START = 2
local LOBBY_COUNTDOWN_TIME = 10 -- 10 seconds
local INTERMISSION_TIME = 5 -- 5 seconds
local ROUND_TIME = 300 -- 5 minutes (For testing)
local GENERATORS_TO_COMPLETE = 5

local completedMachines = 0
local machinesToComplete = 0
local roundTimerThread = nil

-- Helper to get the size of a dictionary
local function table_size(t)
	local count = 0
	for _ in pairs(t) do count += 1 end
	return count
end

--[=[
	Handles the completion of a single machine.
]=]
function RoundManager:OnMachineCompleted(machineInstance: table)
	completedMachines += 1
	print("RoundManager: A machine was completed! Progress: " .. completedMachines .. "/" .. machinesToComplete)

	-- Fire the remote events for feedback
	EventManager.PlaySoundEvent:FireAllClients("MachineComplete")
	if machineInstance.Part then
		EventManager.PlayVFXEvent:FireAllClients("MachineComplete", machineInstance.Part.Position)
	end

	if completedMachines >= machinesToComplete then
		print("All machines completed! Triggering Endgame.")
		EventManager.AllGeneratorsRepaired:FireAllClients()

		-- For now, we will still end the round. The Exit Gate logic will be added in the next task.
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
	-- Create the required number of generators for the round.
	-- For the MVP, all generators will be the "SkillCheckMachine" type.
	if table_size(MachineManager:GetActiveMachines()) == 0 then
		print("Spawning " .. GENERATORS_TO_COMPLETE .. " generators for the round.")
		for i = 1, GENERATORS_TO_COMPLETE do
			MachineManager:CreateMachine("SkillCheckMachine", {})
		end
	end

	-- Set the round's objective
	machinesToComplete = GENERATORS_TO_COMPLETE
	print("Round goal: Complete " .. machinesToComplete .. " generators.")

	-- Start a timer that can be cancelled
	roundTimerThread = task.spawn(function()
		wait(ROUND_TIME)
		print("Round timer finished. Killer wins.")
		-- Ensure the round hasn't already ended
		if GameStateManager.State == "InRound" then
			GameStateManager:SetState("Intermission")
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
