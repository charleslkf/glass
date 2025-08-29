-- MiniGames/NumberLink.lua
local UserInputService = game:GetService("UserInputService")

local NumberLink = {}
NumberLink.__index = NumberLink

function NumberLink.new(mainFrame, resultsEvent)
    local self = setmetatable({}, NumberLink)

    self.resultsEvent = resultsEvent
    self.isGameActive = false
    self.currentMachine = nil

    self.mouseUpConnection = nil
    self.frameLeaveConnection = nil
    self.cell_buttons = {}
    self.paths = {}
    self.endpoints = {}

    -- Create UI
    self.frame = Instance.new("Frame", mainFrame)
    self.frame.Name = "NumberLinkFrame"
    self.frame.Size = UDim2.new(0, 400, 0, 450)
    self.frame.Position = UDim2.new(0.5, -200, 0.5, -225)
    self.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.frame.BorderSizePixel = 0
    self.frame.Visible = false

    local nlCorner = Instance.new("UICorner", self.frame); nlCorner.CornerRadius = UDim.new(0, 8)
    local nlTitle = Instance.new("TextLabel", self.frame); nlTitle.Size = UDim2.new(1, 0, 0, 50); nlTitle.Text = "Connect the Pairs"; nlTitle.Font = Enum.Font.SourceSansBold; nlTitle.TextColor3 = Color3.new(1, 1, 1); nlTitle.TextSize = 24; nlTitle.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    local nlTitleCorner = Instance.new("UICorner", nlTitle); nlTitleCorner.CornerRadius = UDim.new(0, 8)

    self.gridFrame = Instance.new("Frame", self.frame)
    self.gridFrame.Size = UDim2.new(1, -20, 1, -70)
    self.gridFrame.Position = UDim2.new(0.5, 0, 0.5, 10)
    self.gridFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.gridFrame.BackgroundTransparency = 1

    self.gridLayout = Instance.new("UIGridLayout", self.gridFrame)
    self.gridLayout.CellPadding = UDim2.new(0, 4, 0, 4)

    self.progressLabel = Instance.new("TextLabel", self.frame)
    self.progressLabel.Name = "ProgressLabel"
    self.progressLabel.Size = UDim2.new(1, -20, 0, 20)
    self.progressLabel.Position = UDim2.new(0.5, 0, 1, -15)
    self.progressLabel.AnchorPoint = Vector2.new(0.5, 1)
    self.progressLabel.BackgroundTransparency = 1
    self.progressLabel.Font = Enum.Font.SourceSansBold
    self.progressLabel.TextColor3 = Color3.new(1, 1, 1)
    self.progressLabel.TextSize = 18
    self.progressLabel.Text = "Progress: 0 / 6"

    return self
end

function NumberLink:Run(machine, puzzleData, currentProgress, neededProgress)
    self.isGameActive = true
    self.currentMachine = machine
    self:cleanupGrid()

    self.frame.Visible = true
    self.progressLabel.Text = "Connect all 6 pairs!"

    local gridSize = puzzleData[1]
    local isDragging = false
    local activeColor = nil
    local currentPath = {}
    self.completedPairs = 0

    self.gridLayout.CellSize = UDim2.new(1 / gridSize, -4, 1 / gridSize, -4)

    local pairColors = {Color3.fromRGB(255, 87, 87), Color3.fromRGB(87, 255, 87), Color3.fromRGB(87, 87, 255), Color3.fromRGB(255, 255, 87), Color3.fromRGB(255, 87, 255), Color3.fromRGB(87, 255, 255)}
    for i = 2, #puzzleData do
        local pairInfo = puzzleData[i]
        local color = pairColors[i - 1]
        self.endpoints[pairInfo.start] = { color = color, partner = pairInfo.end }
        self.endpoints[pairInfo.end] = { color = color, partner = pairInfo.start }
        self.paths[color] = {}
    end

    local function onDragEnd()
        if not isDragging then
            return
        end
        local lastCell = currentPath[#currentPath]
        local startCell = currentPath[1]
        if not startCell then
            isDragging = false
            return
        end
        local partnerCell = self.endpoints[startCell].partner
        if lastCell == partnerCell then
            self:finalizePath(currentPath, activeColor)
        else
            self:clearPath(currentPath, activeColor)
        end
        isDragging = false
        activeColor = nil
        currentPath = {}
    end

    for i = 1, gridSize * gridSize do
        local cellButton = Instance.new("TextButton", self.gridFrame)
        cellButton.Name = tostring(i)
        cellButton.Text = ""
        cellButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        cellButton.BorderSizePixel = 0
        local uiCorner = Instance.new("UICorner", cellButton); uiCorner.CornerRadius = UDim.new(0, 4)
        self.cell_buttons[i] = cellButton
        if self.endpoints[i] then
            cellButton.BackgroundColor3 = self.endpoints[i].color
        end

        cellButton.MouseButton1Down:Connect(function()
            if self.endpoints[i] then
                isDragging = true
                activeColor = self.endpoints[i].color
                currentPath = {i}
                if #self.paths[activeColor] > 0 then
                    self.completedPairs = self.completedPairs - 1
                    self:clearPath(self.paths[activeColor], activeColor)
                end
            end
        end)

        cellButton.MouseEnter:Connect(function()
            if not isDragging or not activeColor then return end
            if table.find(currentPath, i) then return end
            local isOccupied = false
            for color, path in pairs(self.paths) do
                if color ~= activeColor and table.find(path, i) then
                    isOccupied = true
                    break
                end
            end
            if not isOccupied then
                table.insert(currentPath, i)
                if self.endpoints[i] and self.endpoints[i].color ~= activeColor then
                    onDragEnd()
                else
                    cellButton.BackgroundColor3 = activeColor
                end
            end
        end)
    end

    self.mouseUpConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            onDragEnd()
        end
    end)

    self.frameLeaveConnection = self.frame.MouseLeave:Connect(onDragEnd)
end

function NumberLink:checkWinCondition()
    if self.completedPairs == 6 then -- There are always 6 pairs
        task.wait(0.5)
        self.resultsEvent:FireServer(self.currentMachine, true)
    end
end

function NumberLink:clearPath(path, color)
    for _, cellIndex in ipairs(path) do
        if not self.endpoints[cellIndex] then
            self.cell_buttons[cellIndex].BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
    self.paths[color] = {}
end

function NumberLink:finalizePath(path, color)
    self.paths[color] = path
    self.completedPairs = self.completedPairs + 1
    self.progressLabel.Text = string.format("Pairs connected: %d / 6", self.completedPairs)
    self:checkWinCondition()
end

function NumberLink:cleanupGrid()
    for _, btn in ipairs(self.cell_buttons) do
        btn:Destroy()
    end
    self.cell_buttons = {}
    self.paths = {}
    self.endpoints = {}
end

function NumberLink:Close()
    if self.mouseUpConnection then self.mouseUpConnection:Disconnect(); self.mouseUpConnection = nil end
    if self.frameLeaveConnection then self.frameLeaveConnection:Disconnect(); self.frameLeaveConnection = nil end
    self:cleanupGrid()
    self.isGameActive = false
    self.currentMachine = nil
    self.frame.Visible = false
end

return NumberLink
