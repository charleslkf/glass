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
	machineCompleteSound.SoundId = "rbxassetid://3997124966"
	machineCompleteSound.Name = "MachineComplete"
	machineCompleteSound.Parent = game.SoundService
	sounds["MachineComplete"] = machineCompleteSound

	local helperSound = Instance.new("Sound")
	helperSound.SoundId = "rbxassetid://1839901345"
	helperSound.Name = "HelperAbility"
	helperSound.Parent = game.SoundService
	sounds["HelperAbility"] = helperSound

	local stunnerSound = Instance.new("Sound")
	stunnerSound.SoundId = "rbxassetid://376107717"
	stunnerSound.Name = "StunnerAbility"
	stunnerSound.Parent = game.SoundService
	sounds["StunnerAbility"] = stunnerSound

	local killerSound = Instance.new("Sound")
	killerSound.SoundId = "rbxassetid://130334100741866"
	killerSound.Name = "KillerAttack"
	killerSound.Parent = game.SoundService
	sounds["KillerAttack"] = killerSound

	local killerStunnedSound = Instance.new("Sound")
	killerStunnedSound.SoundId = "rbxassetid://2494488494"
	killerStunnedSound.Name = "KillerStunned"
	killerStunnedSound.Parent = game.SoundService
	sounds["KillerStunned"] = killerStunnedSound

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
PlaySoundEvent.OnClientEvent:Connect(function(soundName: string, targetPlayer: Player)
	if targetPlayer then
		if targetPlayer == game.Players.LocalPlayer then
			SoundManager:PlaySound(soundName)
		end
	else
		-- If no target player, play for everyone (the default)
		SoundManager:PlaySound(soundName)
	end
end)

return SoundManager
