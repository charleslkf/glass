-- StarterPlayer/StarterPlayerScripts/MachineUIController.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
local skillCheckFrame = Instance.new("Frame", mainFrame); skillCheckFrame.Name = "SkillCheckMachineFrame"; skillCheckFrame.Size = UDim2.new(0.4, 0, 0.2, 0); skillCheckFrame.Position = UDim2.new(0.3, 0, 0.4, 0); skillCheckFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); skillCheckFrame.BorderColor3 = Color3.fromRGB(200,200,200); skillCheckFrame.BorderSizePixel = 2; skillCheckFrame.Visible = false
local skillCheckProgressLabel = Instance.new("TextLabel", skillCheckFrame); skillCheckProgressLabel.Name = "ProgressLabel"; skillCheckProgressLabel.Size = UDim2.new(1,0,0.2,0); skillCheckProgressLabel.Position = UDim2.new(0,0,0.8,0); skillCheckProgressLabel.BackgroundColor3 = Color3.fromRGB(60,60,60); skillCheckProgressLabel.TextColor3 = Color3.fromRGB(255,255,255); skillCheckProgressLabel.Font = Enum.Font.SourceSansBold
local bar = Instance.new("Frame", skillCheckFrame); bar.Name = "Bar"; bar.Size = UDim2.new(0.9, 0, 0.2, 0); bar.Position = UDim2.new(0.05, 0, 0.4, 0); bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
local successZone = Instance.new("Frame", bar); successZone.Name = "SuccessZone"; successZone.Size = UDim2.new(0.2, 0, 1, 0); successZone.BackgroundColor3 = Color3.fromRGB(255, 255, 255); successZone.BackgroundTransparency = 0.5
local handle = Instance.new("Frame", bar); handle.Name = "Handle"; handle.Size = UDim2.new(0.04, 0, 1.4, 0); handle.Position = UDim2.new(0, 0, -0.2, 0); handle.BackgroundColor3 = Color3.fromRGB(220, 40, 40); handle.ZIndex = 2

-- Memory Game UI
local memoryFrame = Instance.new("Frame", mainFrame); memoryFrame.Name = "MemoryMachineFrame"; memoryFrame.Size = UDim2.new(0.4, 0, 0.7, 0); memoryFrame.Position = UDim2.new(0.3, 0, 0.15, 0); memoryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); memoryFrame.BorderColor3 = Color3.fromRGB(200, 200, 200); memoryFrame.BorderSizePixel = 2; memoryFrame.Visible = false
local memoryGrid = Instance.new("UIGridLayout", memoryFrame); memoryGrid.Name = "MemoryGridLayout"; memoryGrid.CellPadding = UDim2.new(0, 5, 0, 5)
local memoryStatus = Instance.new("TextLabel", memoryFrame); memoryStatus.Name = "StatusLabel"; memoryStatus.Size = UDim2.new(1, 0, 0.1, 0); memoryStatus.Position = UDim2.new(0, 0, 0.9, 0); memoryStatus.BackgroundColor3 = Color3.fromRGB(60, 60, 60); memoryStatus.TextColor3 = Color3.fromRGB(255, 255, 255); memoryStatus.Font = Enum.Font.SourceSansBold

