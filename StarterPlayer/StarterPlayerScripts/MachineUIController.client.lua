-- StarterPlayer/StarterPlayerScripts/MachineUIController.client.lua

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remote Events
local startSkillCheckEvent = ReplicatedStorage:WaitForChild("StartSkillCheckMiniGame")
local skillCheckResultEvent = ReplicatedStorage:WaitForChild("SkillCheckResult")
local startMemoryEvent = ReplicatedStorage:WaitForChild("StartMemoryMiniGame")
local memoryResultEvent = ReplicatedStorage:WaitForChild("MemoryResult")
local startClassicEvent = ReplicatedStorage:WaitForChild("StartClassicMiniGame")
local classicResultEvent = ReplicatedStorage:WaitForChild("ClassicResult")

-- UI Creation
local screenGui = playerGui:FindFirstChild("MachineGUIs") or Instance.new("ScreenGui", playerGui); screenGui.Name = "MachineGUIs"; screenGui.ResetOnSpawn = false
local mainFrame = screenGui:FindFirstChild("MainFrame") or Instance.new("Frame", screenGui); mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1

-- --- UI Elements ---
local skillCheckFrame = Instance.new("Frame", mainFrame); skillCheckFrame.Name = "SkillCheckMachineFrame"; skillCheckFrame.Size = UDim2.new(0.4, 0, 0.15, 0); skillCheckFrame.Position = UDim2.new(0.3, 0, 0.425, 0); skillCheckFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); skillCheckFrame.BorderColor3 = Color3.fromRGB(200, 200, 200); skillCheckFrame.BorderSizePixel = 2; skillCheckFrame.Visible = false
local bar = Instance.new("Frame", skillCheckFrame); bar.Name = "Bar"; bar.Size = UDim2.new(0.9, 0, 0.2, 0); bar.Position = UDim2.new(0.05, 0, 0.4, 0); bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
local successZone = Instance.new("Frame", bar); successZone.Name = "SuccessZone"; successZone.Size = UDim2.new(0.2, 0, 1, 0); successZone.BackgroundColor3 = Color3.fromRGB(255, 255, 255); successZone.BackgroundTransparency = 0.5
local handle = Instance.new("Frame", bar); handle.Name = "Handle"; handle.Size = UDim2.new(0.04, 0, 1.4, 0); handle.Position = UDim2.new(0, 0, -0.2, 0); handle.BackgroundColor3 = Color3.fromRGB(220, 40, 40); handle.ZIndex = 2

local memoryFrame = Instance.new("Frame", mainFrame); memoryFrame.Name = "MemoryMachineFrame"; memoryFrame.Size = UDim2.new(0.4, 0, 0.7, 0); memoryFrame.Position = UDim2.new(0.3, 0, 0.15, 0); memoryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); memoryFrame.BorderColor3 = Color3.fromRGB(200, 200, 200); memoryFrame.BorderSizePixel = 2; memoryFrame.Visible = false
local memoryGrid = Instance.new("UIGridLayout", memoryFrame); memoryGrid.Name = "MemoryGridLayout"; memoryGrid.Padding = UDim.new(0.05, 0)
local memoryStatus = Instance.new("TextLabel", memoryFrame); memoryStatus.Name = "StatusLabel"; memoryStatus.Size = UDim2.new(1, 0, 0.1, 0); memoryStatus.Position = UDim2.new(0, 0, 0, 0); memoryStatus.BackgroundColor3 = Color3.fromRGB(60, 60, 60); memoryStatus.TextColor3 = Color3.fromRGB(255, 255, 255); memoryStatus.Text = "Memorize the pattern"; memoryStatus.Font = Enum.Font.SourceSansBold

local classicFrame = Instance.new("Frame", mainFrame); classicFrame.Name = "ClassicMachineFrame"; classicFrame.Size = UDim2.new(0.5, 0, 0.8, 0); classicFrame.Position = UDim2.new(0.25, 0, 0.1, 0); classicFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); classicFrame.BorderColor3 = Color3.fromRGB(200, 200, 200); classicFrame.BorderSizePixel = 2; classicFrame.Visible = false
local classicGrid = Instance.new("UIGridLayout", classicFrame); classicGrid.Name = "ClassicGridLayout"; classicGrid.CellPadding = UDim2.new(0, 0, 0, 0); classicGrid.CellSize = UDim2.new(1/6, 0, 1/6, 0);
local classicStatus = Instance.new("TextLabel", classicFrame); classicStatus.Name = "StatusLabel"; classicStatus.Size = UDim2.new(1, 0, 0.1, 0); classicStatus.Position = UDim2.new(0, 0, -0.1, 0); classicStatus.BackgroundColor3 = Color3.fromRGB(60, 60, 60); classicStatus.TextColor3 = Color3.fromRGB(255, 255, 255); classicStatus.Text = "Connect the matching pairs!"; classicStatus.Font = Enum.Font.SourceSansBold

