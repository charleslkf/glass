--!strict
--[=[
	@client
	@class GameStatusUIController
	This client-side script creates and manages the UI that displays
	the current game status (e.g., timers, objectives).
]=]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local UpdateCountdownEvent = GameEvents:WaitForChild("UpdateCountdown")
local UpdateRoundTimerEvent = GameEvents:WaitForChild("UpdateRoundTimer")
local UpdateMachineProgressEvent = GameEvents:WaitForChild("UpdateMachineProgress")

-- Create the main ScreenGui
local statusScreenGui = Instance.new("ScreenGui")
statusScreenGui.Name = "GameStatusUI"
statusScreenGui.ResetOnSpawn = false

-- Create a main frame to hold the labels, centered to avoid default UI
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0.6, 0, 0.15, 0) -- 60% of screen width
mainFrame.AnchorPoint = Vector2.new(0.5, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0, 0) -- Centered at the top
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
timerLabel.Text = ""
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
progressLabel.Text = ""
progressLabel.BackgroundTransparency = 1
progressLabel.Parent = mainFrame

-- Function to format time from seconds to MM:SS
local function formatTime(seconds: number)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%d:%02d", minutes, remainingSeconds)
end

-- Listen for countdown updates
UpdateCountdownEvent.OnClientEvent:Connect(function(message: string, time: number)
	statusLabel.Text = message .. ": " .. time
	timerLabel.Text = ""
	progressLabel.Text = ""
end)

-- Listen for round timer updates
UpdateRoundTimerEvent.OnClientEvent:Connect(function(time: number)
	if statusLabel.Text ~= "Round Over" then
		statusLabel.Text = "" -- Clear the main status during the round
	end
	timerLabel.Text = formatTime(time)
end)

-- Listen for machine progress updates
UpdateMachineProgressEvent.OnClientEvent:Connect(function(completed: number, total: number)
	progressLabel.Text = "Generators: " .. completed .. "/" .. total
end)

-- Parent the ScreenGui to the PlayerGui
statusScreenGui.Parent = PlayerGui

print("GameStatusUIController.client.lua loaded and UI created.")
