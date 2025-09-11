--!strict
--[=[
	@client
	@class GameHUDController
	This client-side script creates and manages the main game HUD, including
	game state announcements, objective tracking, and the endgame timer.
]=]
local GameHUDController = {}
GameHUDController.__index = GameHUDController

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local GameState = ReplicatedStorage:WaitForChild("GameState")
local PlayerRoles = ReplicatedStorage:WaitForChild("PlayerRoles")
local SoundManager = require(script.Parent.Parent:WaitForChild("SoundManager"))

-- A map of item names to their icon asset IDs
local ITEM_ICONS = {
	["Med-Kit"] = "rbxassetid://12623754649",
	["Decoy"] = "rbxassetid://117166078",
	["Picklock"] = "rbxassetid://116319273136552",
	["Key"] = "rbxassetid://79111672527011",
}

-- Main entry point
function GameHUDController.new()
	local self = setmetatable({}, GameHUDController)

	-- Create the main ScreenGui for the HUD
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "GameHUD"
	self.screenGui.ResetOnSpawn = false

	-- Create a central announcement label
	self.announcementLabel = Instance.new("TextLabel")
	self.announcementLabel.Name = "AnnouncementLabel"
	self.announcementLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
	self.announcementLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	self.announcementLabel.Position = UDim2.new(0.5, 0, 0.2, 0)
	self.announcementLabel.Font = Enum.Font.SourceSansBold
	self.announcementLabel.TextSize = 36
	self.announcementLabel.TextColor3 = Color3.new(1, 1, 1)
	self.announcementLabel.TextStrokeTransparency = 0
	self.announcementLabel.BackgroundTransparency = 1
	self.announcementLabel.Text = ""
	self.announcementLabel.Visible = false
	self.announcementLabel.Parent = self.screenGui

	-- Create the objective display
	self.objectiveFrame = Instance.new("Frame")
	self.objectiveFrame.Name = "ObjectiveFrame"
	self.objectiveFrame.Size = UDim2.new(0.25, 0, 0.1, 0)
	self.objectiveFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
	self.objectiveFrame.BackgroundTransparency = 1
	self.objectiveFrame.Parent = self.screenGui
	self.objectiveFrame.Visible = false

	self.machineLabel = Instance.new("TextLabel")
	self.machineLabel.Name = "MachineLabel"
	self.machineLabel.Size = UDim2.new(1, 0, 0.5, 0)
	self.machineLabel.Font = Enum.Font.SourceSans
	self.machineLabel.TextSize = 20
	self.machineLabel.TextColor3 = Color3.new(1, 1, 1)
	self.machineLabel.Text = "Machines Repaired: 0 / 0"
	self.machineLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.machineLabel.BackgroundTransparency = 1
	self.machineLabel.Parent = self.objectiveFrame

	self.timerLabel = Instance.new("TextLabel")
	self.timerLabel.Name = "TimerLabel"
	self.timerLabel.Size = UDim2.new(1, 0, 0.5, 0)
	self.timerLabel.Position = UDim2.new(0, 0, 0.5, 0)
	self.timerLabel.Font = Enum.Font.SourceSans
	self.timerLabel.TextSize = 20
	self.timerLabel.TextColor3 = Color3.new(1, 1, 1)
	self.timerLabel.Text = "Time Left: 0:00"
	self.timerLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.timerLabel.BackgroundTransparency = 1
	self.timerLabel.Parent = self.objectiveFrame

	-- Create Item Display
	self.itemImage = Instance.new("ImageLabel")
	self.itemImage.Name = "ItemImage"
	self.itemImage.Size = UDim2.new(0.1, 0, 0.15, 0)
	self.itemImage.AnchorPoint = Vector2.new(1, 1)
	self.itemImage.Position = UDim2.new(0.98, 0, 0.98, 0)
	self.itemImage.BackgroundTransparency = 1
	self.itemImage.Visible = false
	self.itemImage.Parent = self.screenGui

	self.chargeLabel = Instance.new("TextLabel")
	self.chargeLabel.Name = "ChargeLabel"
	self.chargeLabel.Size = UDim2.new(0.3, 0, 0.3, 0)
	self.chargeLabel.AnchorPoint = Vector2.new(0, 1)
	self.chargeLabel.Position = UDim2.new(0.1, 0, 1, 0)
	self.chargeLabel.Font = Enum.Font.SourceSansBold
	self.chargeLabel.TextSize = 18
	self.chargeLabel.TextColor3 = Color3.new(1, 1, 1)
	self.chargeLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	self.chargeLabel.TextStrokeTransparency = 0.5
	self.chargeLabel.BackgroundTransparency = 1
	self.chargeLabel.Visible = false
	self.chargeLabel.Parent = self.itemImage

	-- Create Endgame Collapse UI
	self.endgameTimerLabel = Instance.new("TextLabel")
	self.endgameTimerLabel.Name = "EndgameTimerLabel"
	self.endgameTimerLabel.Size = UDim2.new(1, 0, 0.2, 0)
	self.endgameTimerLabel.AnchorPoint = Vector2.new(0.5, 0)
	self.endgameTimerLabel.Position = UDim2.new(0.5, 0, 0.1, 0)
	self.endgameTimerLabel.Font = Enum.Font.SourceSansBold
	self.endgameTimerLabel.TextSize = 60
	self.endgameTimerLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
	self.endgameTimerLabel.Text = "2:00"
	self.endgameTimerLabel.BackgroundTransparency = 1
	self.endgameTimerLabel.Visible = false
	self.endgameTimerLabel.Parent = self.screenGui

	self.vignette = Instance.new("ImageLabel")
	self.vignette.Name = "Vignette"
	self.vignette.Size = UDim2.new(1, 0, 1, 0)
	self.vignette.Image = "rbxassetid://116451346870907"
	self.vignette.ScaleType = Enum.ScaleType.Slice
	self.vignette.SliceCenter = Rect.new(100, 100, 100, 100) -- Slice the center to make borders
	self.vignette.ImageColor3 = Color3.fromRGB(255, 0, 0)
	self.vignette.ImageTransparency = 1
	self.vignette.BackgroundTransparency = 1
	self.vignette.Visible = false
	self.vignette.Parent = self.screenGui

	return self