-- --- Logic ---
local currentMachine = nil; local isGameActive = false

local function runSkillCheck(machine)
    if isGameActive then return end; isGameActive = true; currentMachine = machine
    skillCheckFrame.Visible = true; handle.Position = UDim2.new(0, 0, -0.2, 0)
    successZone.Position = UDim2.new(math.random(15, 65) / 100, 0, 0, 0)
    local tween = TweenService:Create(handle, TweenInfo.new(0.7, Enum.EasingStyle.Linear), {Position = UDim2.new(0.96, 0, -0.2, 0)})
    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
            tween:Pause(); inputConnection:Disconnect()
            local handleCenter = handle.Position.X.Scale + (handle.Size.X.Scale / 2)
            local zoneStart = successZone.Position.X.Scale; local zoneEnd = zoneStart + successZone.Size.X.Scale
            local wasSuccessful = (handleCenter >= zoneStart and handleCenter <= zoneEnd)
            if wasSuccessful then successZone.BackgroundColor3 = Color3.fromRGB(100, 255, 100) else bar.BackgroundColor3 = Color3.fromRGB(255, 100, 100) end
            task.wait(0.4)
            skillCheckFrame.Visible = false; successZone.BackgroundColor3 = Color3.fromRGB(255, 255, 255); bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            skillCheckResultEvent:FireServer(currentMachine, wasSuccessful); isGameActive = false
        end
    end)
    tween.Completed:Connect(function()
        if inputConnection.Connected then inputConnection:Disconnect(); skillCheckFrame.Visible = false; skillCheckResultEvent:FireServer(currentMachine, false); isGameActive = false end
    end)
    tween:Play()
end

