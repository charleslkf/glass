-- ServerScriptService/EventSetup.server.lua
-- This script runs once on the server to create the necessary RemoteEvents for mini-games.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local eventNames = {
    "StartSkillCheckMiniGame",
    "SkillCheckResult",
    "StartMemoryMiniGame",
    "MemoryResult",
    "StartClassicMiniGame",
    "ClassicResult",
    "CancelMiniGame"
}

for _, eventName in ipairs(eventNames) do
    if not ReplicatedStorage:FindFirstChild(eventName) then
        local remoteEvent = Instance.new("RemoteEvent")
        remoteEvent.Name = eventName
        remoteEvent.Parent = ReplicatedStorage
        print("Created RemoteEvent: " .. eventName)
    end
end

print("All mini-game RemoteEvents are ready.")
