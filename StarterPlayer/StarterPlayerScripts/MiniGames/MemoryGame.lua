-- MiniGames/MemoryGame.lua

local MemoryGame = {}
MemoryGame.__index = MemoryGame

function MemoryGame.new(mainFrame, resultsEvent)
    local self = setmetatable({}, MemoryGame)

    self.resultsEvent = resultsEvent
    self.isGameActive = false
    self.currentMachine = nil
    self.connections = {}
    self.gridButtons = {}

    -- Create UI
    self.frame = Instance.new("Frame", mainFrame)
    self.frame.Name = "MemoryMachineFrame"
    self.frame.Size = UDim2.new(0.4, 0, 0.7, 0)
    self.frame.Position = UDim2.new(0.3, 0, 0.15, 0)
    self.frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.frame.BorderColor3 = Color3.fromRGB(200, 200, 200)
    self.frame.BorderSizePixel = 2
    self.frame.Visible = false

    self.gridLayout = Instance.new("UIGridLayout", self.frame)
    self.gridLayout.Name = "MemoryGridLayout"
    self.gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)

    self.statusLabel = Instance.new("TextLabel", self.frame)
    self.statusLabel.Name = "StatusLabel"
    self.statusLabel.Size = UDim2.new(1, 0, 0.1, 0)
    self.statusLabel.Position = UDim2.new(0, 0, 0.9, 0)
    self.statusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.statusLabel.Font = Enum.Font.SourceSansBold

    return self
end

function MemoryGame:Run(machine, gridSize, pattern, currentProgress, neededProgress)
    self.isGameActive = true
    self.currentMachine = machine
    self:cleanupGrid()

    self.frame.Visible = true
    self.gridLayout.CellSize = UDim2.new(1 / gridSize, -10, 1 / gridSize, -10)
    self.statusLabel.Text = string.format("Progress: %d / %d", currentProgress, neededProgress)

    if currentProgress >= neededProgress then
        self.statusLabel.Text = "Mission Completed!"
        task.wait(1.5)
        self:Close()
        return
    end

    for i = 1, gridSize * gridSize do
        local btn = Instance.new("TextButton", self.frame)
        btn.Name = "GridButton" .. i
        btn.Text = ""
        btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        table.insert(self.gridButtons, btn)
    end

    task.wait(1)

    -- Show pattern
    self.statusLabel.Text = "Watch carefully..."
    for _, tileIndex in ipairs(pattern) do
        local btn = self.gridButtons[tileIndex]
        if btn then
            btn.BackgroundColor3 = Color3.fromRGB(150, 150, 255)
            task.wait(0.6)
            btn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            task.wait(0.2)
        end
    end

    self.statusLabel.Text = string.format("Your turn! (%d/%d)", currentProgress, neededProgress)

    local playerInput = {}
    for i, btn in ipairs(self.gridButtons) do
        self.connections[i] = btn.MouseButton1Click:Connect(function()
            if #playerInput < #pattern then
                btn.BackgroundColor3 = Color3.fromRGB(200, 200, 100)
                table.insert(playerInput, i)

                if #playerInput == #pattern then
                    local success = true
                    for j = 1, #pattern do
                        if playerInput[j] ~= pattern[j] then
                            success = false
                            break
                        end
                    end
                    self:cleanupConnections()
                    self.resultsEvent:FireServer(self.currentMachine, success)
                end
            end
        end)
    end
end

function MemoryGame:cleanupConnections()
    for _, conn in ipairs(self.connections) do
        conn:Disconnect()
    end
    self.connections = {}
end

function MemoryGame:cleanupGrid()
    for _, btn in ipairs(self.gridButtons) do
        btn:Destroy()
    end
    self.gridButtons = {}
end

function MemoryGame:Close()
    self:cleanupConnections()
    self:cleanupGrid()
    self.isGameActive = false
    self.currentMachine = nil
    self.frame.Visible = false
end

return MemoryGame
