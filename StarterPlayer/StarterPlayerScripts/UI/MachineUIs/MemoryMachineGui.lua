--!strict
--[=[
	@module MemoryMachineGui
	This module creates the UI for the Memory Machine minigame.
	It returns a function that, when called, creates and returns a ScreenGui instance.
]=]

local function createMemoryMachineGui()
	-- Create the main ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.DisplayName = "MemoryMachineGui"
	screenGui.Enabled = false -- Initially disabled

	-- Create the main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 400, 0, 450)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.Parent = screenGui

	-- Create a title label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.Text = "Memory Machine"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextSize = 24
	titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	titleLabel.Parent = mainFrame

	-- Create the grid container
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(0, 300, 0, 300)
	gridContainer.Position = UDim2.new(0.5, 0, 0.5, -20)
	gridContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	gridContainer.BackgroundTransparency = 1
	gridContainer.Parent = mainFrame

	-- Create the grid buttons (3x3 grid)
	local GRID_SIZE = 3
	for y = 1, GRID_SIZE do
		for x = 1, GRID_SIZE do
			local button = Instance.new("TextButton")
			button.Name = "Button_" .. x .. "_" .. y
			button.Text = ""
			button.Size = UDim2.new(0, 90, 0, 90)
			local posX = (x - 1) * 0.333 + 0.1665
			local posY = (y - 1) * 0.333 + 0.1665
			button.Position = UDim2.new(posX, 0, posY, 0)
			button.AnchorPoint = Vector2.new(0.5, 0.5)
			button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			button.Parent = gridContainer

			-- Set attributes for the controller to use
			button:SetAttribute("GridX", x)
			button:SetAttribute("GridY", y)
		end
	end

	-- Create the status label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -20, 0, 30)
	statusLabel.Position = UDim2.new(0.5, 0, 1, -80)
	statusLabel.AnchorPoint = Vector2.new(0.5, 0)
	statusLabel.Text = "Watch the pattern carefully..."
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextColor3 = Color3.new(1, 1, 1)
	statusLabel.TextSize = 18
	statusLabel.BackgroundTransparency = 1
	statusLabel.Parent = mainFrame

	-- Create the submit button
	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.Size = UDim2.new(0, 150, 0, 40)
	submitButton.Position = UDim2.new(0.5, 0, 1, -30)
	submitButton.AnchorPoint = Vector2.new(0.5, 1)
	submitButton.Text = "Submit"
	submitButton.Font = Enum.Font.SourceSansBold
	submitButton.TextSize = 20
	submitButton.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
	submitButton.TextColor3 = Color3.new(1, 1, 1)
	submitButton.Parent = mainFrame

	return screenGui
end

return createMemoryMachineGui
