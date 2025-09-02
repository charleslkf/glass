--!strict
--[=[
	@client
	@class ShopUIController
	This client-side script creates and manages the Shop UI.
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local ShopConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ShopConfig"))
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local RequestCurrencyEvent = GameEvents:WaitForChild("RequestCurrency")
local UpdateCurrencyDisplayEvent = GameEvents:WaitForChild("UpdateCurrencyDisplay")

-- Create the main ScreenGui
local shopScreenGui = Instance.new("ScreenGui")
shopScreenGui.Name = "ShopScreenGui"
shopScreenGui.ResetOnSpawn = false

-- Create the main shop frame
local shopFrame = Instance.new("Frame")
shopFrame.Name = "ShopFrame"
shopFrame.Size = UDim2.new(0.6, 0, 0.7, 0) -- 60% of screen width, 70% of height
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
titleLabel.Text = "Item Shop"
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 24
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
titleLabel.Parent = shopFrame

-- Create a currency display label
local currencyLabel = Instance.new("TextLabel")
currencyLabel.Name = "CurrencyLabel"
currencyLabel.Size = UDim2.new(0.3, 0, 0.08, 0)
currencyLabel.AnchorPoint = Vector2.new(1, 0)
currencyLabel.Position = UDim2.new(0.98, 0, 0.01, 0)
currencyLabel.Text = "Coins: ..."
currencyLabel.Font = Enum.Font.SourceSansBold
currencyLabel.TextSize = 18
currencyLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
currencyLabel.TextXAlignment = Enum.TextXAlignment.Right
currencyLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
currencyLabel.Parent = titleLabel

-- Create a scrolling frame to hold the items
local itemScrollFrame = Instance.new("ScrollingFrame")
itemScrollFrame.Name = "ItemScrollFrame"
itemScrollFrame.Size = UDim2.new(1, 0, 0.9, 0)
itemScrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
itemScrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
itemScrollFrame.BorderSizePixel = 0
itemScrollFrame.Parent = shopFrame

-- Add a grid layout to the scrolling frame
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellPadding = UDim2.new(0.02, 0, 0.02, 0)
gridLayout.CellSize = UDim2.new(0.2, 0, 0.3, 0)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = itemScrollFrame

-- Function to populate the shop with items from the config
local function populateShop()
	for _, itemData in ipairs(ShopConfig.Items) do
		-- Create a container frame for the item
		local itemFrame = Instance.new("Frame")
		itemFrame.Name = itemData.Name
		itemFrame.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		itemFrame.BorderSizePixel = 1
		itemFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
		itemFrame.Parent = itemScrollFrame

		-- Create an image button for the item's icon
		local itemIcon = Instance.new("ImageButton")
		itemIcon.Name = "Icon"
		itemIcon.Size = UDim2.new(1, 0, 0.7, 0)
		itemIcon.Image = itemData.AssetId
		itemIcon.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		itemIcon.Parent = itemFrame

		-- Create a text label for the item's name
		local itemName = Instance.new("TextLabel")
		itemName.Name = "NameLabel"
		itemName.Size = UDim2.new(1, 0, 0.15, 0)
		itemName.Position = UDim2.new(0, 0, 0.7, 0)
		itemName.Text = itemData.Name
		itemName.Font = Enum.Font.SourceSans
		itemName.TextSize = 16
		itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemName.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		itemName.Parent = itemFrame

		-- Create a text label for the item's price
		local itemPrice = Instance.new("TextLabel")
		itemPrice.Name = "PriceLabel"
		itemPrice.Size = UDim2.new(1, 0, 0.15, 0)
		itemPrice.Position = UDim2.new(0, 0, 0.85, 0)
		itemPrice.Text = "Price: " .. tostring(itemData.Price)
		itemPrice.Font = Enum.Font.SourceSansBold
		itemPrice.TextSize = 14
		itemPrice.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow for price
		itemPrice.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
		itemPrice.Parent = itemFrame
	end
end

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

-- Listen for the server to send the currency update
UpdateCurrencyDisplayEvent.OnClientEvent:Connect(function(currencyAmount: number)
	currencyLabel.Text = "Coins: " .. tostring(currencyAmount)
end)

-- Connect the button click to the toggle function
openShopButton.MouseButton1Click:Connect(toggleShop)

-- Parent the ScreenGui to the PlayerGui to make it visible
shopScreenGui.Parent = playerGui

-- Populate the shop and request initial currency when the script runs
populateShop()
RequestCurrencyEvent:FireServer()

print("ShopUIController: Created and initialized shop UI for player.")
