local MemoryGame = {}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Events
local memoryResultEvent = ReplicatedStorage:WaitForChild("MemoryResult")

-- Module Fields
MemoryGame.Frame = nil
MemoryGame.IsGameActive = false
MemoryGame.CurrentMachine = nil

-- Private Functions
local function closeGame(closeCallback)
    MemoryGame.IsGameActive = false
    MemoryGame.CurrentMachine = nil
    if MemoryGame.Frame then
        MemoryGame.Frame.Visible = false
    end
    if closeCallback then
        closeCallback()
    end
end

-- Public Functions
function MemoryGame.Create(mainFrame, themeManager)
    local frame = Instance.new("Frame", mainFrame)
    frame.Name = "MemoryMachineFrame"
    frame.Size = UDim2.new(0.4, 0, 0.7, 0)
    frame.Position = UDim2.new(0.3, 0, 0.15, 0)
    frame.BackgroundColor3 = themeManager.get("Primary")
    frame.BorderColor3 = themeManager.get("Border")
    frame.BorderSizePixel = 2
    frame.Visible = false

    local gridLayout = Instance.new("UIGridLayout", frame)
    gridLayout.Name = "MemoryGridLayout"
    gridLayout.CellPadding = UDim2.new(0, 5, 0, 5)

    local statusLabel = Instance.new("TextLabel", frame)
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, 0, 0.1, 0)
    statusLabel.Position = UDim2.new(0, 0, 0.9, 0)
    statusLabel.BackgroundColor3 = themeManager.get("Secondary")
    statusLabel.TextColor3 = themeManager.get("Text")
    statusLabel.Font = Enum.Font.SourceSansBold

    MemoryGame.Frame = frame
    return frame
end

function MemoryGame.Run(machine, gridSize, pattern, currentProgress, neededProgress, closeCallback, themeManager)
    if not MemoryGame.Frame then return end

    MemoryGame.IsGameActive = true
    MemoryGame.CurrentMachine = machine

    local statusLabel = MemoryGame.Frame:FindFirstChild("StatusLabel")
    local gridLayout = MemoryGame.Frame:FindFirstChild("MemoryGridLayout")

    -- Clear old buttons
    for _, child in ipairs(MemoryGame.Frame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    MemoryGame.Frame.Visible = true
    gridLayout.CellSize = UDim2.new(1 / gridSize, -10, 1 / gridSize, -10)
    statusLabel.Text = string.format("Progress: %d / %d", currentProgress, neededProgress)

    if currentProgress >= neededProgress then
        statusLabel.Text = "Mission Completed!"
        task.wait(1.5)
        closeGame(closeCallback)
        return
    end

    local gridButtons = {}
    for i = 1, gridSize * gridSize do
        local btn = Instance.new("TextButton", MemoryGame.Frame)
        btn.Name = "GridButton" .. i
        btn.Text = ""
        btn.BackgroundColor3 = themeManager.get("Tertiary")
        table.insert(gridButtons, btn)
    end

    task.wait(1)
    for _, tileIndex in ipairs(pattern) do
        local btn = gridButtons[tileIndex]
        btn.BackgroundColor3 = themeManager.get("MemoryPattern")
        task.wait(0.6)
        btn.BackgroundColor3 = themeManager.get("Tertiary")
        task.wait(0.2)
    end

    statusLabel.Text = string.format("Your turn! (%d/%d)", currentProgress, neededProgress)

    local playerInput = {}
    local conns = {}
    for i, btn in ipairs(gridButtons) do
        conns[i] = btn.MouseButton1Click:Connect(function()
            if #playerInput < #pattern then
                btn.BackgroundColor3 = themeManager.get("Highlight")
                table.insert(playerInput, i)

                if #playerInput == #pattern then
                    local success = true
                    for j = 1, #pattern do
                        if playerInput[j] ~= pattern[j] then
                            success = false
                            break
                        end
                    end
                    for _, c in ipairs(conns) do
                        c:Disconnect()
                    end
                    memoryResultEvent:FireServer(MemoryGame.CurrentMachine, success)
                end
            end
        end)
    end
end

function MemoryGame.Close()
    closeGame(nil)
end

return MemoryGame
