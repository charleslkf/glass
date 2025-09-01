--!strict
--[=[
	This module script programmatically creates and returns the ScreenGui
	for the Skill Check minigame.
]=]

local function createSkillCheckGui(): ScreenGui
	-- Main ScreenGui container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SkillCheckMachineGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Background bar for the skill check
	local backgroundBar = Instance.new("Frame")
	backgroundBar.Name = "BackgroundBar"
	backgroundBar.Size = UDim2.new(0.3, 0, 0, 20) -- 30% of screen width, 20 pixels high
	backgroundBar.Position = UDim2.new(0.5, 0, 0.8, 0) -- Positioned towards the bottom of the screen
	backgroundBar.AnchorPoint = Vector2.new(0.5, 0.5)
	backgroundBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	backgroundBar.BorderSizePixel = 2
	backgroundBar.BorderColor3 = Color3.new(0, 0, 0)
	backgroundBar.Parent = screenGui

	-- Success Zone frame inside the background bar
	local successZone = Instance.new("Frame")
	successZone.Name = "SuccessZone"
	successZone.Size = UDim2.new(0.2, 0, 1, 0) -- 20% of the background bar's width
	successZone.Position = UDim2.fromScale(0.7, 0.5) -- Positioned somewhere on the bar (example: 70% mark)
	successZone.AnchorPoint = Vector2.new(0.5, 0.5)
	successZone.BackgroundColor3 = Color3.fromRGB(100, 200, 100) -- A light green color
	successZone.BorderSizePixel = 0
	successZone.Parent = backgroundBar

	-- Moving cursor that travels across the bar
	local cursor = Instance.new("Frame")
	cursor.Name = "Cursor"
	cursor.Size = UDim2.new(0, 4, 1.2, 0) -- A thin vertical line, slightly taller than the bar
	cursor.Position = UDim2.fromScale(0, 0.5) -- Starts at the beginning
	cursor.AnchorPoint = Vector2.new(0.5, 0.5)
	cursor.BackgroundColor3 = Color3.new(1, 1, 1) -- White
	cursor.BorderSizePixel = 0
	cursor.Parent = backgroundBar

	return screenGui
end

return createSkillCheckGui
