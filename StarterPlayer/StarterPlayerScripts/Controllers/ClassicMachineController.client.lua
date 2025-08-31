--!strict
--[=[
    @client
    This controller manages the UI and client-side logic for the Classic Machine minigame.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

print("ClassicMachineController.client.lua loaded.")

-- Get remote events folder
local EventsFolder = ReplicatedStorage:WaitForChild("GameEvents")
local ShowMachineUIEvent = EventsFolder:WaitForChild("ShowMachineUI")
local SubmitClassicMachineSolution = EventsFolder:WaitForChild("SubmitClassicMachineSolution")

-- Get UI module
local ClassicMachineGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("ClassicMachineGui"))

-- Create the GUI instance
local guiInstance = ClassicMachineGuiModule()
guiInstance.Parent = PlayerGui
print("ClassicMachineController: GUI instance created.")

local gridContainer = guiInstance.MainFrame.GridContainer
local submitButton = guiInstance.MainFrame.SubmitButton

-- FIX: Use a local variable to track the active machine's ID
local activeMachineID: string?

-- --- Functions to control the GUI ---

local function showGui(machineID: string)
    -- Randomize tile rotations when showing the GUI
    for _, tile in ipairs(gridContainer:GetChildren()) do
        if tile:IsA("TextButton") then -- Only rotate interactive tiles
            local randomRotations = {0, 90, 180, 270}
            tile.Rotation = randomRotations[math.random(1, #randomRotations)]
        end
    end
    guiInstance.Enabled = true
    -- Store the ID of the machine we are interacting with
    activeMachineID = machineID
    print("ClassicMachineController: GUI shown for machine: " .. machineID)
end

local function hideGui()
    guiInstance.Enabled = false
    -- Clear the active machine ID
    activeMachineID = nil
    print("ClassicMachineController: GUI hidden.")
end

-- --- Event Connections ---

-- Listen for server to show the UI
ShowMachineUIEvent.OnClientEvent:Connect(function(machineType: string, machineID: string)
    if machineType == "ClassicMachine" then
        showGui(machineID)
    end
end)

-- Connect click-to-rotate for each interactive tile
for _, tile in ipairs(gridContainer:GetChildren()) do
    if tile:IsA("TextButton") then
        tile.MouseButton1Click:Connect(function()
            -- Rotate the tile by 90 degrees
            tile.Rotation += 90
        end)
    end
end

-- Connect the submit button to send the solution to the server
submitButton.MouseButton1Click:Connect(function()
    print("Submit button clicked! Sending solution to server.")

    local solution = {}
    local children = gridContainer:GetChildren()

    -- Create a 5x5 table
    for y = 1, 5 do
        solution[y] = {}
    end

    -- Populate the table with the grid state
    for _, tile in ipairs(children) do
        local pipeType = tile:GetAttribute("PipeType")
        local gridX = tile:GetAttribute("GridX")
        local gridY = tile:GetAttribute("GridY")

        if pipeType and gridX and gridY then
            solution[gridY][gridX] = {
                Type = pipeType,
                Rotation = tile.Rotation,
            }
        end
    end

    -- Fire the remote event to the server
    if activeMachineID then
        SubmitClassicMachineSolution:FireServer(activeMachineID, solution)
    else
        warn("No active machine ID found when submitting solution!")
    end

    -- Hide the UI after submitting
    hideGui()
end)

print("ClassicMachineController: Event listeners connected.")
