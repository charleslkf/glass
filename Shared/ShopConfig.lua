--[=[
	@module ShopConfig
	This module contains the configuration for all items available in the shop.
	This allows us to easily add, remove, or edit items without changing the UI code.
]=]
local ShopConfig = {}

ShopConfig.Items = {
	{
		Name = "Cool Killer Skin",
		Type = "Skin",
		Price = 500,
		AssetId = "rbxassetid://1234567890", -- Placeholder
		ForRole = "Killer",
	},
	{
		Name = "Epic Stunner Skin",
		Type = "Skin",
		Price = 500,
		AssetId = "rbxassetid://0987654321", -- Placeholder
		ForRole = "Stunner",
	},
	{
		Name = "Advanced Heal",
		Type = "Ability",
		Price = 1000,
		AssetId = "rbxassetid://1122334455", -- Placeholder
		ForRole = "Helper",
		Description = "A more powerful healing ability.",
	},
}

return ShopConfig
