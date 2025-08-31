--!strict
--[=[
	This module script programmatically creates and returns the ScreenGui
	for the Classic Machine minigame.
]=]

local function createGui(): ScreenGui
	-- Main ScreenGui container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ClassicMachineGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Main Frame for the puzzle window
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	mainFrame.Parent = screenGui

	-- Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Text = "Connect the Pipes"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 24
	titleLabel.Parent = mainFrame

	-- Frame to hold the puzzle grid
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(0.9, 0, 1, -110)
	gridContainer.Position = UDim2.new(0.5, 0, 0.5, 10)
	gridContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	gridContainer.BackgroundTransparency = 1
	gridContainer.Parent = mainFrame

	-- AspectRatioConstraint to keep the grid square
	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.AspectRatio = 1
	aspectRatio.DominantAxis = Enum.DominantAxis.Width
	aspectRatio.Parent = gridContainer

	-- GridLayout
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.2, -5, 0.2, -5)
	gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = gridContainer

	-- Define the puzzle layout
	local puzzleLayout = {
		{"S", "I", "_", "_", "_"},
		{"L", "I", "L", "_", "_"},
		{"_", "I", "I", "L", "_"},
		{"_", "L", "I", "E", "_"},
		{"_", "_", "_", "_", "_"},
	}

	-- Create the grid tiles
	for y = 1, 5 do
		for x = 1, 5 do
			local tileData = puzzleLayout[y][x]
			local isInteractive = (tileData == "I" or tileData == "L")

			local tileInstance
			if isInteractive then
				tileInstance = Instance.new("TextButton")
				tileInstance.Text = ""
				tileInstance.AutoButtonColor = false
				tileInstance.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				tileInstance.BorderSizePixel = 1
			else
				tileInstance = Instance.new("Frame")
			end

			tileInstance.Name = `Tile_{y}_{x}`
			tileInstance.LayoutOrder = (y - 1) * 5 + x
			tileInstance.Parent = gridContainer
			tileInstance:SetAttribute("GridX", x)
			tileInstance:SetAttribute("GridY", y)
			tileInstance:SetAttribute("PipeType", tileData)

			if tileData ~= "_" then
				if not isInteractive then
					tileInstance.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
					tileInstance.BorderSizePixel = 1
				end

				-- FIX: Using TextLabels which support InputTransparent
				if tileData == "I" then
					local bar = Instance.new("TextLabel")
					bar.Text = ""
					bar.Name = "Bar"
					bar.Size = UDim2.new(0.3, 0, 1, 0)
					bar.Position = UDim2.new(0.5, 0, 0.5, 0)
					bar.AnchorPoint = Vector2.new(0.5, 0.5)
					bar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
					bar.BorderSizePixel = 0
					bar.Interactable = false
					bar.Parent = tileInstance
				elseif tileData == "L" then
					local vertBar = Instance.new("TextLabel")
					vertBar.Text = ""
					vertBar.Name = "VertBar"
					vertBar.Size = UDim2.new(0.3, 0, 0.65, 0)
					vertBar.Position = UDim2.new(0.5, 0, 0.325, 0)
					vertBar.AnchorPoint = Vector2.new(0.5, 0.5)
					vertBar.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
					vertBar.BorderSizePixel = 0
					vertBar.Interactable = false
					vertBar.Parent = tileInstance

					local horizBar = Instance.new("TextLabel")
					horizBar.Text = ""
					horizBar.Name = "HorizBar"
					horizBar.Size = UDim2.new(0.65, 0, 0.3, 0)
					horizBar.Position = UDim2.new(0.675, 0, 0.5, 0)
					horizBar.AnchorPoint = Vector2.new(0.5, 0.5)
					horizBar.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
					horizBar.BorderSizePixel = 0
					horizBar.Interactable = false
					horizBar.Parent = tileInstance
				elseif tileData == "S" or tileData == "E" then
					local indicator = Instance.new("TextLabel")
					indicator.Text = ""
					indicator.Size = UDim2.new(1, 0, 1, 0)
					indicator.BackgroundColor3 = if tileData == "S" then Color3.fromRGB(0, 255, 0) else Color3.fromRGB(255, 0, 0)
					indicator.Interactable = false
					indicator.Parent = tileInstance
				end
			else
				tileInstance.BackgroundTransparency = 1
			end
		end
	end

	-- Submit Button
	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.Size = UDim2.new(0.4, 0, 0, 40)
	submitButton.Position = UDim2.new(0.5, 0, 1, -10)
	submitButton.AnchorPoint = Vector2.new(0.5, 1)
	submitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitButton.Text = "Submit"
	submitButton.Font = Enum.Font.SourceSansBold
	submitButton.TextSize = 20
	submitButton.Parent = mainFrame

	return screenGui
end

return createGui
