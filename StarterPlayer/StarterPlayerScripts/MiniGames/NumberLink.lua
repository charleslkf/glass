local NumberLink = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Events
local numberLinkResultEvent = ReplicatedStorage:WaitForChild("NumberLinkResult")

-- Module Fields
NumberLink.Frame = nil
NumberLink.IsGameActive = false
NumberLink.CurrentMachine = nil
NumberLink.MouseUpConnection = nil
NumberLink.FrameLeaveConnection = nil

-- Private Functions
local function closeGame(closeCallback)
    NumberLink.IsGameActive = false
    NumberLink.CurrentMachine = nil
    if NumberLink.Frame then
        NumberLink.Frame.Visible = false
    end
    if NumberLink.MouseUpConnection then
        NumberLink.MouseUpConnection:Disconnect()
        NumberLink.MouseUpConnection = nil
    end
    if NumberLink.FrameLeaveConnection then
        NumberLink.FrameLeaveConnection:Disconnect()
        NumberLink.FrameLeaveConnection = nil
    end
    if closeCallback then
        closeCallback()
    end
end

-- Public Functions
function NumberLink.Create(mainFrame, themeManager)
    local frame = Instance.new("Frame", mainFrame)
    frame.Name = "NumberLinkFrame"
    frame.Size = UDim2.new(0, 400, 0, 450)
    frame.Position = UDim2.new(0.5, -200, 0.5, -225)
    frame.BackgroundColor3 = themeManager.get("Background")
    frame.BorderSizePixel = 0
    frame.Visible = false

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 9)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Text = "Connect the Pairs"
    title.Font = Enum.Font.SourceSansBold
    title.TextColor3 = themeManager.get("Text")
    title.TextSize = 24
    title.BackgroundColor3 = themeManager.get("Primary")

    local titleCorner = Instance.new("UICorner", title)
    titleCorner.CornerRadius = UDim.new(0, 9)

    local gridFrame = Instance.new("Frame", frame)
    gridFrame.Size = UDim2.new(1, -20, 1, -70)
    gridFrame.Position = UDim2.new(0.5, 0, 0.5, 10)
    gridFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    gridFrame.BackgroundTransparency = 1

    local gridLayout = Instance.new("UIGridLayout", gridFrame)
    gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)

    local progressLabel = Instance.new("TextLabel", frame)
    progressLabel.Name = "ProgressLabel"
    progressLabel.Size = UDim2.new(1, -20, 0, 20)
    progressLabel.Position = UDim2.new(0.5, 0, 1, -15)
    progressLabel.AnchorPoint = Vector2.new(0.5, 1)
    progressLabel.BackgroundTransparency = 1
    progressLabel.Font = Enum.Font.SourceSansBold
    progressLabel.TextColor3 = themeManager.get("Text")
    progressLabel.TextSize = 18
    progressLabel.Text = "Progress: 0 / 6"

    NumberLink.Frame = frame
    return frame
end

function NumberLink.Run(machine, puzzleData, currentProgress, neededProgress, closeCallback, themeManager)
    if not NumberLink.Frame then return end

    NumberLink.IsGameActive = true
    NumberLink.CurrentMachine = machine
    NumberLink.Frame.Visible = true

    local progressLabel = NumberLink.Frame:FindFirstChild("ProgressLabel")
    local gridFrame = NumberLink.Frame:FindFirstChild("Frame")
    local gridLayout = gridFrame:FindFirstChild("UIGridLayout")

    progressLabel.Text = "Connect all 6 pairs!"

    local gridSize = puzzleData[1]
    local endpoints = {}
    local paths = {}
    local cell_buttons = {}
    local completedPairs = 0
    local isDragging = false
    local activeColor = nil
    local currentPath = {}

    for _, child in ipairs(gridFrame:GetChildren()) do
        if not child:IsA("UIGridLayout") then child:Destroy() end
    end
    gridLayout.CellSize = UDim2.new(1 / gridSize, -4, 1 / gridSize, -4)

    local pairColors = themeManager.get("PairColors")
    for i = 2, #puzzleData do
        local pairInfo = puzzleData[i]
        local color = pairColors[i - 1]
        endpoints[pairInfo.start] = { color = color, partner = pairInfo.endPos }
        endpoints[pairInfo.endPos] = { color = color, partner = pairInfo.start }
        paths[color] = {}
    end

    local function checkWinCondition()
        if completedPairs == #pairColors then
            task.wait(0.5)
            numberLinkResultEvent:FireServer(NumberLink.CurrentMachine, true)
        end
    end

    local function clearPath(path, color)
        for _, cellIndex in ipairs(path) do
            if not endpoints[cellIndex] then
                cell_buttons[cellIndex].BackgroundColor3 = themeManager.get("Secondary")
            end
        end
        paths[color] = {}
    end

    local function finalizePath(path, color)
        paths[color] = path
        completedPairs = completedPairs + 1
        progressLabel.Text = string.format("Pairs connected: %d / %d", completedPairs, #pairColors)
        checkWinCondition()
    end

    local function onDragEnd()
        if not isDragging then return end
        local lastCell = currentPath[#currentPath]
        local startCell = currentPath[1]
        if not startCell then
            isDragging = false
            return
        end
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
        local cellButton = Instance.new("TextButton", gridFrame)
        cellButton.Name = tostring(i)
        cellButton.Text = ""
        cellButton.BackgroundColor3 = themeManager.get("Secondary")
        cellButton.BorderSizePixel = 0
        local uiCorner = Instance.new("UICorner", cellButton)
        uiCorner.CornerRadius = UDim.new(0, 4)
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

    NumberLink.MouseUpConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragEnd()
        end
    end)

    NumberLink.FrameLeaveConnection = NumberLink.Frame.MouseLeave:Connect(onDragEnd)
end

function NumberLink.Close()
    closeGame(nil)
end

return NumberLink
