-- StarterPlayer/StarterPlayerScripts/MachineUIController.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local ThemeManager = require(script.Parent:WaitForChild("ThemeManager"))

-- Remote Events
local startSkillCheckEvent = ReplicatedStorage:WaitForChild("StartSkillCheckMiniGame")
local skillCheckResultEvent = ReplicatedStorage:WaitForChild("SkillCheckResult")
local startMemoryEvent = ReplicatedStorage:WaitForChild("StartMemoryMiniGame")
local memoryResultEvent = ReplicatedStorage:WaitForChild("MemoryResult")
local startNumberLinkEvent = ReplicatedStorage:WaitForChild("StartNumberLinkMiniGame")
local numberLinkResultEvent = ReplicatedStorage:WaitForChild("NumberLinkResult")
local cancelEvent = ReplicatedStorage:WaitForChild("CancelMiniGame")
local miniGameCompleteEvent = ReplicatedStorage:WaitForChild("MiniGameComplete")

local MAX_INTERACTION_DISTANCE = 12

-- UI Creation
local screenGui = playerGui:FindFirstChild("MachineGUIs") or Instance.new("ScreenGui", playerGui); screenGui.Name = "MachineGUIs"; screenGui.ResetOnSpawn = false
local mainFrame = screenGui:FindFirstChild("MainFrame") or Instance.new("Frame", screenGui); mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1

-- --- UI Elements ---
-- Skill Check UI
local skillCheckFrame = Instance.new("Frame", mainFrame); skillCheckFrame.Name = "SkillCheckMachineFrame"; skillCheckFrame.Size = UDim2.new(0.4, 0, 0.2, 0); skillCheckFrame.Position = UDim2.new(0.3, 0, 0.4, 0); skillCheckFrame.BackgroundColor3 = ThemeManager.get("Background"); skillCheckFrame.BorderColor3 = ThemeManager.get("Border"); skillCheckFrame.BorderSizePixel = 2; skillCheckFrame.Visible = false
local skillCheckProgressLabel = Instance.new("TextLabel", skillCheckFrame); skillCheckProgressLabel.Name = "ProgressLabel"; skillCheckProgressLabel.Size = UDim2.new(1,0,0.2,0); skillCheckProgressLabel.Position = UDim2.new(0,0,0.8,0); skillCheckProgressLabel.BackgroundColor3 = ThemeManager.get("Secondary"); skillCheckProgressLabel.TextColor3 = ThemeManager.get("Text"); skillCheckProgressLabel.Font = Enum.Font.SourceSansBold
local bar = Instance.new("Frame", skillCheckFrame); bar.Name = "Bar"; bar.Size = UDim2.new(0.9, 0, 0.2, 0); bar.Position = UDim2.new(0.05, 0, 0.4, 0); bar.BackgroundColor3 = ThemeManager.get("Tertiary")
local successZone = Instance.new("Frame", bar); successZone.Name = "SuccessZone"; successZone.Size = UDim2.new(0.2, 0, 1, 0); successZone.BackgroundColor3 = ThemeManager.get("SuccessZone"); successZone.BackgroundTransparency = 0.5
local handle = Instance.new("Frame", bar); handle.Name = "Handle"; handle.Size = UDim2.new(0.04, 0, 1.4, 0); handle.Position = UDim2.new(0, 0, -0.2, 0); handle.BackgroundColor3 = ThemeManager.get("Handle"); handle.ZIndex = 2

-- Memory Game UI
local memoryFrame = Instance.new("Frame", mainFrame); memoryFrame.Name = "MemoryMachineFrame"; memoryFrame.Size = UDim2.new(0.4, 0, 0.7, 0); memoryFrame.Position = UDim2.new(0.3, 0, 0.15, 0); memoryFrame.BackgroundColor3 = ThemeManager.get("Primary"); memoryFrame.BorderColor3 = ThemeManager.get("Border"); memoryFrame.BorderSizePixel = 2; memoryFrame.Visible = false
local memoryGrid = Instance.new("UIGridLayout", memoryFrame); memoryGrid.Name = "MemoryGridLayout"; memoryGrid.CellPadding = UDim2.new(0, 5, 0, 5)
local memoryStatus = Instance.new("TextLabel", memoryFrame); memoryStatus.Name = "StatusLabel"; memoryStatus.Size = UDim2.new(1, 0, 0.1, 0); memoryStatus.Position = UDim2.new(0, 0, 0.9, 0); memoryStatus.BackgroundColor3 = ThemeManager.get("Secondary"); memoryStatus.TextColor3 = ThemeManager.get("Text"); memoryStatus.Font = Enum.Font.SourceSansBold

