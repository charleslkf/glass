-- ServerScriptService/EventSetup.server.lua

-- This script creates all the RemoteEvents needed for the mini-games.
-- It ensures that they exist before any other script tries to access them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local eventNames = {
    -- For Skill Check Mini-Game
    "StartSkillCheckMiniGame",
    "SkillCheckResult",

    -- For Memory Mini-Game
    "StartMemoryMiniGame",
    "MemoryResult",

    -- General Mini-Game Events
    "CancelMiniGame",       -- Fired by client when they walk away
    "MiniGameComplete",     -- Fired by server when a player fully completes a machine's objectives
    "MachineCompletedEvent" -- Fired by MachineManager when a machine is completed, listened to by GameStateManager
}

for _, name in ipairs(eventNames) do
    if not ReplicatedStorage:FindFirstChild(name) then
        local event = Instance.new("RemoteEvent")
        event.Name = name
        event.Parent = ReplicatedStorage
        print("Created RemoteEvent: " .. name)
    end
end

print("All mini-game RemoteEvents are ready.")
