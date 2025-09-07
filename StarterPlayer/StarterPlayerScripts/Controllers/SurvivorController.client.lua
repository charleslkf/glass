--[=[
	@client
	@class SurvivorController
	Handles client-side input and logic for Survivor roles.
]=]
local SurvivorController = {}
SurvivorController.__index = SurvivorController

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local EventManager = ReplicatedStorage:WaitForChild("GameEvents")

local playerRoles = ReplicatedStorage:WaitForChild("PlayerRoles")
local playerStates = ReplicatedStorage:WaitForChild("PlayerStates")

local INTERACTION_KEY = Enum.KeyCode.E
local INTERACTION_DISTANCE = 8

function SurvivorController.new()
	local self = setmetatable({}, SurvivorController)
	self.isSurvivor = false
	self.currentTarget = nil
	self.poweredGates = {}
	return self
end

function SurvivorController:Init()
	local self = self -- Capture self for closures
	print("SurvivorController Initialized")

	EventManager.GatePoweredEvent.OnClientEvent:Connect(function(gates)
		print("Client received GatePoweredEvent with " .. #gates .. " gates.")
		self.poweredGates = gates
	end)

	local function onRoleChanged(role)
		if role ~= "Killer" then
			if not self.isSurvivor then
				self.isSurvivor = true
				print("You are a Survivor.")
				RunService.Heartbeat:Connect(function() self:Update() end)
				UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed then
						self:OnInputBegan(input)
					end
				end)
			end
		else
			self.isSurvivor = false
		end
	end

	-- Listen for role changes
	playerRoles.AttributeChanged:Connect(function(attribute)
		if attribute == tostring(localPlayer.UserId) then
			onRoleChanged(playerRoles:GetAttribute(attribute))
		end
	end)

	-- Check initial role
	local initialRole = playerRoles:GetAttribute(tostring(localPlayer.UserId))
	if initialRole then
		onRoleChanged(initialRole)
	end
end

function SurvivorController:Update()
	if not self.isSurvivor or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		self.currentTarget = nil
		return
	end

	local myRoot = localPlayer.Character.HumanoidRootPart
	local myState = playerStates:GetAttribute(tostring(localPlayer.UserId))

	-- Can't interact while in these states
	if myState == "Hooked" or myState == "Carried" or myState == "Downed" then
		self.currentTarget = nil
		return
	end

	self.currentTarget = nil
	local closestDist = INTERACTION_DISTANCE

	-- Look for the closest interactable object (can be a hooked player or a gate)
	local bestTarget = nil

	-- Look for hooked survivors
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			local targetState = playerStates:GetAttribute(tostring(player.UserId))
			if targetState == "Hooked" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local targetRoot = player.Character.HumanoidRootPart
				local dist = (myRoot.Position - targetRoot.Position).Magnitude
				if dist < closestDist then
					closestDist = dist
					bestTarget = { Type = "Unhook", Player = player }
				end
			end
		end
	end

	-- Look for powered exit gates
	for _, gate in ipairs(self.poweredGates) do
		-- If a gate is in this list, we trust the server that it's powered.
		local mainPart = gate and (gate:FindFirstChild("Main") or gate:FindFirstChildOfClass("BasePart"))
		if mainPart then
			local dist = (myRoot.Position - mainPart.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				bestTarget = { Type = "ExitGate", Object = gate }
			end
		end
	end

	self.currentTarget = bestTarget
end

function SurvivorController:OnInputBegan(input)
	if not self.isSurvivor then return end

	if input.KeyCode == INTERACTION_KEY then
		if self.currentTarget then
			if self.currentTarget.Type == "Unhook" then
				print("Requesting to unhook survivor:", self.currentTarget.Player.Name)
				EventManager.UnhookRequestEvent:FireServer(self.currentTarget.Player)
			elseif self.currentTarget.Type == "ExitGate" then
				print("Requesting to open gate:", self.currentTarget.Object.Name)
				EventManager.RequestOpenGateEvent:FireServer(self.currentTarget.Object)
			end
		end
	end
end

-- Create and initialize the controller
local controller = SurvivorController.new()
controller:Init()

return controller