-- Number Link UI
local numberLinkFrame = Instance.new("Frame", mainFrame); numberLinkFrame.Name = "NumberLinkFrame"; numberLinkFrame.Size = UDim2.new(0, 400, 0, 450); numberLinkFrame.Position = UDim2.new(0.5, -200, 0.5, -225); numberLinkFrame.BackgroundColor3 = ThemeManager.get("Background"); numberLinkFrame.BorderSizePixel = 0; numberLinkFrame.Visible = false
local nlCorner = Instance.new("UICorner", numberLinkFrame); nlCorner.CornerRadius = UDim.new(0, 8)
local nlTitle = Instance.new("TextLabel", numberLinkFrame); nlTitle.Size = UDim2.new(1, 0, 0, 50); nlTitle.Text = "Connect the Pairs"; nlTitle.Font = Enum.Font.SourceSansBold; nlTitle.TextColor3 = ThemeManager.get("Text"); nlTitle.TextSize = 24; nlTitle.BackgroundColor3 = ThemeManager.get("Primary")
local nlTitleCorner = Instance.new("UICorner", nlTitle); nlTitleCorner.CornerRadius = UDim.new(0, 8)
local nlGridFrame = Instance.new("Frame", numberLinkFrame); nlGridFrame.Size = UDim2.new(1, -20, 1, -70); nlGridFrame.Position = UDim2.new(0.5, 0, 0.5, 10); nlGridFrame.AnchorPoint = Vector2.new(0.5, 0.5); nlGridFrame.BackgroundTransparency = 1
local nlGridLayout = Instance.new("UIGridLayout", nlGridFrame); nlGridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
local nlProgressLabel = Instance.new("TextLabel", numberLinkFrame); nlProgressLabel.Name = "ProgressLabel"; nlProgressLabel.Size = UDim2.new(1, -20, 0, 20); nlProgressLabel.Position = UDim2.new(0.5, 0, 1, -15); nlProgressLabel.AnchorPoint = Vector2.new(0.5, 1); nlProgressLabel.BackgroundTransparency = 1; nlProgressLabel.Font = Enum.Font.SourceSansBold; nlProgressLabel.TextColor3 = ThemeManager.get("Text"); nlProgressLabel.TextSize = 18; nlProgressLabel.Text = "Progress: 0 / 6"

-- --- Logic ---
local currentMachine = nil
local isGameActive = false
local nlMouseUpConnection = nil
local nlFrameLeaveConnection = nil

local function closeAllGames()
	if not isGameActive then return end
	isGameActive = false
	currentMachine = nil
	skillCheckFrame.Visible = false
	memoryFrame.Visible = false
	numberLinkFrame.Visible = false
	if nlMouseUpConnection then nlMouseUpConnection:Disconnect(); nlMouseUpConnection = nil end
	if nlFrameLeaveConnection then nlFrameLeaveConnection:Disconnect(); nlFrameLeaveConnection = nil end
end

