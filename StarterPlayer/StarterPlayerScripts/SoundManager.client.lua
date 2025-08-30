--!strict
--[=[
	@client
	@class SoundManager
	This client-side module handles loading and playing all game sound effects.
]=]
local SoundManager = {}

-- A dictionary to hold our sound objects
local sounds = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local PlaySoundEvent = GameEvents:WaitForChild("PlaySoundEvent")

--[=[
	Initializes the SoundManager and pre-loads the sounds.
]=]
function SoundManager:Init()
	print("SoundManager initializing...")

	-- In the future, we can populate this from a folder in ReplicatedStorage
	-- For now, we'll define a placeholder sound here.
	local machineCompleteSound = Instance.new("Sound")
	machineCompleteSound.SoundId = "rbxassetid://1842267866" -- A generic "success" sound from the library
	machineCompleteSound.Name = "MachineComplete"
	machineCompleteSound.Parent = game.SoundService -- Store sounds in SoundService

	sounds["MachineComplete"] = machineCompleteSound

	print("SoundManager initialized.")
end

--[=[
	Plays a sound by name.
	@param soundName string The name of the sound to play.
]=]
function SoundManager:PlaySound(soundName: string)
	local sound = sounds[soundName]
	if sound then
		sound:Play()
		print("Playing sound: " .. soundName)
	else
		warn("Attempted to play unknown sound: " .. soundName)
	end
end

-- Initialize the manager when the script runs
SoundManager:Init()

-- Listen for the event from the server
PlaySoundEvent.OnClientEvent:Connect(function(soundName: string)
	SoundManager:PlaySound(soundName)
end)

return SoundManager
