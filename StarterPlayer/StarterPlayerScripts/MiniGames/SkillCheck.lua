-- MiniGames/SkillCheck.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local SkillCheck = {}
SkillCheck.__index = SkillCheck

function SkillCheck.new(mainFrame, resultsEvent)
    local self = setmetatable({}, SkillCheck)

    self.resultsEvent = resultsEvent
    self.isGameActive = false
    self.currentMachine = nil
    self.inputConnection = nil
    self.tween = nil

    -- Create UI
    self.frame = Instance.new("Frame", mainFrame)
    self.frame.Name = "SkillCheckMachineFrame"
    self.frame.Size = UDim2.new(0.4, 0, 0.2, 0)
    self.frame.Position = UDim2.new(0.3, 0, 0.4, 0)
    self.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.frame.BorderColor3 = Color3.fromRGB(200, 200, 200)
    self.frame.BorderSizePixel = 2
    self.frame.Visible = false

    self.progressLabel = Instance.new("TextLabel", self.frame)
    self.progressLabel.Name = "ProgressLabel"
    self.progressLabel.Size = UDim2.new(1, 0, 0.2, 0)
    self.progressLabel.Position = UDim2.new(0, 0, 0.8, 0)
    self.progressLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    self.progressLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.progressLabel.Font = Enum.Font.SourceSansBold

    self.bar = Instance.new("Frame", self.frame)
    self.bar.Name = "Bar"
    self.bar.Size = UDim2.new(0.9, 0, 0.2, 0)
    self.bar.Position = UDim2.new(0.05, 0, 0.4, 0)
    self.bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

    self.successZone = Instance.new("Frame", self.bar)
    self.successZone.Name = "SuccessZone"
    self.successZone.Size = UDim2.new(0.2, 0, 1, 0)
    self.successZone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.successZone.BackgroundTransparency = 0.5

    self.handle = Instance.new("Frame", self.bar)
    self.handle.Name = "Handle"
    self.handle.Size = UDim2.new(0.04, 0, 1.4, 0)
    self.handle.Position = UDim2.new(0, 0, -0.2, 0)
    self.handle.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
    self.handle.ZIndex = 2

    return self
end

function SkillCheck:Run(machine, currentProgress, neededProgress)
    self.isGameActive = true
    self.currentMachine = machine

    self.progressLabel.Text = string.format("Progress: %d / %d", currentProgress, neededProgress)
    if currentProgress >= neededProgress then
        self.progressLabel.Text = "Mission Completed!"
        task.wait(1.5)
        self:Close()
        return
    end

    task.wait(1.5)
    self.frame.Visible = true
    self.handle.Position = UDim2.new(0, 0, -0.2, 0)
    self.successZone.Position = UDim2.new(math.random(15, 65) / 100, 0, 0, 0)

    self.tween = TweenService:Create(self.handle, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {Position = UDim2.new(0.96, 0, -0.2, 0)})

    self.inputConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if gp or not self.isGameActive then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.Space then
            self.tween:Pause()
            if self.inputConnection then self.inputConnection:Disconnect(); self.inputConnection = nil end

            local handleCenter = self.handle.Position.X.Scale + (self.handle.Size.X.Scale / 2)
            local zoneStart = self.successZone.Position.X.Scale
            local zoneEnd = zoneStart + self.successZone.Size.X.Scale
            local wasSuccessful = (handleCenter >= zoneStart and handleCenter <= zoneEnd)

            if wasSuccessful then
                self.successZone.BackgroundColor3 = Color3.fromRGB(100, 255, 100)
            else
                self.bar.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            end

            task.wait(0.5)
            self.successZone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            self.bar.BackgroundColor3 = Color3.fromRGB(80, 80, 80)

            self.resultsEvent:FireServer(self.currentMachine, wasSuccessful)
        end
    end)

    self.tween.Completed:Connect(function()
        if self.inputConnection and self.inputConnection.Connected then
            self.inputConnection:Disconnect()
            self.inputConnection = nil
            self.resultsEvent:FireServer(self.currentMachine, false)
        end
    end)

    self.tween:Play()
end

function SkillCheck:Close()
    if self.tween then self.tween:Cancel(); self.tween = nil end
    if self.inputConnection then self.inputConnection:Disconnect(); self.inputConnection = nil end
    self.isGameActive = false
    self.currentMachine = nil
    self.frame.Visible = false
end

return SkillCheck
