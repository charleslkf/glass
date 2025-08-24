-- ServerScriptService/EventSetup.server.lua

print("RUNNING FINAL DEBUG VERSION of EventSetup.server.lua")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local eventNames = {
	"StartSkillCheckMiniGame",
	"SkillCheckResult",
	"StartMemoryMiniGame",
	"MemoryResult",
	"CancelMiniGame",
	"MiniGameComplete",
	"StartNumberLinkMiniGame",
	"NumberLinkResult"
}

print("Event names to be created:", #eventNames)

for index, name in ipairs(eventNames) do
	print("Loop " .. index .. ": Processing event '" .. name .. "'") -- This will show us each step of the loop
	if not ReplicatedStorage:FindFirstChild(name) then
		local event = Instance.new("RemoteEvent")
		event.Name = name
		event.Parent = ReplicatedStorage
		print("--> SUCCESS: Created RemoteEvent: " .. name)
	else
		print("--> INFO: Event already exists: " .. name)
	end
end

print("All mini-game RemoteEvents are ready.")
