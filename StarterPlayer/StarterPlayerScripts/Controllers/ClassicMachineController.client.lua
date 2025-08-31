--!strict
--[=[
    @client
    This controller manages the UI and client-side logic for the Classic Machine minigame.
    It creates the UI, listens for server events to show it, and handles user input.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

print("ClassicMachineController.client.lua loaded.")

-- Get the folder for remote events, created by the server's EventManager
local EventsFolder = ReplicatedStorage:WaitForChild("GameEvents")
-- Get the specific event for showing the machine UI. The script will yield until it exists.
local ShowMachineUIEvent = EventsFolder:WaitForChild("ShowMachineUI")

-- The UI module we created in the previous step
local ClassicMachineGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("ClassicMachineGui"))

-- Create the GUI instance and parent it to the PlayerGui
local guiInstance = ClassicMachineGuiModule()
guiInstance.Parent = PlayerGui
print("ClassicMachineController: GUI instance created and parented.")

-- --- Functions to control the GUI ---

local function showGui()
    guiInstance.Enabled = true
    print("ClassicMachineController: GUI shown.")
end

local function hideGui()
    guiInstance.Enabled = false
    print("ClassicMachineController: GUI hidden.")
end

-- --- Event Connections ---

-- Listen for the server event to show the UI for our specific machine type
ShowMachineUIEvent.OnClientEvent:Connect(function(machineType: string)
    if machineType == "ClassicMachine" then
        showGui()
    end
end)

-- Connect the submit button to the hide function
local submitButton = guiInstance:FindFirstChild("MainFrame", true):FindFirstChild("SubmitButton")
if submitButton and submitButton:IsA("TextButton") then
    submitButton.MouseButton1Click:Connect(function()
        print("Submit button clicked! Hiding UI.")
        -- In the future, this will send the solution to the server before hiding.
        hideGui()
    end)
end

print("ClassicMachineController: Event listeners connected.")
