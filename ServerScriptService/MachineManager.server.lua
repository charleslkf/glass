-- ServerScriptService/MachineManager.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Events
local machineCompletedEvent = ReplicatedStorage:WaitForChild("MachineCompletedEvent")
local startSkillCheckEvent = ReplicatedStorage:WaitForChild("StartSkillCheckMiniGame")
local skillCheckResultEvent = ReplicatedStorage:WaitForChild("SkillCheckResult")
local startMemoryEvent = ReplicatedStorage:WaitForChild("StartMemoryMiniGame")
local memoryResultEvent = ReplicatedStorage:WaitForChild("MemoryResult")
local startClassicEvent = ReplicatedStorage:WaitForChild("StartClassicMiniGame")
local classicResultEvent = ReplicatedStorage:WaitForChild("ClassicResult")
local cancelEvent = ReplicatedStorage:WaitForChild("CancelMiniGame")

local MACHINE_POSITIONS = { Vector3.new(0,3,20), Vector3.new(20,3,0), Vector3.new(0,3,-20), Vector3.new(-20,3,0), Vector3.new(15,3,15), Vector3.new(-15,3,-15) }
local CLASSIC_PUZZLES = { { {1,"Bright red",1,1},{1,"Bright red",8,8}, {2,"Bright green",1,3},{2,"Bright green",6,3}, {3,"Bright blue",1,6},{3,"Bright blue",8,6}, {4,"Bright yellow",2,2},{4,"Bright yellow",2,8}, {5,"Dark orange",3,4},{5,"Dark orange",7,4}, {6,"Bright violet",4,2},{6,"Bright violet",4,7} } }
local COOLDOWN_DURATION = 25
local MAX_INTERACTION_DISTANCE = 20

-- State tracking
local activePlayers = {} -- [player] = machineInstance

local function resetPlayerProgress(player)
    if player then activePlayers[player] = nil end
end

local function completeMachine(machine, player)
    machineCompletedEvent:Fire()
    machine.ProximityPrompt.Enabled = false; machine.BrickColor = BrickColor.new("Lime green"); task.wait(COOLDOWN_DURATION); machine.ProximityPrompt.Enabled = true; machine.BrickColor = BrickColor.new("Medium stone grey")
end

local function createMachine(position, machineType)
    local machine = Instance.new("Part"); machine.Size = Vector3.new(5, 6, 3); machine.Position = position; machine.Anchored = true; machine.BrickColor = BrickColor.new("Medium stone grey"); machine.Material = Enum.Material.Metal; machine.Name = "Machine"; machine:SetAttribute("Type", machineType); machine.Parent = Workspace
    local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Repair Machine"; prompt.ObjectText = "Machine (" .. machineType .. ")"; prompt.HoldDuration = 0; prompt.Enabled = true; prompt.RequiresLineOfSight = false; prompt.Parent = machine

    prompt.Triggered:Connect(function(player)
        if activePlayers[player] then return end
        activePlayers[player] = machine

        local mType = machine:GetAttribute("Type")
        if mType == "SkillCheck" then
            startSkillCheckEvent:FireClient(player, machine)
        elseif mType == "Memory" then
            startMemoryEvent:FireClient(player, machine)
        elseif mType == "Classic" then
            local puzzle = CLASSIC_PUZZLES[math.random(1, #CLASSIC_PUZZLES)]
            startClassicEvent:FireClient(player, machine, puzzle)
        end
    end)
end

-- Event Listeners (now much simpler)
local function onResult(player, machine, wasSuccessful)
    if activePlayers[player] ~= machine then return end
    if wasSuccessful then
        completeMachine(machine, player)
    end
    resetPlayerProgress(player)
end

skillCheckResultEvent.OnServerEvent:Connect(onResult)
memoryResultEvent.OnServerEvent:Connect(onResult)
classicResultEvent.OnServerEvent:Connect(onResult)

-- Initialize machines
local machineTypes = {"SkillCheck", "Memory", "Classic"}
for _, pos in ipairs(MACHINE_POSITIONS) do createMachine(pos, machineTypes[math.random(1,#machineTypes)]) end
print("MachineManager initialized for all machine types.")

-- Background loop
while task.wait(1) do
    for player, machine in pairs(activePlayers) do
        if not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            resetPlayerProgress(player)
        else
            if (player.Character.HumanoidRootPart.Position - machine.Position).Magnitude > MAX_INTERACTION_DISTANCE then
                cancelEvent:FireClient(player); resetPlayerProgress(player)
            end
        end
    end
end
