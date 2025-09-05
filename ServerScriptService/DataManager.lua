--!strict
--[=[
	@class DataManager
	Handles all player data saving and loading using DataStoreService.
]=]
local DataManager = {}
DataManager.__index = DataManager

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local EventManager = require(game:GetService("ServerScriptService").EventManager)

-- Define the DataStore for player data
local playerDataStore = DataStoreService:GetDataStore("PlayerData_v1")

-- A table to hold the loaded data for active players
local sessionData = {}

--[=[
	Loads a player's data when they join the game.
	@param player Player The player whose data should be loaded.
]=]
function DataManager:LoadData(player: Player)
	local playerKey = "Player_" .. player.UserId

	local success, data = pcall(function()
		return playerDataStore:GetAsync(playerKey)
	end)

	if success then
		if data then
			-- Player has existing data, load it
			sessionData[player] = data
			print("Loaded data for " .. player.Name, data)
		else
			-- New player, create default data
			sessionData[player] = {
				Currency = 0,
				Unlocks = {}
			}
			print("No data found for " .. player.Name .. ". Creating default data.")
		end
	else
		-- This is not a critical error in Studio, where datastores are often disabled.
		-- Instead of kicking, we'll create default data and proceed.
		warn("Failed to load data for " .. player.Name .. "! Reason: " .. tostring(data) .. ". Creating default data instead.")
		sessionData[player] = {
			Currency = 0,
			Unlocks = {}
		}
	end
end

--[=[
	Saves a player's data when they leave the game.
	@param player Player The player whose data should be saved.
]=]
function DataManager:SaveData(player: Player)
	local playerKey = "Player_" .. player.UserId

	if sessionData[player] then
		local success, err = pcall(function()
			playerDataStore:SetAsync(playerKey, sessionData[player])
		end)

		if success then
			print("Successfully saved data for " .. player.Name)
		else
			warn("Failed to save data for " .. player.Name .. "! Reason: " .. tostring(err))
		end
	else
		warn("No session data to save for " .. player.Name)
	end
end

--[=[
	Initializes the DataManager, connecting to player events.
]=]
function DataManager:Init()
	Players.PlayerAdded:Connect(function(player)
		self:LoadData(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:SaveData(player)
	end)

	-- Note: DataStore requests can only be made from a live server,
	-- not during Studio's "Play Solo" mode unless API access is enabled.

	EventManager.RequestCurrency.OnServerEvent:Connect(function(player)
		local currency = self:GetCurrency(player)
		EventManager.UpdateCurrencyDisplay:FireClient(player, currency)
	end)
end

--[=[
	Returns the current currency for a given player.
	@param player Player
	@return number The player's currency amount.
]=]
function DataManager:GetCurrency(player: Player)
	if sessionData[player] then
		return sessionData[player].Currency
	end
	return 0
end


-- Example of how to modify data during gameplay
-- function DataManager:AddCurrency(player: Player, amount: number)
-- 	if sessionData[player] then
-- 		sessionData[player].Currency += amount
-- 	end
-- end

return DataManager
