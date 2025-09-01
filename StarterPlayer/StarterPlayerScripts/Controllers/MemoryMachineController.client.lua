--!strict
--[=[
    @client
    This controller manages the UI and client-side logic for the Memory Machine minigame.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

print("MemoryMachineController.client.lua loaded.")

-- Get remote events
local EventsFolder = ReplicatedStorage:WaitForChild("GameEvents")
local ShowMachineUIEvent = EventsFolder:WaitForChild("ShowMachineUI")
local SubmitMemoryMachineSolution = EventsFolder:WaitForChild("SubmitMemoryMachineSolution")
local ShowMemoryMachinePattern = EventsFolder:WaitForChild("ShowMemoryMachinePattern")

-- Get UI module
local MemoryMachineGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("MemoryMachineGui"))

-- Create the GUI instance
local guiInstance = MemoryMachineGuiModule()
guiInstance.Parent = PlayerGui
print("MemoryMachineController: GUI instance created.")

local mainFrame = guiInstance.MainFrame
local gridContainer = mainFrame.GridContainer
local statusLabel = mainFrame.StatusLabel

local activeMachineID: string?
local playerSequence = {}
local isPlayerTurn = false
local requiredPatternLength = 0

-- --- Functions ---

local function flashButton(button: TextButton)
	local originalColor = button.BackgroundColor3
	button.BackgroundColor3 = Color3.new(1, 1, 1) -- Flash white
	task.wait(0.4)
	button.BackgroundColor3 = originalColor
	task.wait(0.2)
end

local function playPattern(pattern: {{X: number, Y: number}})
	isPlayerTurn = false
	statusLabel.Text = "Watch the pattern..."
	task.wait(1)

	for _, step in ipairs(pattern) do
		local buttonName = `Tile_{step.Y}_{step.X}`
		local button = gridContainer:FindFirstChild(buttonName)
		if button and button:IsA("TextButton") then
			flashButton(button)
		end
	end

	statusLabel.Text = `Your turn... (0/${requiredPatternLength})`
	isPlayerTurn = true
end

local function showGui(machineID: string)
	playerSequence = {}
	isPlayerTurn = false
	requiredPatternLength = 0
	statusLabel.Text = "Watch the pattern..."
	guiInstance.Enabled = true
	activeMachineID = machineID
	print("MemoryMachineController: GUI shown for machine: " .. machineID)
end

local function hideGui()
	guiInstance.Enabled = false
	activeMachineID = nil
	print("MemoryMachineController: GUI hidden.")
end

-- --- Event Connections ---

ShowMachineUIEvent.OnClientEvent:Connect(function(machineType: string, machineID: string)
	if machineType == "MemoryMachine" then
		showGui(machineID)
	end
end)

ShowMemoryMachinePattern.OnClientEvent:Connect(function(machineID: string, pattern: table, patternLength: number)
	if guiInstance.Enabled and activeMachineID == machineID then
		requiredPatternLength = patternLength
		playPattern(pattern)
	end
end)

for _, tileButton in ipairs(gridContainer:GetChildren()) do
	if tileButton:IsA("TextButton") then
		tileButton.MouseButton1Click:Connect(function()
			if not isPlayerTurn then return end

			-- Prevent adding more steps than required
			if #playerSequence >= requiredPatternLength then return end

			local gridX = tileButton:GetAttribute("GridX")
			local gridY = tileButton:GetAttribute("GridY")
			table.insert(playerSequence, {X = gridX, Y = gridY})
			statusLabel.Text = `Input recorded (${#playerSequence}/${requiredPatternLength})`

			flashButton(tileButton)

			-- FIX: Automatically submit when the sequence is complete
			if #playerSequence == requiredPatternLength then
				isPlayerTurn = false -- Prevent more clicks
				task.wait(0.5) -- Small delay for player to see the last feedback

				print("Submitting final sequence...")
				if activeMachineID then
					SubmitMemoryMachineSolution:FireServer(activeMachineID, playerSequence)
				end
				hideGui()
			end
		end)
	end
end

print("MemoryMachineController: Event listeners connected.")
