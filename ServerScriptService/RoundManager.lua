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
local InteractionManager = require(ServerScriptService.InteractionManager)
local GameState = game:GetService("ReplicatedStorage"):WaitForChild("GameState")

-- Constants
local MIN_PLAYERS_TO_START = 2
local LOBBY_COUNTDOWN_TIME = 10 -- 10 seconds
local INTERMISSION_TIME = 5 -- 5 seconds
local ROUND_TIME = 300 -- 5 minutes (For testing)
local ENDGAME_COLLAPSE_TIME = 120 -- 2 minutes

local completedMachines = 0
local machinesToComplete = 0
local roundTimerThread = nil
local endgameTimerThread = nil

-- Helper to get the size of a dictionary
local function table_size(t)
	local count = 0
	for _ in pairs(t) do count += 1 end
	return count
end

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

--[=[
	Powers up the exit gates, making them interactable.
]=]
function RoundManager:InitiateEndgame()
	print("All machines repaired! Powering the Exit Gates.")
	if roundTimerThread then
		task.cancel(roundTimerThread)
		roundTimerThread = nil
	end

	local poweredGates = {}
	local gateNames = {"GateA", "GateB"}
	for _, gateName in ipairs(gateNames) do
		local gateModel = Workspace:FindFirstChild(gateName)
		if gateModel then
			gateModel:SetAttribute("State", "Powered")
			-- The new gate model has a predictable structure
			local mainPart = gateModel:FindFirstChild("Main")
			if mainPart and mainPart:IsA("BasePart") then
				mainPart.Color = Color3.fromRGB(0, 255, 127) -- Bright green
			end
			print(gateName .. " has been powered.")
			table.insert(poweredGates, gateModel)
			task.wait(0.1) -- Add a small delay to see if it helps replication
		else
			warn("Could not find " .. gateName .. " in the Workspace!")
		end
	end

	-- This will eventually trigger the Endgame Collapse timer
	-- For now, it just signifies the next phase of the game
	GameState:SetAttribute("EndgameEndTime", os.time() + ENDGAME_COLLAPSE_TIME)
	GameStateManager:SetState("Endgame")
	EventManager.GatePoweredEvent:FireAllClients(poweredGates)
end


--[=[
	Handles the completion of a single machine.
]=]
function RoundManager:OnMachineCompleted(machineInstance: table)
	completedMachines += 1
	GameState:SetAttribute("MachinesCompleted", completedMachines)
	print("RoundManager: A machine was completed! Progress: " .. completedMachines .. "/" .. machinesToComplete)

	-- Fire the remote events for feedback
	EventManager.PlaySoundEvent:FireAllClients("MachineComplete")
	if machineInstance.Part then
		EventManager.PlayVFXEvent:FireAllClients("MachineComplete", machineInstance.Part.Position)
	end

	if completedMachines >= machinesToComplete then
		self:InitiateEndgame()
	end
end

--[=[
	Handles a survivor escaping, which ends the round in a win for the survivors.
]=]
function RoundManager:OnSurvivorEscaped(player: Player)
	print(player.Name .. " has escaped!")

	local activeSurvivors = PlayerManager:GetActiveSurvivors()
	if #activeSurvivors == 0 then
		print("All survivors have escaped! Survivors win the round.")
		if roundTimerThread then
			task.cancel(roundTimerThread)
			roundTimerThread = nil
		end
		if endgameTimerThread then
			task.cancel(endgameTimerThread)
			endgameTimerThread = nil
		end
		GameStateManager:SetState("Intermission")
	else
		print(#activeSurvivors .. " survivor(s) remaining.")
		self:CheckForHatchSpawn()
	end
end

function RoundManager:CheckForHatchSpawn()
	local activeSurvivors = PlayerManager:GetActiveSurvivors()
	if #activeSurvivors == 1 then
		print("Only one survivor remains! Spawning the hatch.")
		local hatches = CollectionService:GetTagged("Hatch")
		if #hatches > 0 then
			local hatch = hatches[1]
			if hatch:GetAttribute("State") == "Hidden" then
				hatch:SetAttribute("State", "Visible")
				hatch.Transparency = 0
				hatch.CanCollide = true
				-- TODO: Play a sound effect for the hatch spawning
			end
		else
			warn("Last survivor remaining, but no hatch was found in the map.")
		end
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

	InteractionManager.SurvivorEscaped.Event:Connect(function(player)
		self:OnSurvivorEscaped(player)
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
	elseif newState == "Endgame" then
		-- The InitiateEndgame function handles the transition logic.
		-- Now, start the collapse timer.
		print("Endgame Collapse has begun!")
		endgameTimerThread = task.spawn(function()
			wait(ENDGAME_COLLAPSE_TIME)
			print("Endgame Collapse timer finished. The Entity consumes all. Killer wins.")
			if GameStateManager.State == "Endgame" then
				GameStateManager:SetState("Intermission")
			end
		end)
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
	local countdownEndTime = os.time() + LOBBY_COUNTDOWN_TIME
	GameState:SetAttribute("CountdownEndTime", countdownEndTime)

	while os.time() < countdownEndTime do
		if #Players:GetPlayers() < MIN_PLAYERS_TO_START then
			print("A player left. Halting countdown.")
			GameState:SetAttribute("CountdownEndTime", nil) -- Clear the countdown
			self:Lobby() -- Re-run the lobby logic
			return
		end
		task.wait(0.5)
	end

	GameState:SetAttribute("CountdownEndTime", nil) -- Clear after countdown
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
	-- TEST: Spawn all three machine types
	local availableMachineTypes = {"ClassicMachine", "MemoryMachine", "SkillCheckMachine"}

	-- Create one of each machine type if no machines exist
	if table_size(MachineManager:GetActiveMachines()) == 0 then
		print("No machines found, creating one of each type for the round.")
		for _, machineType in ipairs(availableMachineTypes) do
			MachineManager:CreateMachine(machineType, {})
		end
	end

	-- The goal is to complete all three machines
	machinesToComplete = 3
	GameState:SetAttribute("MachinesTotal", machinesToComplete)
	GameState:SetAttribute("MachinesCompleted", 0)
	print("Round goal: Complete " .. machinesToComplete .. " machine(s).")

	-- Start a timer that can be cancelled
	local roundEndTime = os.time() + ROUND_TIME
	GameState:SetAttribute("RoundEndTime", roundEndTime)
	roundTimerThread = task.spawn(function()
		local timeLeft = roundEndTime - os.time()
		if timeLeft > 0 then
			task.wait(timeLeft)
		end

		print("Round timer finished. Killer wins.")
		-- Ensure the round hasn't already ended
		if GameStateManager.State == "InRound" then
			GameState:SetAttribute("RoundEndTime", nil)
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