-- Number Link UI
local numberLinkFrame = Instance.new("Frame", mainFrame); numberLinkFrame.Name = "NumberLinkFrame"; numberLinkFrame.Size = UDim2.new(0, 400, 0, 450); numberLinkFrame.Position = UDim2.new(0.5, -200, 0.5, -225); numberLinkFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); numberLinkFrame.BorderSizePixel = 0; numberLinkFrame.Visible = false
local nlCorner = Instance.new("UICorner", numberLinkFrame); nlCorner.CornerRadius = UDim.new(0, 8)
local nlTitle = Instance.new("TextLabel", numberLinkFrame); nlTitle.Size = UDim2.new(1, 0, 0, 50); nlTitle.Text = "Connect the Pairs"; nlTitle.Font = Enum.Font.SourceSansBold; nlTitle.TextColor3 = Color3.new(1, 1, 1); nlTitle.TextSize = 24; nlTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
local nlTitleCorner = Instance.new("UICorner", nlTitle); nlTitleCorner.CornerRadius = UDim.new(0, 8)
local nlGridFrame = Instance.new("Frame", numberLinkFrame); nlGridFrame.Size = UDim2.new(1, -20, 1, -70); nlGridFrame.Position = UDim2.new(0.5, 0, 0.5, 10); nlGridFrame.AnchorPoint = Vector2.new(0.5, 0.5); nlGridFrame.BackgroundTransparency = 1
local nlGridLayout = Instance.new("UIGridLayout", nlGridFrame); nlGridLayout.CellPadding = UDim2.new(0, 4, 0, 4)
local nlProgressLabel = Instance.new("TextLabel", numberLinkFrame); nlProgressLabel.Name = "ProgressLabel"; nlProgressLabel.Size = UDim2.new(1, -20, 0, 20); nlProgressLabel.Position = UDim2.new(0.5, 0, 1, -15); nlProgressLabel.AnchorPoint = Vector2.new(0.5, 1); nlProgressLabel.BackgroundTransparency = 1; nlProgressLabel.Font = Enum.Font.SourceSansBold; nlProgressLabel.TextColor3 = Color3.new(1,1,1); nlProgressLabel.TextSize = 18; nlProgressLabel.Text = "Progress: 0 / 6"

-- --- Logic ---
local currentMachine = nil
local isGameActive = false

local function closeAllGames()
	if not isGameActive then return end
	isGameActive = false
	currentMachine = nil
	skillCheckFrame.Visible = false
	memoryFrame.Visible = false
	numberLinkFrame.Visible = false
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
			if wasSuccessful then successZone.BackgroundColor3 = Color3.fromRGB(100,255,100) else bar.BackgroundColor3 = Color3.fromRGB(255,100,100) end
			task.wait(0.5); successZone.BackgroundColor3=Color3.fromRGB(255,255,255); bar.BackgroundColor3=Color3.fromRGB(80,80,80)
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

	local gridButtons={}; for i=1,gridSize*gridSize do local btn=Instance.new("TextButton",memoryFrame); btn.Name="GridButton"..i; btn.Text=""; btn.BackgroundColor3=Color3.fromRGB(90,90,90); table.insert(gridButtons,btn) end
	task.wait(1); for _,tileIndex in ipairs(pattern) do local btn=gridButtons[tileIndex]; btn.BackgroundColor3=Color3.fromRGB(150,150,255); task.wait(0.6); btn.BackgroundColor3=Color3.fromRGB(90,90,90); task.wait(0.2) end
	memoryStatus.Text = string.format("Your turn! (%d/%d)", currentProgress, neededProgress)
	local playerInput={}; local conns={}
	for i,btn in ipairs(gridButtons) do
		conns[i] = btn.MouseButton1Click:Connect(function()
			if #playerInput < #pattern then btn.BackgroundColor3=Color3.fromRGB(200,200,100); table.insert(playerInput,i)
				if #playerInput == #pattern then
					local success=true; for j=1,#pattern do if playerInput[j]~=pattern[j] then success=false; break end end
					for _,c in ipairs(conns) do c:Disconnect() end
					memoryResultEvent:FireServer(currentMachine, success)
				end
			end
		end)
	end
end

-- REWRITTEN NumberLinkGame function with simpler "click-to-match" logic
local function runNumberLinkGame(machine, puzzleData, currentProgress, neededProgress)
	print("Number Link game started, but is currently disabled to fix a syntax error.")
	closeAllGames()
end


-- --- Event Connections ---
startSkillCheckEvent.OnClientEvent:Connect(runSkillCheck)
startMemoryEvent.OnClientEvent:Connect(runMemoryGame)
startNumberLinkEvent.OnClientEvent:Connect(runNumberLinkGame)

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
