local SkillCheck = {}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Events
local skillCheckResultEvent = ReplicatedStorage:WaitForChild("SkillCheckResult")

-- Module Fields
SkillCheck.Frame = nil
SkillCheck.IsGameActive = false
SkillCheck.CurrentMachine = nil

-- Private Functions
local function closeGame(closeCallback)
    SkillCheck.IsGameActive = false
    SkillCheck.CurrentMachine = nil
    if SkillCheck.Frame then
        SkillCheck.Frame.Visible = false
    end
    if closeCallback then
        closeCallback()
    end
end

-- Public Functions
function SkillCheck.Create(mainFrame, themeManager)
    local frame = Instance.new("Frame", mainFrame)
    frame.Name = "SkillCheckMachineFrame"
    frame.Size = UDim2.new(0.4, 0, 0.2, 0)
    frame.Position = UDim2.new(0.3, 0, 0.4, 0)
    frame.BackgroundColor3 = themeManager.get("Background")
    frame.BorderColor3 = themeManager.get("Border")
    frame.BorderSizePixel = 2
    frame.Visible = false

    local progressLabel = Instance.new("TextLabel", frame)
    progressLabel.Name = "ProgressLabel"
    progressLabel.Size = UDim2.new(1, 0, 0.2, 0)
    progressLabel.Position = UDim2.new(0, 0, 0.8, 0)
    progressLabel.BackgroundColor3 = themeManager.get("Secondary")
    progressLabel.TextColor3 = themeManager.get("Text")
    progressLabel.Font = Enum.Font.SourceSansBold

    local bar = Instance.new("Frame", frame)
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.9, 0, 0.2, 0)
    bar.Position = UDim2.new(0.05, 0, 0.4, 0)
    bar.BackgroundColor3 = themeManager.get("Tertiary")

    local successZone = Instance.new("Frame", bar)
    successZone.Name = "SuccessZone"
    successZone.Size = UDim2.new(0.2, 0, 1, 0)
    successZone.BackgroundColor3 = themeManager.get("SuccessZone")
    successZone.BackgroundTransparency = 0.5

    local handle = Instance.new("Frame", bar)
    handle.Name = "Handle"
    handle.Size = UDim2.new(0.04, 0, 1.4, 0)
    handle.Position = UDim2.new(0, 0, -0.2, 0)
    handle.BackgroundColor3 = themeManager.get("Handle")
    handle.ZIndex = 2

    SkillCheck.Frame = frame
    return frame
end

function SkillCheck.Run(machine, currentProgress, neededProgress, closeCallback, themeManager)
    if not SkillCheck.Frame then return end

    SkillCheck.IsGameActive = true
    SkillCheck.CurrentMachine = machine

    local progressLabel = SkillCheck.Frame:FindFirstChild("ProgressLabel")
    local bar = SkillCheck.Frame:FindFirstChild("Bar")
    local successZone = bar:FindFirstChild("SuccessZone")
    local handle = bar:FindFirstChild("Handle")

    progressLabel.Text = string.format("Progress: %d / %d", currentProgress, neededProgress)
    if currentProgress >= neededProgress then
        progressLabel.Text = "Mission Completed!"
        task.wait(1.5)
        closeGame(closeCallback)
        return
    end

    task.wait(1.5)
    SkillCheck.Frame.Visible = true
    handle.Position = UDim2.new(0, 0, -0.2, 0)
    successZone.Position = UDim2.new(math.random(15, 65) / 100, 0, 0, 0)

    local tween = TweenService:Create(handle, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {Position = UDim2.new(0.96, 0, -0.2, 0)})

    local inputConnection
    inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not SkillCheck.IsGameActive then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
            tween:Pause()
            if inputConnection then inputConnection:Disconnect() end

            local handleCenter = handle.Position.X.Scale + (handle.Size.X.Scale / 2)
            local zoneStart = successZone.Position.X.Scale
            local zoneEnd = zoneStart + successZone.Size.X.Scale
            local wasSuccessful = (handleCenter >= zoneStart and handleCenter <= zoneEnd)

            if wasSuccessful then
                successZone.BackgroundColor3 = themeManager.get("Success")
            else
                bar.BackgroundColor3 = themeManager.get("Failure")
            end

            task.wait(0.5)
            successZone.BackgroundColor3 = themeManager.get("SuccessZone")
            bar.BackgroundColor3 = themeManager.get("Tertiary")

            skillCheckResultEvent:FireServer(SkillCheck.CurrentMachine, wasSuccessful)
        end
    end)

    tween.Completed:Connect(function()
        if inputConnection and inputConnection.Connected then
            inputConnection:Disconnect()
            skillCheckResultEvent:FireServer(SkillCheck.CurrentMachine, false)
        end
    end)

    tween:Play()
end

function SkillCheck.Close()
    closeGame(nil)
end

return SkillCheck