end

-- Shows a message for a short duration, then fades it out
function GameHUDController:ShowAnnouncement(message: string, duration: number)
	self.announcementLabel.Text = message
	self.announcementLabel.Visible = true

	if self.announcementTimer then
		task.cancel(self.announcementTimer)
	end

	self.announcementTimer = task.delay(duration, function()
		self.announcementLabel.Visible = false
		self.announcementTimer = nil
	end)
end

-- Initializes the controller and starts listening for events
function GameHUDController:Init()
	print("GameHUDController Initialized")

	-- Listen for game state changes
	GameState.AttributeChanged:Connect(function(attribute)
		if attribute == "State" then
			self:OnStateChanged(GameState:GetAttribute("State"))
		elseif attribute == "MachinesCompleted" or attribute == "MachinesTotal" then
			local completed = GameState:GetAttribute("MachinesCompleted") or 0
			local total = GameState:GetAttribute("MachinesTotal") or 0
			self.machineLabel.Text = "Machines Repaired: " .. completed .. " / " .. total
		end
	end)

	-- Listen for role and item changes
	PlayerRoles.AttributeChanged:Connect(function(attribute)
		if attribute == tostring(localPlayer.UserId) then
			local role = PlayerRoles:GetAttribute(attribute)
			self:ShowAnnouncement("YOU ARE THE " .. string.upper(role), 5)
		end

		if attribute == tostring(localPlayer.UserId) .. "_Item" then
			local itemName = PlayerRoles:GetAttribute(attribute)
			self:UpdateItemDisplay(itemName)
		end

		if attribute == tostring(localPlayer.UserId) .. "_ItemCharges" then
			local charges = PlayerRoles:GetAttribute(attribute)
			self:UpdateChargeDisplay(charges)
		end
	end)

	-- Parent the ScreenGui to the PlayerGui to make it visible
	self.screenGui.Parent = playerGui

	-- Show initial state
	self:OnStateChanged(GameState:GetAttribute("State"))
	self:UpdateItemDisplay(PlayerRoles:GetAttribute(tostring(localPlayer.UserId) .. "_Item"))
	self:UpdateChargeDisplay(PlayerRoles:GetAttribute(tostring(localPlayer.UserId) .. "_ItemCharges"))
