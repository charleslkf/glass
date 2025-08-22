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
local cancelEvent = ReplicatedStorage:WaitForChild("CancelMiniGame")
local miniGameCompleteEvent = ReplicatedStorage:WaitForChild("MiniGameComplete")

-- UI Creation
local screenGui = playerGui:FindFirstChild("MachineGUIs") or Instance.new("ScreenGui", playerGui); screenGui.Name = "MachineGUIs"; screenGui.ResetOnSpawn = false
local mainFrame = screenGui:FindFirstChild("MainFrame") or Instance.new("Frame", screenGui); mainFrame.Name = "MainFrame"; mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1

-- --- UI Elements ---
local skillCheckFrame = Instance.new("Frame", mainFrame); skillCheckFrame.Name = "SkillCheckMachineFrame"; skillCheckFrame.Size = UDim2.new(0.4, 0, 0.2, 0); skillCheckFrame.Position = UDim2.new(0.3, 0, 0.4, 0); skillCheckFrame.BackgroundColor3 = Color3.fromRGB(30,30,30); skillCheckFrame.BorderColor3 = Color3.fromRGB(200,200,200); skillCheckFrame.BorderSizePixel = 2; skillCheckFrame.Visible = false
local skillCheckProgressLabel = Instance.new("TextLabel", skillCheckFrame); skillCheckProgressLabel.Name = "ProgressLabel"; skillCheckProgressLabel.Size = UDim2.new(1,0,0.2,0); skillCheckProgressLabel.Position = UDim2.new(0,0,0.8,0); skillCheckProgressLabel.BackgroundColor3 = Color3.fromRGB(60,60,60); skillCheckProgressLabel.TextColor3 = Color3.fromRGB(255,255,255); skillCheckProgressLabel.Font = Enum.Font.SourceSansBold
local bar = Instance.new("Frame", skillCheckFrame); bar.Name = "Bar"; bar.Size = UDim2.new(0.9, 0, 0.2, 0); bar.Position = UDim2.new(0.05, 0, 0.4, 0); bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
local successZone = Instance.new("Frame", bar); successZone.Name = "SuccessZone"; successZone.Size = UDim2.new(0.2, 0, 1, 0); successZone.BackgroundColor3 = Color3.fromRGB(255, 255, 255); successZone.BackgroundTransparency = 0.5
local handle = Instance.new("Frame", bar); handle.Name = "Handle"; handle.Size = UDim2.new(0.04, 0, 1.4, 0); handle.Position = UDim2.new(0, 0, -0.2, 0); handle.BackgroundColor3 = Color3.fromRGB(220, 40, 40); handle.ZIndex = 2

local memoryFrame = Instance.new("Frame", mainFrame); memoryFrame.Name = "MemoryMachineFrame"; memoryFrame.Size = UDim2.new(0.4, 0, 0.7, 0); memoryFrame.Position = UDim2.new(0.3, 0, 0.15, 0); memoryFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); memoryFrame.BorderColor3 = Color3.fromRGB(200, 200, 200); memoryFrame.BorderSizePixel = 2; memoryFrame.Visible = false
local memoryGrid = Instance.new("UIGridLayout", memoryFrame); memoryGrid.Name = "MemoryGridLayout"; memoryGrid.CellPadding = UDim2.new(0, 5, 0, 5)
local memoryStatus = Instance.new("TextLabel", memoryFrame); memoryStatus.Name = "StatusLabel"; memoryStatus.Size = UDim2.new(1, 0, 0.1, 0); memoryStatus.Position = UDim2.new(0, 0, 0.9, 0); memoryStatus.BackgroundColor3 = Color3.fromRGB(60, 60, 60); memoryStatus.TextColor3 = Color3.fromRGB(255, 255, 255); memoryStatus.Font = Enum.Font.SourceSansBold

