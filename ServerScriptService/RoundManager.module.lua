-- ServerScriptService/RoundManager.module.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local GameStateManager = require(ServerScriptService:WaitForChild("GameStateManager"))

local RoundManager = {}

-- Get/Create Status StringValue
local status = ReplicatedStorage:FindFirstChild("Status") or Instance.new("StringValue", ReplicatedStorage)
status.Name = "Status"

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

    -- Assign roles
    local survivorRoles = {"Survivor", "Stunner", "Helper"}
    local killer = players[math.random(1, #players)]

    for _, player in ipairs(players) do
        if player == killer then
            player:SetAttribute("Role", "Killer")
            print(player.Name .. " has been chosen as the Killer!")
        else
            local assignedRole = survivorRoles[math.random(1, #survivorRoles)]
            player:SetAttribute("Role", assignedRole)
            print(player.Name .. " is a " .. assignedRole)
        end
    end

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
function RoundManager:Start()
    -- Main Game Loop
    while true do
        intermission()
        GameStateManager:StartGame()

        local gameActive = true
        while gameActive do
            local roundOutcome = startRound()

            if roundOutcome == "SURVIVORS_WIN" then
                -- Gate is now open!
                for i = GATE_OPEN_DURATION, 0, -1 do
                    status.Value = string.format("Gate is open! Closes in: %d", i)
                    task.wait(1)
                end
                status.Value = "The gate is now closed!"
                task.wait(2)
                -- Placeholder: For now, we assume everyone made it. A future step would check this.

                local gameContinues = GameStateManager:AdvanceLevel()
                if not gameContinues then
                    status.Value = "Congratulations! Survivors have completed all levels!"
                    task.wait(10)
                    gameActive = false
                else
                    status.Value = "Survivors have won the level! Proceeding to the next."
                    task.wait(5)
                end
            else -- Killer wins
                status.Value = "The Killer has won. The game will now reset."
                task.wait(10)
                GameStateManager:ResetGame()
                gameActive = false
            end
        end
    end
end

return RoundManager
