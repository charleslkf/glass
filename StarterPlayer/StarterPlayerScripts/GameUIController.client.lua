-- StarterPlayer/StarterPlayerScripts/GameUIController.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local ThemeManager = require(script.Parent:WaitForChild("ThemeManager"))

-- Find the existing ScreenGui and mainFrame created by MachineUIController
local screenGui = playerGui:WaitForChild("MachineGUIs")
local mainFrame = screenGui:WaitForChild("MainFrame")

-- Create the status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0.1, 0) -- Use full width of the mainFrame
statusLabel.Position = UDim2.new(0, 0, 0, 0) -- Position at the top
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextColor3 = ThemeManager.get("Text") -- White text
statusLabel.TextScaled = true
statusLabel.TextStrokeTransparency = 0 -- Black outline
statusLabel.ZIndex = 10 -- Ensure it's on top of other elements in the same frame
statusLabel.Text = "Loading..."
statusLabel.Parent = mainFrame -- Parent to the existing mainFrame

-- Get the status value from ReplicatedStorage
local statusValue = ReplicatedStorage:WaitForChild("Status")

-- Function to update the label
local function updateStatus()
    statusLabel.Text = statusValue.Value
end

-- Listen for changes and set initial value
statusValue.Changed:Connect(updateStatus)
updateStatus() -- Set the initial text

print("GameUIController initialized and attached to existing MachineGUIs frame.")
