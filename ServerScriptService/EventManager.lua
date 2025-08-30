--!strict
--[=[
	@class EventManager
	Manages and creates global RemoteEvents for server-client communication.
]=]
local EventManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a folder to hold all game events
local eventsFolder = Instance.new("Folder")
eventsFolder.Name = "GameEvents"
eventsFolder.Parent = ReplicatedStorage

-- Create specific events
EventManager.PlaySoundEvent = Instance.new("RemoteEvent")
EventManager.PlaySoundEvent.Name = "PlaySoundEvent"
EventManager.PlaySoundEvent.Parent = eventsFolder

-- This function is just to ensure the module is loaded and the events are created.
function EventManager:Init()
	print("EventManager initialized and events created.")
end

return EventManager