local function runSkillCheck(machine, currentProgress, neededProgress)
	isGameActive = true; currentMachine = machine
	skillCheckProgressLabel.Text = string.format("Progress: %d / %d", currentProgress, neededProgress)
	if currentProgress >= neededProgress then skillCheckProgressLabel.Text = "Mission Completed!"; task.wait(1.5); closeAllGames(); return end
	task.wait(1.5); skillCheckFrame.Visible = true; handle.Position = UDim2.new(0, 0, -0.2, 0)
	successZone.Position = UDim2.new(math.random(15, 65) / 100, 0, 0, 0)
	local tween = TweenService:Create(handle, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {Position = UDim2.new(0.96, 0, -0.2, 0)})
	local inputConnection; inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
		if gp or not isGameActive then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
			tween:Pause(); inputConnection:Disconnect()
			local handleCenter = handle.Position.X.Scale+(handle.Size.X.Scale/2); local zoneStart=successZone.Position.X.Scale; local zoneEnd=zoneStart+successZone.Size.X.Scale
			local wasSuccessful = (handleCenter >= zoneStart and handleCenter <= zoneEnd)
			if wasSuccessful then successZone.BackgroundColor3 = ThemeManager.get("Success") else bar.BackgroundColor3 = ThemeManager.get("Failure") end
			task.wait(0.5); successZone.BackgroundColor3=ThemeManager.get("SuccessZone"); bar.BackgroundColor3=ThemeManager.get("Tertiary")
			skillCheckResultEvent:FireServer(currentMachine, wasSuccessful)
		end
	end)
	tween.Completed:Connect(function() if inputConnection.Connected then inputConnection:Disconnect(); skillCheckResultEvent:FireServer(currentMachine, false) end end)
	tween:Play()
end