local classicFrame = Instance.new("Frame", mainFrame); classicFrame.Name = "ClassicMachineFrame"; classicFrame.Size = UDim2.new(0.5, 0, 0.8, 0); classicFrame.Position = UDim2.new(0.25, 0, 0.1, 0); classicFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); classicFrame.BorderColor3 = Color3.fromRGB(200, 200, 200); classicFrame.BorderSizePixel = 2; classicFrame.Visible = false
local classicGrid = Instance.new("UIGridLayout", classicFrame); classicGrid.Name = "ClassicGridLayout"; classicGrid.CellPadding = UDim2.new(0, 0, 0, 0); classicGrid.CellSize = UDim2.new(1/8, 0, 1/8, 0);
local classicStatus = Instance.new("TextLabel", classicFrame); classicStatus.Name = "StatusLabel"; classicStatus.Size = UDim2.new(1, 0, 0.1, 0); classicStatus.Position = UDim2.new(0, 0, -0.1, 0); classicStatus.BackgroundColor3 = Color3.fromRGB(60, 60, 60); classicStatus.TextColor3 = Color3.fromRGB(255, 255, 255); classicStatus.Text = "Connect the matching pairs!"; classicStatus.Font = Enum.Font.SourceSansBold

-- --- Logic ---
local currentMachine = nil; local isGameActive = false

local function runSkillCheck(machine, currentProgress, neededProgress)
    isGameActive = true; currentMachine = machine
    skillCheckProgressLabel.Text = string.format("Progress: %d / %d", currentProgress, neededProgress)
    task.wait(1.5); skillCheckFrame.Visible = true; handle.Position = UDim2.new(0, 0, -0.2, 0)
    successZone.Position = UDim2.new(math.random(15, 65) / 100, 0, 0, 0)
    local tween = TweenService:Create(handle, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {Position = UDim2.new(0.96, 0, -0.2, 0)})
    local inputConnection; inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not isGameActive then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
            tween:Pause(); inputConnection:Disconnect(); local handleCenter = handle.Position.X.Scale+(handle.Size.X.Scale/2); local zoneStart=successZone.Position.X.Scale; local zoneEnd=zoneStart+successZone.Size.X.Scale
            local wasSuccessful = (handleCenter >= zoneStart and handleCenter <= zoneEnd)
            if wasSuccessful then successZone.BackgroundColor3 = Color3.fromRGB(100,255,100) else bar.BackgroundColor3 = Color3.fromRGB(255,100,100) end
            task.wait(0.5); if wasSuccessful then successZone.BackgroundColor3=Color3.fromRGB(255,255,255) else bar.BackgroundColor3=Color3.fromRGB(80,80,80) end
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
    local gridButtons={}; for i=1,gridSize*gridSize do local btn=Instance.new("TextButton",memoryFrame); btn.Name="GridButton"..i; btn.Text=""; btn.BackgroundColor3=Color3.fromRGB(90,90,90); table.insert(gridButtons,btn) end
    task.wait(1); for _,tileIndex in ipairs(pattern) do local btn=gridButtons[tileIndex]; btn.BackgroundColor3=Color3.fromRGB(150,150,255); task.wait(0.6); btn.BackgroundColor3=Color3.fromRGB(90,90,90); task.wait(0.2) end
    memoryStatus.Text = string.format("Your turn! (%d/%d)", currentProgress, neededProgress)
    local playerInput={}; local conns={}
    for i,btn in ipairs(gridButtons) do
        conns[i] = btn.MouseButton1Click:Connect(function()
            if #playerInput < #pattern then btn.BackgroundColor3=Color3.fromRGB(200,200,100); table.insert(playerInput,i)
                if #playerInput == #pattern then
                    local success=true; for j=1,#pattern do if playerInput[j]~=pattern[j] then success=false; break end end
                    memoryResultEvent:FireServer(currentMachine, success)
                end
            end
        end)
    end
end

