--!strict
--[=[
    @client
    This controller manages the UI and client-side logic for the Skill Check minigame.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

print("SkillCheckMachineController.client.lua loaded.")

-- Get remote events
local EventsFolder = ReplicatedStorage:WaitForChild("GameEvents")
local StartSkillCheckEvent = EventsFolder:WaitForChild("StartSkillCheck")
local ReportSkillCheckResult = EventsFolder:WaitForChild("ReportSkillCheckResult")

-- Get UI module
local SkillCheckGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("SkillCheckMachineGui"))

-- Create the GUI instance
local guiInstance = SkillCheckGuiModule()
guiInstance.Parent = PlayerGui
print("SkillCheckMachineController: GUI instance created.")

local backgroundBar = guiInstance.BackgroundBar
local successZone = backgroundBar.SuccessZone
local cursor = backgroundBar.Cursor

local activeMachineID: string?
local currentTween: Tween?
local isStopped = false -- FIX: Flag to prevent race condition

-- --- Functions ---

local function onInputBegan(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.Space then
		if guiInstance.Enabled and currentTween then
			isStopped = true -- Mark that the player has acted
			currentTween:Cancel()
			currentTween = nil

			-- Check for success
			local cursorPos = cursor.Position.X.Scale
			local zoneStart = successZone.Position.X.Scale - (successZone.Size.X.Scale / 2)
			local zoneEnd = successZone.Position.X.Scale + (successZone.Size.X.Scale / 2)

			local success = (cursorPos >= zoneStart and cursorPos <= zoneEnd)

			print("Skill check result: " .. tostring(success))
			if activeMachineID then
				ReportSkillCheckResult:FireServer(activeMachineID, success)
			end

			-- Hide UI after a short delay to show result
			task.wait(0.5)
			guiInstance.Enabled = false
		end
	end
end

local function startSkillCheck(machineID: string)
	if guiInstance.Enabled then return end

	activeMachineID = machineID
	isStopped = false -- Reset the flag for the new skill check
	guiInstance.Enabled = true
	cursor.Position = UDim2.fromScale(0, 0.5)

	-- Create and play the tween
	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
	currentTween = TweenService:Create(cursor, tweenInfo, {Position = UDim2.fromScale(1, 0.5)})

	currentTween.Completed:Connect(function()
		-- If it completes and was NOT stopped by the player, it's a failure
		if not isStopped then
			print("Skill check failed (timed out)")
			if activeMachineID then
				ReportSkillCheckResult:FireServer(activeMachineID, false)
			end
			guiInstance.Enabled = false
		end
	end)

	currentTween:Play()
end


-- --- Event Connections ---

StartSkillCheckEvent.OnClientEvent:Connect(function(machineID: string)
	startSkillCheck(machineID)
end)

UserInputService.InputBegan:Connect(onInputBegan)

print("SkillCheckMachineController: Event listeners connected.")
