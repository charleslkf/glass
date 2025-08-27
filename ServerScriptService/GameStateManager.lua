-- ServerScriptService/GameStateManager.lua (ModuleScript)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameState = {}
GameState.__index = GameState

-- Create a NumberValue for the level if it doesn't exist
local levelValue = ReplicatedStorage:FindFirstChild("CurrentLevel")
if not levelValue then
    levelValue = Instance.new("NumberValue")
    levelValue.Name = "CurrentLevel"
    levelValue.Value = 0 -- 0 means in lobby/intermission
    levelValue.Parent = ReplicatedStorage
end

local MAX_LEVEL = 10

function GameState:StartGame()
    if levelValue.Value == 0 then
        levelValue.Value = 1
        print("Game started! Current level: " .. levelValue.Value)
    end
end

function GameState:AdvanceLevel()
    if levelValue.Value > 0 and levelValue.Value < MAX_LEVEL then
        levelValue.Value = levelValue.Value + 1
        print("Level advanced! Current level: " .. levelValue.Value)
        return true -- Level advanced successfully
    else
        print("Final level completed! Survivors win the game!")
        self:ResetGame()
        return false -- Game is over
    end
end

function GameState:ResetGame()
    levelValue.Value = 0
    print("Game state has been reset. Returning to lobby.")
end

function GameState:GetCurrentLevel()
    return levelValue.Value
end

return GameState
