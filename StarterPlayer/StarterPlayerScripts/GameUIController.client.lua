-- StarterPlayer/StarterPlayerScripts/GameUIController.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Get or create the ScreenGui
local screenGui = playerGui:FindFirstChild("GameStatusGui")
if not screenGui then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GameStatusGui"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 10 -- Set high to render on top of other UI
    screenGui.Parent = playerGui
end

-- Create the status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.8, 0, 0.1, 0) -- 80% of screen width, 10% of screen height
statusLabel.Position = UDim2.new(0.1, 0, 0.02, 0) -- Centered at the top
statusLabel.ZIndex = 2
statusLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statusLabel.BackgroundTransparency = 0.5 -- Semi-transparent black background
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextColor3 = Color3.new(1, 1, 1) -- White text
statusLabel.TextScaled = true -- Scale text to fit label
statusLabel.TextStrokeTransparency = 0 -- Black outline
statusLabel.TextTransparency = 0 -- Ensure text is not transparent
statusLabel.Text = "Loading..."
statusLabel.Parent = screenGui

print("DEBUG (UI): statusLabel created. Visible: " .. tostring(statusLabel.Visible) .. ", Parent: " .. tostring(statusLabel.Parent))

-- Get the status value from ReplicatedStorage
local statusValue = ReplicatedStorage:WaitForChild("Status")
print("DEBUG (UI): Found Status object in ReplicatedStorage: " .. tostring(statusValue))


-- Function to update the label
local function updateStatus()
    local newText = statusValue.Value
    statusLabel.Text = newText
    print("DEBUG (UI): statusValue.Changed fired. Set StatusLabel.Text to: '" .. tostring(newText) .. "'")
end

-- Listen for changes and set initial value
print("DEBUG (UI): Connecting to .Changed event.")
statusValue.Changed:Connect(updateStatus)
print("DEBUG (UI): Setting initial text.")
updateStatus() -- Set the initial text

print("GameUIController initialized.")
