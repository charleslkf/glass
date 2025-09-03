--!strict
--[=[
	@client
	@class GameStatusUIController
	This client-side script creates and manages the UI that displays
	the current game status (e.g., timers, objectives).
]=]
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create the main ScreenGui
local statusScreenGui = Instance.new("ScreenGui")
statusScreenGui.Name = "GameStatusUI"
statusScreenGui.ResetOnSpawn = false

-- Create a main frame to hold the labels
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 0.15, 0) -- Full width, 15% of screen height
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = statusScreenGui

-- Create the main status label (for countdowns and messages)
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
statusLabel.AnchorPoint = Vector2.new(0.5, 0)
statusLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 28
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextStrokeTransparency = 0.5
statusLabel.Text = "Waiting for players..."
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = mainFrame

-- Create the round timer label
local timerLabel = Instance.new("TextLabel")
timerLabel.Name = "TimerLabel"
timerLabel.Size = UDim2.new(0.2, 0, 0.4, 0)
timerLabel.AnchorPoint = Vector2.new(1, 0)
timerLabel.Position = UDim2.new(0.98, 0, 0.1, 0)
timerLabel.Font = Enum.Font.SourceSansBold
timerLabel.TextSize = 24
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.TextStrokeTransparency = 0.5
timerLabel.Text = "5:00"
timerLabel.BackgroundTransparency = 1
timerLabel.Parent = mainFrame

-- Create the machine progress label
local progressLabel = Instance.new("TextLabel")
progressLabel.Name = "ProgressLabel"
progressLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
progressLabel.AnchorPoint = Vector2.new(0, 0)
progressLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
progressLabel.Font = Enum.Font.SourceSansBold
progressLabel.TextSize = 24
progressLabel.TextColor3 = Color3.new(1, 1, 1)
progressLabel.TextStrokeTransparency = 0.5
progressLabel.Text = "Generators: 0/5"
progressLabel.BackgroundTransparency = 1
progressLabel.Parent = mainFrame

-- Parent the ScreenGui to the PlayerGui to make it visible
statusScreenGui.Parent = PlayerGui

print("GameStatusUIController: UI elements created.")

-- Return an empty table for now. Event handling will be added in a future step.
return {}
