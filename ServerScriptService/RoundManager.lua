-- ServerScriptService/RoundManager.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameStateManager = require(ServerScriptService:WaitForChild("GameStateManager"))
local PlayerManager = require(ServerScriptService:WaitForChild("PlayerManager"))

local RoundManager = {}

-- Get/Create Status StringValue
local status = ReplicatedStorage:FindFirstChild("Status")
if not status then
    status = Instance.new("StringValue")
    status.Name = "Status"
    status.Value = "Waiting for players..." -- Set default value on creation
    status.Parent = ReplicatedStorage
end

-- Machine Completion Event
local machineCompletedEvent = ReplicatedStorage:FindFirstChild("MachineCompletedEvent") or Instance.new("BindableEvent", ReplicatedStorage)
machineCompletedEvent.Name = "MachineCompletedEvent"

local timeLeft = 0
local machinesCompleted = 0
local MACHINES_PER_LEVEL = 5 -- The number of machines survivors need to complete

local function onMachineCompleted()
    machinesCompleted = machinesCompleted + 1
    timeLeft = timeLeft + 10 -- Add 10 seconds
    status.Value = "A machine was completed! +10 seconds!"
    task.wait(1)
end

machineCompletedEvent.Event:Connect(onMachineCompleted)

local MIN_PLAYERS_TO_START = 2
local ROUND_DURATION = 120
local INTERMISSION_DURATION = 15
local GATE_OPEN_DURATION = 20

local function startRound()
    machinesCompleted = 0 -- Reset for the new round
    local currentLevel = GameStateManager:GetCurrentLevel()
    status.Value = string.format("Level %d is starting!", currentLevel)
    task.wait(3)

    local players = Players:GetPlayers()

    if #players == 0 then
        print("WARNING: startRound called with 0 players. Aborting round.")
        return "ABORTED"
    end

    PlayerManager:AssignRoles(players)
    status.Value = "Roles have been assigned! The round has started."

    timeLeft = ROUND_DURATION
    local roundInProgress = true
    local outcome = "KILLER_WIN"
    local survivorsLastTick = -1

    while timeLeft > 0 and roundInProgress do
        local survivorsAlive = 0
        local killerPlayer = nil
        for _, p in ipairs(players) do
            if p:IsDescendantOf(Players) then
                if p:GetAttribute("Role") ~= "Killer" then
                    if p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health > 0 then
                        survivorsAlive = survivorsAlive + 1
                    end
                else
                    killerPlayer = p
                end
            end
        end

        if survivorsLastTick ~= -1 and survivorsAlive < survivorsLastTick then
            local survivorsKilled = survivorsLastTick - survivorsAlive
            timeLeft = timeLeft - (10 * survivorsKilled)
            status.Value = string.format("%d survivor(s) killed! -%d seconds!", survivorsKilled, 10 * survivorsKilled)
            task.wait(1)
        end
        survivorsLastTick = survivorsAlive

        local killerIsAlive = killerPlayer and killerPlayer.Character and killerPlayer.Character:FindFirstChildOfClass("Humanoid") and killerPlayer.Character.Humanoid.Health > 0

        if survivorsAlive == 0 then
            status.Value = "All survivors have been eliminated! The Killer wins!"
            roundInProgress = false
            outcome = "KILLER_WIN"
        elseif not killerIsAlive then
            status.Value = "The Killer has been defeated! Survivors win!"
            roundInProgress = false
            outcome = "SURVIVORS_WIN"
        elseif machinesCompleted >= MACHINES_PER_LEVEL then
            status.Value = "All machines repaired! Survivors win the level!"
            roundInProgress = false
            outcome = "SURVIVORS_WIN"
        end

        if roundInProgress then
            status.Value = string.format("Level: %d | Machines: %d/%d | Time: %d", currentLevel, machinesCompleted, MACHINES_PER_LEVEL, timeLeft)
            timeLeft = timeLeft - 1
            task.wait(1)
        end
    end

    if timeLeft <= 0 and roundInProgress then
        status.Value = "Time's up! The Killer wins!"
        outcome = "KILLER_WIN"
    end

    task.wait(5)
    for _, player in ipairs(players) do
        if player:IsDescendantOf(Players) then
            player:SetAttribute("Role", nil)
        end
    end

    return outcome
end

local function intermission()
    status.Value = "Intermission. Waiting for players..."
    while #Players:GetPlayers() < MIN_PLAYERS_TO_START do
        status.Value = string.format("Waiting for players... (%d/%d)", #Players:GetPlayers(), MIN_PLAYERS_TO_START)
        task.wait(1)
    end

    status.Value = "Enough players have joined! Starting game soon..."
    for i = INTERMISSION_DURATION, 0, -1 do
        status.Value = string.format("Game starts in: %d", i)
        task.wait(1)
    end
end

local function OnStateChanged(newState)
    task.spawn(function()
        if newState == "Lobby" then
            intermission()
            GameStateManager:SetState("InRound")
        elseif newState == "InRound" then
            local roundOutcome = startRound()
            if roundOutcome == "SURVIVORS_WIN" then
                for i = GATE_OPEN_DURATION, 0, -1 do
                    status.Value = string.format("Gate is open! Closes in: %d", i)
                    task.wait(1)
                end
                status.Value = "The gate is now closed!"
                task.wait(2)

                local gameContinues = GameStateManager:AdvanceLevel()
                if not gameContinues then
                    status.Value = "Congratulations! Survivors have completed all levels!"
                    task.wait(10)
                    GameStateManager:SetState("Lobby")
                end
            elseif roundOutcome == "KILLER_WIN" then
                status.Value = "The Killer has won. The game will now reset."
                task.wait(10)
                GameStateManager:ResetGame()
            else
                status.Value = "Round ended unexpectedly. Returning to lobby."
                task.wait(5)
                GameStateManager:SetState("Lobby")
            end
        elseif newState == "Intermission" then
            status.Value = "Survivors have won the level! Proceeding to the next."
            task.wait(5)
            GameStateManager:SetState("InRound")
        end
    end)
end

function RoundManager:Start()
    GameStateManager.OnStateChanged:Connect(OnStateChanged)
    OnStateChanged(GameStateManager:GetState())
end

return RoundManager
