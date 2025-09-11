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
	killerSound.SoundId = "rbxassetid://9103473772"
	killerSound.Name = "KillerAttack"
	killerSound.Parent = game.SoundService
	sounds["KillerAttack"] = killerSound

	local winningSound = Instance.new("Sound")
	winningSound.SoundId = "rbxassetid://80766655803396"
	winningSound.Name = "WinningSound"
	winningSound.Parent = game.SoundService
	sounds["WinningSound"] = winningSound

	-- Placeholder for endgame collapse sound. User should replace this ID.
	local endgameSound = Instance.new("Sound")
	endgameSound.SoundId = "rbxassetid://121178745797615"
	endgameSound.Name = "EndgameCollapse"
	endgameSound.Looped = true
	endgameSound.Parent = game.SoundService
	sounds["EndgameCollapse"] = endgameSound

	local machineFailSound = Instance.new("Sound")
	machineFailSound.SoundId = "rbxassetid://15506420081"
	machineFailSound.Name = "MachineFail"
	machineFailSound.Parent = game.SoundService
	sounds["MachineFail"] = machineFailSound

	local decoySound = Instance.new("Sound")
	decoySound.SoundId = "rbxassetid://91265893155753"
	decoySound.Name = "DecoySound"
	decoySound.Parent = game.SoundService
	sounds["DecoySound"] = decoySound

	-- Sounds for using items
	local useMedkitSound = Instance.new("Sound")
	useMedkitSound.SoundId = "rbxassetid://18613451236"
	useMedkitSound.Name = "UseMedkit"
	useMedkitSound.Parent = game.SoundService
	sounds["UseMedkit"] = useMedkitSound

	local usePicklockSound = Instance.new("Sound")
	usePicklockSound.SoundId = "rbxassetid://9117185720"
	usePicklockSound.Name = "UsePicklock"
	usePicklockSound.Parent = game.SoundService
	sounds["UsePicklock"] = usePicklockSound

	local useKeySound = Instance.new("Sound")
	useKeySound.SoundId = "rbxassetid://1836860398"
	useKeySound.Name = "UseKey"
	useKeySound.Parent = game.SoundService
	sounds["UseKey"] = useKeySound

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

function SoundManager:StopSound(soundName: string)
	local sound = sounds[soundName]
	if sound and sound.IsPlaying then
		sound:Stop()
		print("Stopping sound: " .. soundName)
	end
end

-- Initialize the manager when the script runs
SoundManager:Init()

-- Listen for the event from the server
PlaySoundEvent.OnClientEvent:Connect(function(soundName, target)
	if typeof(target) == "Instance" and target:IsA("Player") then
		-- If a specific player is targeted, only play for them.
		if target == game.Players.LocalPlayer then
			SoundManager:PlaySound(soundName)
		end
	else
		-- If no player is targeted, play the sound for everyone.
		-- This handles cases where the second argument is a position, or nil.
		SoundManager:PlaySound(soundName)
	end
end)

return SoundManager
