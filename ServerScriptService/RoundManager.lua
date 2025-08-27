-- ServerScriptService/RoundManager.server.lua

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

local timeLeft = 0

function RoundManager:AddTime(seconds)
    timeLeft = timeLeft + seconds
    status.Value = string.format("A machine was completed! +%d seconds!", seconds)
    task.wait(1) -- show message briefly
end

local MIN_PLAYERS_TO_START = 1
local ROUND_DURATION = 60
local INTERMISSION_DURATION = 15
local GATE_OPEN_DURATION = 20

local function startRound()
    local currentLevel = GameStateManager:GetCurrentLevel()
    status.Value = string.format("Level %d is starting!", currentLevel)
    task.wait(3)

    local players = Players:GetPlayers()

    -- Check if there are any players before starting
    if #players == 0 then
        print("WARNING: startRound called with 0 players. Aborting round.")
        return "ABORTED"
    end

    -- Assign roles using the PlayerManager
    PlayerManager:AssignRoles(players)

    status.Value = "Roles have been assigned! The round has started."

    -- Main round loop
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
                else -- Role is "Killer"
                    killerPlayer = p
                end
            end
        end

        -- Check if a survivor died since last second
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
        end

        if roundInProgress then
            status.Value = string.format("Level: %d | Time: %d | Survivors: %d", currentLevel, timeLeft, survivorsAlive)
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

-- Main Game Loop
local function OnStateChanged(newState)
    task.spawn(function()
        if newState == "Lobby" then
            intermission()
            GameStateManager:SetState("InRound")
        elseif newState == "InRound" then
            local roundOutcome = startRound()
            if roundOutcome == "SURVIVORS_WIN" then
                -- Gate is now open!
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
                    GameStateManager:SetState("Lobby") -- Or a "PostGame" state
                end
            elseif roundOutcome == "KILLER_WIN" then
                status.Value = "The Killer has won. The game will now reset."
                task.wait(10)
                GameStateManager:ResetGame()
            else -- Handle ABORTED or any other unexpected outcome
                status.Value = "Round ended unexpectedly. Returning to lobby."
                task.wait(5)
                GameStateManager:SetState("Lobby")
            end
        elseif newState == "Intermission" then
            status.Value = "Survivors have won the level! Proceeding to the next."
            task.wait(5)
            GameStateManager:SetState("InRound") -- Start the next round
        end
    end)
end

-- The Start function will now just set the initial state and connect the event listener.
function RoundManager:Start()
    GameStateManager.OnStateChanged:Connect(OnStateChanged)
    -- Set the initial state to begin the game loop
    GameStateManager:SetState("Lobby")
end

return RoundManager