local function runClassicGame(machine, puzzle)
    isGameActive = true; currentMachine = machine
    for _, child in ipairs(classicFrame:GetChildren()) do if not child:IsA("UILayout") and not child:IsA("TextLabel") then child:Destroy() end end
    classicFrame.Visible = true; classicStatus.Text = "Connect the matching pairs!"
    local GRID_SIZE = 8; classicGrid.CellSize = UDim2.new(1/GRID_SIZE,0,1/GRID_SIZE,0);
    local grid = {}; for r=1,GRID_SIZE do grid[r]={} end
    for _, nodeInfo in ipairs(puzzle) do
        local num, color, r, c = nodeInfo[1], nodeInfo[2], nodeInfo[3], nodeInfo[4]
        local nodeLabel=Instance.new("TextLabel",classicFrame); nodeLabel.Name="Node_"..r.."_"..c; nodeLabel.Size=UDim2.new(1/GRID_SIZE,0,1/GRID_SIZE,0); nodeLabel.Position=UDim2.new((c-1)/GRID_SIZE,0,(r-1)/GRID_SIZE,0); nodeLabel.Text=tostring(num); nodeLabel.Font=Enum.Font.SourceSansBold; nodeLabel.TextScaled=true; nodeLabel.TextColor3=Color3.new(1,1,1); nodeLabel.BackgroundColor3=BrickColor.new(color).Color; nodeLabel.ZIndex=3
        grid[r][c]={node={label=nodeLabel,r=r,c=c,num=num,color=color,isEndpoint=true}}
    end
    local isDrawing,activePath,activeColor,pairsConnected,pathElements,conns={},false,{},nil,0,{},{}
    local function cleanup() for _,c in ipairs(conns) do c:Disconnect() end end
    local function getCell(pos) if not classicFrame.Visible then return end; local rel=pos-classicFrame.AbsolutePosition;local c=math.floor(rel.X/(classicFrame.AbsoluteSize.X/GRID_SIZE))+1;local r=math.floor(rel.Y/(classicFrame.AbsoluteSize.Y/GRID_SIZE))+1;if r>0 and r<=GRID_SIZE and c>0 and c<=GRID_SIZE then return r,c end end
    conns[1]=UserInputService.InputBegan:Connect(function(input,gp) if gp or not isGameActive or not classicFrame.Visible or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end;local r,c=getCell(input.Position);if r and grid[r][c] and grid[r][c].node and grid[r][c].node.isEndpoint and not grid[r][c].path then isDrawing=true;activeColor=grid[r][c].node.color;table.insert(activePath,{r,c}) end end)
    conns[2]=UserInputService.InputChanged:Connect(function(input,gp) if gp or not isDrawing then return end;local r,c=getCell(input.Position);if r then local lastPos=activePath[#activePath];if lastPos and (r~=lastPos[1] or c~=lastPos[2]) and (math.abs(r-lastPos[1])+math.abs(c-lastPos[2])==1) then if not grid[r][c] then table.insert(activePath,{r,c});local p=Instance.new("Frame",classicFrame);p.Size=UDim2.new(1/GRID_SIZE,0,1/GRID_SIZE,0);p.Position=UDim2.new((c-1)/GRID_SIZE,0,(r-1)/GRID_SIZE,0);p.BackgroundColor3=BrickColor.new(activeColor).Color;p.ZIndex=2;table.insert(pathElements,p)elseif #activePath>1 and r==activePath[#activePath-1][1] and c==activePath[#activePath-1][2] then table.remove(activePath);local p=table.remove(pathElements);if p then p:Destroy() end end end end end)
    conns[3]=UserInputService.InputEnded:Connect(function(input,gp)
        if gp or not isDrawing or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local r,c=getCell(input.Position);local success=false
        if r and grid[r][c] and grid[r][c].node and grid[r][c].node.isEndpoint then
            local startNode=grid[activePath[1][1]][activePath[1][2]].node;local endNode=grid[r][c].node
            if startNode~=endNode and startNode.color==endNode.color then
                for _,pos in ipairs(activePath) do grid[pos[1]][pos[2]]={path=activeColor} end
                for _,el in ipairs(pathElements) do el.Name="Path" end; pairsConnected+=1; success=true
                if pairsConnected==6 then classicStatus.Text="Mission Completed!";classicResultEvent:FireServer(currentMachine,true);cleanup() end
            end
        end
        if not success then for _,p in ipairs(pathElements) do p:Destroy() end end
        isDrawing=false;activePath={};activeColor=nil;pathElements={}
    end)
end

local function closeAllGames()
    if not isGameActive then return end
    skillCheckFrame.Visible=false; memoryFrame.Visible=false; classicFrame.Visible=false; isGameActive=false
end

startSkillCheckEvent.OnClientEvent:Connect(runSkillCheck)
startMemoryEvent.OnClientEvent:Connect(runMemoryGame)
startClassicEvent.OnClientEvent:Connect(runClassicGame)
cancelEvent.OnClientEvent:Connect(closeAllGames)
miniGameCompleteEvent.OnClientEvent:Connect(function() print("Client received MiniGameComplete signal."); closeAllGames() end)

print("MachineUIController initialized for all machine types.")