local function runMemoryGame(machine, gridSize, pattern)
    if isGameActive then return end; isGameActive = true; currentMachine = machine
    for _, child in ipairs(memoryFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    memoryFrame.Visible = true; memoryGrid.CellSize = UDim2.new(1 / gridSize, -5, 1 / gridSize, -5)
    local gridButtons = {}
    for i = 1, gridSize * gridSize do local button = Instance.new("TextButton", memoryFrame); button.Name = "GridButton" .. i; button.Text = ""; button.BackgroundColor3 = Color3.fromRGB(90, 90, 90); table.insert(gridButtons, button) end
    memoryStatus.Text = "Memorize..."; task.wait(1)
    for _, tileIndex in ipairs(pattern) do local button = gridButtons[tileIndex]; button.BackgroundColor3 = Color3.fromRGB(150, 150, 255); task.wait(0.6); button.BackgroundColor3 = Color3.fromRGB(90, 90, 90); task.wait(0.2) end
    memoryStatus.Text = "Your turn!"; local playerInput = {}; local connections = {}
    for i, button in ipairs(gridButtons) do
        connections[i] = button.MouseButton1Click:Connect(function()
            if #playerInput < #pattern then
                button.BackgroundColor3 = Color3.fromRGB(200, 200, 100); table.insert(playerInput, i)
                if #playerInput == #pattern then
                    local success = true; for j = 1, #pattern do if playerInput[j] ~= pattern[j] then success = false; break end end
                    if success then memoryStatus.Text = "Success!"; memoryResultEvent:FireServer(currentMachine, true); task.wait(1); memoryFrame.Visible = false; isGameActive = false
                    else memoryStatus.Text = "Failure! Resetting..."; task.wait(1.5); isGameActive = false; runMemoryGame(machine, gridSize, pattern) end
                end
            end
        end)
    end
end

local function runClassicGame(machine, puzzle)
    if isGameActive then return end; isGameActive = true; currentMachine = machine
    for _, child in ipairs(classicFrame:GetChildren()) do if not child:IsA("UILayout") and not child:IsA("TextLabel") then child:Destroy() end end
    classicFrame.Visible = true
    local GRID_SIZE = 6; local grid = {}; for r = 1, GRID_SIZE do grid[r] = {} end; local nodes = {}
    for _, nodeInfo in ipairs(puzzle) do
        local num, r, c = nodeInfo[1], nodeInfo[2], nodeInfo[3]
        local nodeLabel = Instance.new("TextLabel", classicFrame); nodeLabel.Name = "Node_"..r.."_"..c; nodeLabel.Size = UDim2.new(1/GRID_SIZE, 0, 1/GRID_SIZE, 0); nodeLabel.Position = UDim2.new((c-1)/GRID_SIZE, 0, (r-1)/GRID_SIZE, 0); nodeLabel.Text = tostring(num); nodeLabel.Font = Enum.Font.SourceSansBold; nodeLabel.TextScaled = true; nodeLabel.BackgroundColor3 = Color3.fromRGB(150, 150, 150); nodeLabel.ZIndex = 2
        grid[r][c] = num; nodes[nodeLabel] = {r=r, c=c, num=num}
    end
    local selectedNode = nil; local pairsConnected = 0; local colors = {[1]=Color3.fromRGB(255,0,0),[2]=Color3.fromRGB(0,255,0),[3]=Color3.fromRGB(0,0,255),[4]=Color3.fromRGB(255,255,0),[5]=Color3.fromRGB(255,0,255),[6]=Color3.fromRGB(0,255,255)}
    for nodeLabel, nodeData in pairs(nodes) do
        nodeLabel.InputBegan:Connect(function()
            if not selectedNode then selectedNode = nodeData; nodeLabel.BorderColor3 = Color3.fromRGB(255,255,255); nodeLabel.BorderSizePixel = 2
            else
                if selectedNode ~= nodeData and selectedNode.num == nodeData.num then
                    local queue = {{ {r=selectedNode.r, c=selectedNode.c}, {{selectedNode.r, selectedNode.c}} }}; local visited = {[selectedNode.r..","..selectedNode.c]=true}; local path = nil
                    while #queue > 0 do
                        local current = table.remove(queue, 1); local pos, p = current[1], current[2]
                        if pos.r == nodeData.r and pos.c == nodeData.c then path = p; break end
                        local neighbors = {{pos.r+1,pos.c},{pos.r-1,pos.c},{pos.r,pos.c+1},{pos.r,pos.c-1}}
                        for _,n in ipairs(neighbors) do
                            local nr, nc = n[1], n[2]
                            if nr > 0 and nr <= GRID_SIZE and nc > 0 and nc <= GRID_SIZE and not visited[nr..","..nc] and (grid[nr][nc] == nil or (nr==nodeData.r and nc==nodeData.c)) then
                                visited[nr..","..nc] = true; local newPath = table.create(#p, p[1]); for i=1,#p do newPath[i]=p[i] end; table.insert(newPath, {nr,nc}); table.insert(queue, {{r=nr,c=nc}, newPath})
                            end
                        end
                    end
                    if path then
                        pairsConnected = pairsConnected + 1
                        for _, p_ in ipairs(path) do
                            local r, c = p_[1], p_[2]
                            if grid[r][c] == nil then local pathSegment = Instance.new("Frame", classicFrame); pathSegment.Size=UDim2.new(1/GRID_SIZE,0,1/GRID_SIZE,0); pathSegment.Position=UDim2.new((c-1)/GRID_SIZE,0,(r-1)/GRID_SIZE,0); pathSegment.BackgroundColor3=colors[nodeData.num]; pathSegment.BackgroundTransparency=0.5; pathSegment.ZIndex=1; grid[r][c] = "path" end
                        end
                        if pairsConnected == 6 then classicStatus.Text = "Success!"; classicResultEvent:FireServer(currentMachine, true); task.wait(1); classicFrame.Visible = false; isGameActive = false end
                    end
                end
                selectedNode = nil; for l,_ in pairs(nodes) do l.BorderSizePixel = 0 end
            end
        end)
    end
end

startSkillCheckEvent.OnClientEvent:Connect(runSkillCheck)
startMemoryEvent.OnClientEvent:Connect(runMemoryGame)
startClassicEvent.OnClientEvent:Connect(runClassicGame)

local cancelEvent = ReplicatedStorage:WaitForChild("CancelMiniGame")
cancelEvent.OnClientEvent:Connect(function()
    if isGameActive then
        print("Received cancel signal from server.")
        -- Hide all frames and reset state
        skillCheckFrame.Visible = false
        memoryFrame.Visible = false
        classicFrame.Visible = false
        isGameActive = false
        -- Any active tweens or loops will stop because isGameActive is false
        -- or because their parent frame is no longer visible.
    end
end)

print("MachineUIController initialized for all machine types.")
