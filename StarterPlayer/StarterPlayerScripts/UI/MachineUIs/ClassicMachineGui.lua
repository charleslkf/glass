--!strict
--[=[
	This module script programmatically creates and returns the ScreenGui
	for the Classic Machine minigame.
]=]

local function createGui(): ScreenGui
	-- Main ScreenGui container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ClassicMachineGui"
	-- Set ResetOnSpawn to false so the UI doesn't close if the player dies.
	screenGui.ResetOnSpawn = false
	-- Start with the UI disabled. The controller will enable it.
	screenGui.Enabled = false

	-- Main Frame for the puzzle window
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.5, 0, 0.6, 0) -- 50% of screen width, 60% of screen height
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center of the screen
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5) -- Anchor from its center
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	mainFrame.Parent = screenGui

	-- Title Label at the top of the frame
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50) -- Full width, 50 pixels high
	titleLabel.Position = UDim2.new(0, 0, 0, 0)
	titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Text = "Connect the Pipes"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 24
	titleLabel.Parent = mainFrame

	-- Submit Button at the bottom of the frame
	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.Size = UDim2.new(0.4, 0, 0, 40) -- 40% of frame width, 40 pixels high
	submitButton.Position = UDim2.new(0.5, 0, 1, -50) -- Positioned at the bottom, with some padding
	submitButton.AnchorPoint = Vector2.new(0.5, 1) -- Anchor from its bottom-center
	submitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitButton.Text = "Submit"
	submitButton.Font = Enum.Font.SourceSansBold
	submitButton.TextSize = 20
	submitButton.Parent = mainFrame

	return screenGui
end

return createGui