local function runMemoryGame(machine, gridSize, pattern, currentProgress, neededProgress)
	isGameActive = true; currentMachine = machine
	for _, child in ipairs(memoryFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	memoryFrame.Visible = true; memoryGrid.CellSize = UDim2.new(1/gridSize,-10,1/gridSize,-10); memoryStatus.Text = string.format("Progress: %d / %d", currentProgress, neededProgress)
	if currentProgress >= neededProgress then memoryStatus.Text = "Mission Completed!"; task.wait(1.5); closeAllGames(); return end
	local gridButtons={}; for i=1,gridSize*gridSize do local btn=Instance.new("TextButton",memoryFrame); btn.Name="GridButton"..i; btn.Text=""; btn.BackgroundColor3=ThemeManager.get("Tertiary"); table.insert(gridButtons,btn) end
	task.wait(1); for _,tileIndex in ipairs(pattern) do local btn=gridButtons[tileIndex]; btn.BackgroundColor3=ThemeManager.get("MemoryPattern"); task.wait(0.6); btn.BackgroundColor3=ThemeManager.get("Tertiary"); task.wait(0.2) end
	memoryStatus.Text = string.format("Your turn! (%d/%d)", currentProgress, neededProgress)
	local playerInput={}; local conns={}
	for i,btn in ipairs(gridButtons) do
		conns[i] = btn.MouseButton1Click:Connect(function()
			if #playerInput < #pattern then btn.BackgroundColor3=ThemeManager.get("Highlight"); table.insert(playerInput,i)
				if #playerInput == #pattern then
					local success=true; for j=1,#pattern do if playerInput[j]~=pattern[j] then success=false; break end end
					for _,c in ipairs(conns) do c:Disconnect() end
					memoryResultEvent:FireServer(currentMachine, success)
				end
			end
		end)
	end
end

--[[
local function runNumberLinkGame(machine, puzzleData, currentProgress, neededProgress)
	isGameActive = true
	currentMachine = machine
	numberLinkFrame.Visible = true
	nlProgressLabel.Text = "Connect all 6 pairs!"

	local gridSize = puzzleData[1]
	local endpoints = {}
	local paths = {}
	local cell_buttons = {}
	local completedPairs = 0
	local isDragging = false
	local activeColor = nil
	local currentPath = {}

	for _, child in ipairs(nlGridFrame:GetChildren()) do
		if not child:IsA("UIGridLayout") then child:Destroy() end
	end
	nlGridLayout.CellSize = UDim2.new(1/gridSize, -4, 1/gridSize, -4)

	local pairColors = ThemeManager.get("PairColors")
	for i = 2, #puzzleData do
		local pairInfo = puzzleData[i]
		local color = pairColors[i - 1]
		endpoints[pairInfo.start] = { color = color, partner = pairInfo.end }
		endpoints[pairInfo.end] = { color = color, partner = pairInfo.start }
		paths[color] = {}
	end

	local function checkWinCondition()
		if completedPairs == #pairColors then
			task.wait(0.5)
			numberLinkResultEvent:FireServer(currentMachine, true)
		end
	end

	local function clearPath(path, color)
		for _, cellIndex in ipairs(path) do
			if not endpoints[cellIndex] then
				cell_buttons[cellIndex].BackgroundColor3 = ThemeManager.get("Secondary")
			end
		end
		paths[color] = {}
	end

	local function finalizePath(path, color)
		paths[color] = path
		completedPairs = completedPairs + 1
		nlProgressLabel.Text = string.format("Pairs connected: %d / %d", completedPairs, #pairColors)
		checkWinCondition()
	end

	local function onDragEnd()
		if not isDragging then return end
		local lastCell = currentPath[#currentPath]
		local startCell = currentPath[1]
		if not startCell then isDragging = false; return end
		local partnerCell = endpoints[startCell].partner
		if lastCell == partnerCell then
			finalizePath(currentPath, activeColor)
		else
			clearPath(currentPath, activeColor)
		end
		isDragging = false
		activeColor = nil
		currentPath = {}
	end

	for i = 1, gridSize * gridSize do
		local cellButton = Instance.new("TextButton", nlGridFrame)
		cellButton.Name = tostring(i)
		cellButton.Text = ""
		cellButton.BackgroundColor3 = ThemeManager.get("Secondary")
		cellButton.BorderSizePixel = 0
		local uiCorner = Instance.new("UICorner", cellButton); uiCorner.CornerRadius = UDim.new(0, 4)
		cell_buttons[i] = cellButton
		if endpoints[i] then
			cellButton.BackgroundColor3 = endpoints[i].color
		end
		cellButton.MouseButton1Down:Connect(function()
			if endpoints[i] then
				isDragging = true
				activeColor = endpoints[i].color
				currentPath = {i}
				if #paths[activeColor] > 0 then
					completedPairs = completedPairs - 1
					clearPath(paths[activeColor], activeColor)
				end
			end
		end)
		cellButton.MouseEnter:Connect(function()
			if not isDragging or not activeColor then return end
			if table.find(currentPath, i) then return end
			local isOccupied = false
			for color, path in pairs(paths) do
				if color ~= activeColor and table.find(path, i) then
					isOccupied = true
					break
				end
			end
			if not isOccupied then
				table.insert(currentPath, i)
				if endpoints[i] and endpoints[i].color ~= activeColor then
					onDragEnd()
				else
					cellButton.BackgroundColor3 = activeColor
				end
			end
		end)
	end

	nlMouseUpConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			onDragEnd()
		end
	end)

	nlFrameLeaveConnection = mainFrame.MouseLeave:Connect(onDragEnd)
end
--]]

-- --- Event Connections ---
startSkillCheckEvent.OnClientEvent:Connect(runSkillCheck)
startMemoryEvent.OnClientEvent:Connect(runMemoryGame)
-- startNumberLinkEvent.OnClientEvent:Connect(runNumberLinkGame)

cancelEvent.OnClientEvent:Connect(closeAllGames)
miniGameCompleteEvent.OnClientEvent:Connect(function() print("Client received MiniGameComplete signal."); closeAllGames() end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent or not isGameActive then return end
	if input.KeyCode == Enum.KeyCode.Backspace then
		cancelEvent:FireServer(currentMachine)
		closeAllGames()
	end
end)

RunService.RenderStepped:Connect(function()
	if isGameActive and currentMachine then
		local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not rootPart then closeAllGames(); return end
		if typeof(currentMachine) ~= "Instance" or not currentMachine.Parent then closeAllGames(); return end
		local success, distance = pcall(function() return (rootPart.Position - currentMachine.Position).Magnitude end)
		if success and distance > MAX_INTERACTION_DISTANCE then
			cancelEvent:FireServer(currentMachine)
			closeAllGames()
		elseif not success then
			closeAllGames()
		end
	end
end)

print("MachineUIController initialized with all minigames.")
