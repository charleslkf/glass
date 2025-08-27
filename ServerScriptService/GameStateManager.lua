-- ServerScriptService/GameStateManager.lua (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = {}
GameState.__index = GameState

-- State Management
local currentState = "Lobby"
local onStateChanged = Instance.new("BindableEvent")
GameState.OnStateChanged = onStateChanged.Event

-- Create a NumberValue for the level if it doesn't exist
local levelValue = ReplicatedStorage:FindFirstChild("CurrentLevel")
if not levelValue then
    levelValue = Instance.new("NumberValue")
    levelValue.Name = "CurrentLevel"
    levelValue.Value = 0 -- 0 means in lobby/intermission
    levelValue.Parent = ReplicatedStorage
end

local MAX_LEVEL = 10

function GameState:SetState(newState)
    if newState ~= currentState then
        currentState = newState
        onStateChanged:Fire(newState)
        print("Game state changed to: " .. newState)
    end
end

function GameState:GetState()
    return currentState
end

function GameState:StartGame()
    if currentState == "Lobby" then
        levelValue.Value = 1
        self:SetState("InRound")
    end
end

function GameState:AdvanceLevel()
    if levelValue.Value > 0 and levelValue.Value < MAX_LEVEL then
        levelValue.Value = levelValue.Value + 1
        print("Level advanced! Current level: " .. levelValue.Value)
        self:SetState("Intermission") -- Start intermission after advancing
        return true -- Level advanced successfully
    else
        print("Final level completed! Survivors win the game!")
        self:ResetGame()
        return false -- Game is over
    end
end

function GameState:ResetGame()
    levelValue.Value = 0
    self:SetState("Lobby")
end

function GameState:GetCurrentLevel()
    return levelValue.Value
end

return GameState
