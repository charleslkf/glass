--!strict
--[=[
	@client
	@class AbilityUIController
	This client-side script will be responsible for displaying the player's
	ability, its cooldown, and handling the input to use the ability.
]=]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local UseAbilityEvent = GameEvents:WaitForChild("UseAbilityEvent")

print("AbilityUIController loaded for player.")

-- This is a placeholder for the full UI implementation.
-- In the future, this script will create the UI elements.

local function onInputBegan(input, gameProcessedEvent)
	-- Ignore input if the user is typing in a textbox
	if gameProcessedEvent then return end

	-- Check if the 'Q' key was pressed
	if input.KeyCode == Enum.KeyCode.Q then
		print("'Q' key pressed. Firing UseAbilityEvent to server.")
		UseAbilityEvent:FireServer()
	end
end

-- Listen for input
UserInputService.InputBegan:Connect(onInputBegan)
