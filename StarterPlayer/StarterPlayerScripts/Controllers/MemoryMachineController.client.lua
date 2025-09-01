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

-- --- Functions to control the GUI ---

local function showGui(machineID: string)
	playerSequence = {} -- Reset sequence
	statusLabel.Text = "Watch the pattern..."
	guiInstance.Enabled = true
	activeMachineID = machineID
	print("MemoryMachineController: GUI shown for machine: " .. machineID)
	-- In the future, this is where we would receive and display the pattern.
end

local function hideGui()
	guiInstance.Enabled = false
	activeMachineID = nil
	print("MemoryMachineController: GUI hidden.")
end

-- --- Event Connections ---

-- Listen for server to show the UI
ShowMachineUIEvent.OnClientEvent:Connect(function(machineType: string, machineID: string)
	if machineType == "MemoryMachine" then
		showGui(machineID)
	end
end)

-- Connect click handlers for each grid button
for _, tileButton in ipairs(gridContainer:GetChildren()) do
	if tileButton:IsA("TextButton") then
		tileButton.MouseButton1Click:Connect(function()
			if #playerSequence < 9 then -- Limit sequence length for now
				local gridX = tileButton:GetAttribute("GridX")
				local gridY = tileButton:GetAttribute("GridY")
				table.insert(playerSequence, {X = gridX, Y = gridY})
				statusLabel.Text = "Input recorded (" .. #playerSequence .. "/?)"

				-- Simple visual feedback
				local originalColor = tileButton.BackgroundColor3
				tileButton.BackgroundColor3 = Color3.new(1,1,1)
				task.wait(0.2)
				tileButton.BackgroundColor3 = originalColor
			end

			-- Placeholder submission logic
			if #playerSequence == 5 then
				print("Submitting placeholder sequence...")
				if activeMachineID then
					SubmitMemoryMachineSolution:FireServer(activeMachineID, playerSequence)
				end
				hideGui()
			end
		end)
	end
end

print("MemoryMachineController: Event listeners connected.")
