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
	gridContainer.Position = UDim2.new(0.5, 0, 0.5, -25)
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
				tileInstance.AutoButtonColor = true -- Gives visual feedback
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
				tileInstance.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				tileInstance.BorderSizePixel = 1

				local pipeIndicator = Instance.new("Frame")
				pipeIndicator.Name = "PipeIndicator"
				pipeIndicator.BorderSizePixel = 0
				pipeIndicator.Position = UDim2.new(0.5, 0, 0.5, 0)
				pipeIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
				pipeIndicator.Parent = tileInstance

				if tileData == "I" then
					pipeIndicator.Size = UDim2.new(0.3, 0, 1, 0)
					pipeIndicator.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
				elseif tileData == "L" then
					pipeIndicator.Size = UDim2.new(0.8, 0, 0.8, 0)
					pipeIndicator.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
				elseif tileData == "S" then
					pipeIndicator.Size = UDim2.new(1, 0, 1, 0)
					pipeIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
				elseif tileData == "E" then
					pipeIndicator.Size = UDim2.new(1, 0, 1, 0)
					pipeIndicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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
