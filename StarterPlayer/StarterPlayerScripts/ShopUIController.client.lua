--!strict
--[=[
	@client
	@class ShopUIController
	This client-side script creates and manages the Shop UI.
]=]

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Create the main ScreenGui
local shopScreenGui = Instance.new("ScreenGui")
shopScreenGui.Name = "ShopScreenGui"
shopScreenGui.ResetOnSpawn = false

-- Create the main shop frame
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0.5, 0, 0.6, 0) -- 50% of screen width, 60% of height
shopFrame.AnchorPoint = Vector2.new(0.5, 0.5)
shopFrame.Position = UDim2.new(0.5, 0, 0.5, 0) -- Center of the screen
shopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
shopFrame.BorderSizePixel = 2
shopFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
shopFrame.Visible = false -- Start hidden
shopFrame.Parent = shopScreenGui

-- Create a title label for the shop
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
titleLabel.Text = "Shop"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.Parent = shopFrame

-- Create a button to toggle the shop's visibility
local openShopButton = Instance.new("TextButton")
openShopButton.Name = "OpenShopButton"
openShopButton.Size = UDim2.new(0, 150, 0, 50)
openShopButton.AnchorPoint = Vector2.new(1, 0)
openShopButton.Position = UDim2.new(0.98, 0, 0.05, 0) -- Top-right corner
openShopButton.Text = "Shop"
openShopButton.Font = Enum.Font.SourceSansBold
openShopButton.TextSize = 20
openShopButton.Parent = shopScreenGui

-- Function to toggle the shop's visibility
local function toggleShop()
	shopFrame.Visible = not shopFrame.Visible
end

-- Connect the button click to the toggle function
openShopButton.MouseButton1Click:Connect(toggleShop)

-- Parent the ScreenGui to the PlayerGui to make it visible
shopScreenGui.Parent = playerGui

print("ShopUIController: Created and initialized shop UI for player.")