end

function GameHUDController:UpdateChargeDisplay(charges: number?)
	if charges and charges > 0 then
		self.chargeLabel.Text = "x" .. tostring(charges)
		self.chargeLabel.Visible = true
	else
		self.chargeLabel.Visible = false
	end
end

function GameHUDController:UpdateItemDisplay(itemName: string?)
	if itemName and ITEM_ICONS[itemName] then
		self.itemImage.Image = ITEM_ICONS[itemName]
		self.itemImage.Visible = true
	else
		self.itemImage.Visible = false
		self:UpdateChargeDisplay(nil) -- Hide charges if item is hidden
	end
end

-- Formats seconds into a M:SS string
function GameHUDController:FormatTime(seconds: number)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%d:%02d", minutes, remainingSeconds)
end

function GameHUDController:OnStateChanged(newState: string)
	-- Disconnect any running loops to prevent duplicates
	if self.countdownConnection then
		self.countdownConnection:Disconnect()
		self.countdownConnection = nil
	end
	if self.roundTimerConnection then
		self.roundTimerConnection:Disconnect()
		self.roundTimerConnection = nil
	end
	if self.endgameTimerConnection then
		self.endgameTimerConnection:Disconnect()
		self.endgameTimerConnection = nil
	end
	if self.vignetteTween then
		self.vignetteTween:Cancel()
		self.vignetteTween = nil
		self.vignette.Visible = false
	end
	SoundManager:StopSound("EndgameCollapse")

	-- Control visibility of UI elements based on state
	self.objectiveFrame.Visible = (newState == "InRound")
	self.endgameTimerLabel.Visible = (newState == "Endgame")

	if newState == "Lobby" then
		self.announcementLabel.Visible = true
		self.countdownConnection = RunService.Heartbeat:Connect(function()
			local countdownEndTime = GameState:GetAttribute("CountdownEndTime")
			if countdownEndTime then
				local timeLeft = math.ceil(countdownEndTime - os.time())
				if timeLeft > 0 then
					self.announcementLabel.Text = "Round starting in: " .. timeLeft
				else
					self.announcementLabel.Text = "Waiting for players..."
				end
			else
				self.announcementLabel.Text = "Waiting for more players..."
			end
		end)
	elseif newState == "InRound" then
		self.roundTimerConnection = RunService.Heartbeat:Connect(function()
			local roundEndTime = GameState:GetAttribute("RoundEndTime")
			if roundEndTime then
				local timeLeft = math.ceil(roundEndTime - os.time())
				if timeLeft >= 0 then
					self.timerLabel.Text = "Time Left: " .. self:FormatTime(timeLeft)
				end
			end
		end)
	elseif newState == "Endgame" then
		self.vignette.Visible = true
		self.vignetteTween = TweenService:Create(self.vignette, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {ImageTransparency = 0.7})
		self.vignetteTween:Play()
		SoundManager:PlaySound("EndgameCollapse")

		self.endgameTimerConnection = RunService.Heartbeat:Connect(function()
			local endgameEndTime = GameState:GetAttribute("EndgameEndTime")
			if endgameEndTime then
				local timeLeft = math.ceil(endgameEndTime - os.time())
				if timeLeft >= 0 then
					self.endgameTimerLabel.Text = self:FormatTime(timeLeft)
				end
			end
		end)
	elseif newState == "Intermission" then
		self:ShowAnnouncement("Round over!", 5)
	end
end

-- Create and initialize the controller
local controller = GameHUDController.new()
controller:Init()

return controller
