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

    -- For Number Link Mini-Game
    "StartNumberLinkMiniGame",
    "NumberLinkResult",

    -- General Mini-Game Events
    "CancelMiniGame",       -- Fired by client when they walk away
    "MiniGameComplete"     -- Fired by server when a player fully completes a machine's objectives
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

-- Create the shared Status StringValue if it doesn't exist
if not ReplicatedStorage:FindFirstChild("Status") then
    local statusValue = Instance.new("StringValue")
    statusValue.Name = "Status"
    statusValue.Value = "Waiting for players..."
    statusValue.Parent = ReplicatedStorage
    print("Created StringValue: Status")
end
