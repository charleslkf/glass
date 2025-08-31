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

-- Get remote events folder
local EventsFolder = ReplicatedStorage:WaitForChild("GameEvents")
local ShowMachineUIEvent = EventsFolder:WaitForChild("ShowMachineUI")
local SubmitMemoryMachineSolution = EventsFolder:WaitForChild("SubmitMemoryMachineSolution") -- Assumes this event exists

-- Get UI module (assumes a similar structure to ClassicMachine)
-- IMPORTANT: This script assumes a MemoryMachineGui module exists and creates a UI
-- with a 'GridContainer' frame and a 'SubmitButton'. The grid buttons should
-- have 'GridX' and 'GridY' attributes.
local MemoryMachineGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("MemoryMachineGui"))

-- Create the GUI instance
local guiInstance = MemoryMachineGuiModule()
guiInstance.Parent = PlayerGui
print("MemoryMachineController: GUI instance created.")

local gridContainer = guiInstance.MainFrame.GridContainer
local submitButton = guiInstance.MainFrame.SubmitButton
local statusLabel = guiInstance.MainFrame.StatusLabel -- Assume a label for status updates

local activeMachineID: string?
local playerSolution: {{X: number, Y: number}} = {}
local isPlayerTurn = false -- To prevent clicking during pattern display

-- --- Functions ---

local function showGui(machineID: string, pattern: {{X: number, Y: number}})
    activeMachineID = machineID
    playerSolution = {}
    isPlayerTurn = false
    guiInstance.Enabled = true
    statusLabel.Text = "Watch the pattern carefully..."
    print("MemoryMachineController: GUI shown for machine: " .. machineID)

    -- Animate the pattern
    task.spawn(function()
        task.wait(1) -- Wait a moment before starting
        for _, pos in ipairs(pattern) do
            local tile = gridContainer:FindFirstChild("Button_" .. pos.X .. "_" .. pos.Y)
            if tile and tile:IsA("TextButton") then
                local originalColor = tile.BackgroundColor3
                tile.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8) -- Highlight color
                task.wait(0.6)
                tile.BackgroundColor3 = originalColor
                task.wait(0.2)
            end
        end
        statusLabel.Text = "Your turn! Replicate the pattern."
        isPlayerTurn = true -- Allow player input
    end)
end

local function hideGui()
    guiInstance.Enabled = false
    activeMachineID = nil
    print("MemoryMachineController: GUI hidden.")
end

-- --- Event Connections ---

-- Listen for server to show the UI
ShowMachineUIEvent.OnClientEvent:Connect(function(machineType: string, machineID: string, pattern: {{X: number, Y: number}}?)
    if machineType == "MemoryMachine" and pattern then
        showGui(machineID, pattern)
    end
end)

-- Connect click handlers for each grid button
for _, tile in ipairs(gridContainer:GetChildren()) do
    if tile:IsA("TextButton") then
        tile.MouseButton1Click:Connect(function()
            if not isPlayerTurn then return end

            local gridX = tile:GetAttribute("GridX")
            local gridY = tile:GetAttribute("GridY")

            if gridX and gridY then
                -- Briefly flash the button to give feedback
                local originalColor = tile.BackgroundColor3
                tile.BackgroundColor3 = Color3.new(0.5, 0.8, 0.5) -- Click feedback color
                task.wait(0.1)
                tile.BackgroundColor3 = originalColor

                -- Add to player's solution
                table.insert(playerSolution, {X = gridX, Y = gridY})
                print("Player clicked:", gridX, gridY)
            end
        end)
    end
end

-- Connect the submit button
submitButton.MouseButton1Click:Connect(function()
    if not isPlayerTurn or not activeMachineID then return end

    print("Submit button clicked! Sending solution to server.")
    statusLabel.Text = "Submitting..."
    isPlayerTurn = false

    SubmitMemoryMachineSolution:FireServer(activeMachineID, playerSolution)

    -- Hide the UI after a short delay
    task.wait(1)
    hideGui()
end)

print("MemoryMachineController: Event listeners connected.")
