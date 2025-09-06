--[=[
	@class KillerController
	Handles client-side input and logic for the Killer role.
]=]
local KillerController = {}
KillerController.__index = KillerController

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local EventManager = ReplicatedStorage:WaitForChild("GameEvents")

local playerRoles = ReplicatedStorage:WaitForChild("PlayerRoles")
local playerStates = ReplicatedStorage:WaitForChild("PlayerStates")

local INTERACTION_KEY = Enum.KeyCode.E
local DROP_KEY = Enum.KeyCode.R
local INTERACTION_DISTANCE = 8

function KillerController.new()
	local self = setmetatable({}, KillerController)
	self.isKiller = false
	self.currentTarget = nil
	self.lastInteractionTimestamp = 0
	return self
end

function KillerController:Init()
	print("KillerController Initialized")

	-- Determine if the local player is the killer
	local role = playerRoles:GetAttribute(tostring(localPlayer.UserId))
	if role == "Killer" then
		self.isKiller = true
		print("You are the Killer.")
		-- Start the update loop only if the player is the killer
		RunService.Heartbeat:Connect(function() self:Update() end)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed then
				self:OnInputBegan(input)
			end
		end)
	end

	-- Listen for role changes in case they are assigned after joining
	playerRoles.AttributeChanged:Connect(function(attribute)
		if attribute == tostring(localPlayer.UserId) then
			local newRole = playerRoles:GetAttribute(tostring(localPlayer.UserId))
			if newRole == "Killer" and not self.isKiller then
				self.isKiller = true
				print("Role changed: You are now the Killer.")
				-- Start the update loop only if the player is the killer
				RunService.Heartbeat:Connect(function() self:Update() end)
				UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed then
						self:OnInputBegan(input)
					end
				end)
			else
				self.isKiller = false -- Or handle other role changes
			end
		end
	end)
end

function KillerController:Update()
	if not self.isKiller or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
		self.currentTarget = nil
		return
	end

	local myRoot = localPlayer.Character.HumanoidRootPart
	local myState = playerStates:GetAttribute(tostring(localPlayer.UserId))

	self.currentTarget = nil
	local closestDist = INTERACTION_DISTANCE

	if myState == "Carrying" then
		-- Look for hooks
		for _, hook in ipairs(CollectionService:GetTagged("Hook")) do
			local dist = (myRoot.Position - hook.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				self.currentTarget = { Type = "Hook", Object = hook }
			end
		end
	else
		-- Look for downed survivors
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local targetState = playerStates:GetAttribute(tostring(player.UserId))
				if targetState == "Downed" then
					local targetRoot = player.Character.HumanoidRootPart
					local dist = (myRoot.Position - targetRoot.Position).Magnitude
					if dist < closestDist then
						closestDist = dist
						self.currentTarget = { Type = "Survivor", Object = player }
					end
				end
			end
		end
	end
end

function KillerController:OnInputBegan(input)
	if not self.isKiller then return end

	local myState = playerStates:GetAttribute(tostring(localPlayer.UserId))

	if input.KeyCode == INTERACTION_KEY then
		if self.currentTarget then
			if myState == "Carrying" and self.currentTarget.Type == "Hook" then
				print("Requesting to hook survivor.")
				EventManager.HookRequestEvent:FireServer()
			elseif myState ~= "Carrying" and self.currentTarget.Type == "Survivor" then
				print("Requesting to pick up survivor:", self.currentTarget.Object.Name)
				EventManager.PickupRequestEvent:FireServer(self.currentTarget.Object)
			end
		end
	elseif input.KeyCode == DROP_KEY then
		if myState == "Carrying" then
			print("Requesting to drop survivor.")
			EventManager.DropRequestEvent:FireServer()
		end
	end
end

-- Create and initialize the controller
local controller = KillerController.new()
controller:Init()

return controller
