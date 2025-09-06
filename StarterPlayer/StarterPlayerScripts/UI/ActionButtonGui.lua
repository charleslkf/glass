--!strict
--[=[
	@client
	@module ActionButtonGui
	This module creates and returns the on-screen action button GUI for mobile players.
]=]

--[=[
	Creates the GUI elements.
	@return ScreenGui The top-level GUI object.
	@return TextButton The button the player will tap.
]=]
local function createActionButton()
	-- Create the main GUI container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ActionButtonGui"
	screenGui.ResetOnSpawn = false

	-- Create the action button
	local actionButton = Instance.new("TextButton")
	actionButton.Name = "ActionButton"
	actionButton.Parent = screenGui
	actionButton.Text = "" -- No text needed

	-- Style the button
	actionButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	actionButton.BackgroundTransparency = 0.4
	actionButton.BorderSizePixel = 0

	actionButton.Size = UDim2.new(0, 120, 0, 120) -- 120x120 pixels
	actionButton.Position = UDim2.new(1, -150, 1, -150) -- Positioned at the bottom right
	actionButton.AnchorPoint = Vector2.new(1, 1) -- Anchor to the bottom right corner

	-- Create the UICorner to make the button circular
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0.5, 0) -- 0.5 scale makes it a perfect circle
	uiCorner.Parent = actionButton

	return screenGui, actionButton
end

return createActionButton
