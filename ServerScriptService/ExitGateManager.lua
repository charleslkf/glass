--!strict
--[=[
	@class ExitGateManager
	Manages the state and interactions for the two exit gates on the map.
]=]
local ExitGateManager = {}
ExitGateManager.__index = ExitGateManager

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local EventManager = require(ServerScriptService.EventManager)

local GATE_OPEN_TIME = 10 -- seconds

--[=[
	This table will hold the state of the exit gates.
	In a real game, these would be associated with actual parts in the workspace.
]=]
local gates = {
	GateA = { Name = "GateA", isPowered = false, isOpen = false, isOpening = false },
	GateB = { Name = "GateB", isPowered = false, isOpen = false, isOpening = false },
}

--[=[
	Handles a player's escape.
]=]
function ExitGateManager:Escape(player: Player)
	if not player then return end

	print("Survivor " .. player.Name .. " has escaped!")
	-- A real implementation would award points and handle removing the player gracefully.
	-- For now, we will just kick them to simulate leaving the match.
	player:Kick("You have escaped!")
end


--[=[
	Handles a player's request to open a gate.
]=]
function ExitGateManager:RequestOpenGate(player: Player, gateName: string)
	local gateData = gates[gateName]

	if not gateData then
		warn("Player " .. player.Name .. " requested to open an invalid gate: " .. gateName)
		return
	end

	if not gateData.isPowered then
		print("Player " .. player.Name .. " tried to open gate " .. gateName .. ", but it is not powered.")
		return
	end

	if gateData.isOpen or gateData.isOpening then
		print("Gate " .. gateName .. " is already open or being opened.")
		return
	end

	print("Player " .. player.Name .. " is opening gate " .. gateName .. ". It will take " .. GATE_OPEN_TIME .. " seconds.")
	gateData.isOpening = true

	-- For now, a simple wait. This could be a loop with skill checks in the future.
	wait(GATE_OPEN_TIME)

	gateData.isOpen = true
	gateData.isOpening = false
	print("Gate " .. gateName .. " has been opened!")
	-- In the future, fire an event to update the UI and play a sound.
end

--[=[
	Powers up the exit gates, making them interactable.
]=]
function ExitGateManager:PowerGates()
	print("All generators repaired! Powering the exit gates.")
	for _, gateData in pairs(gates) do
		gateData.isPowered = true
	end
	-- In the future, we would also fire an event here to play a loud sound
	-- and update the UI to show "Find the exit!".
end

--[=[
	Sets up the .Touched event for a given gate part.
]=]
local function setupGateTouch(gatePart: BasePart, gateName: string, self)
	gatePart.Touched:Connect(function(otherPart)
		local character = otherPart.Parent
		if not character then return end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then return end

		local gateData = gates[gateName]
		if gateData and gateData.isOpen then
			self:Escape(player)
		end
	end)
end

--[=[
	Initializes the manager and connects to game events.
]=]
function ExitGateManager:Init()
	EventManager.AllGeneratorsRepaired.Event:Connect(function()
		self:PowerGates()
	end)

	EventManager.RequestOpenGate.OnServerEvent:Connect(function(player, gateName)
		self:RequestOpenGate(player, gateName)
	end)

	-- Find the physical gate parts in the workspace and connect touch events
	-- This assumes parts named "GateA" and "GateB" exist in workspace.
	local gateA = workspace:FindFirstChild("GateA")
	if gateA then
		setupGateTouch(gateA, "GateA", self)
	else
		warn("ExitGateManager: Could not find a part named 'GateA' in the workspace.")
	end

	local gateB = workspace:FindFirstChild("GateB")
	if gateB then
		setupGateTouch(gateB, "GateB", self)
	else
		warn("ExitGateManager: Could not find a part named 'GateB' in the workspace.")
	end

	print("ExitGateManager Initialized and listening for events.")
end

return ExitGateManager
