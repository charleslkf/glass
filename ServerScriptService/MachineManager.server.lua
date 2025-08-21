-- ServerScriptService/MachineManager.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local GameStateManager = require(ServerScriptService:WaitForChild("GameStateManager"))

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
local CLASSIC_PUZZLES = { { {1,1,1},{1,3,4}, {2,1,2},{2,4,2}, {3,1,5},{3,4,5}, {4,2,1},{4,5,1}, {5,2,3},{5,5,4}, {6,3,2},{6,6,6} } }
local COOLDOWN_DURATION = 25
local SKILL_CHECKS_NEEDED = 4
local MAX_INTERACTION_DISTANCE = 20 -- Studs

-- State tracking tables
local machineProgress = {}
local memoryGamePatterns = {}
local activePlayers = {} -- [player] = machineInstance

local function resetPlayerProgress(player, machine)
    if machineProgress[machine] and machineProgress[machine][player] then
        machineProgress[machine][player] = 0
    end
    if memoryGamePatterns[machine] then
        -- This implies anyone failing resets the puzzle for everyone. This might need refinement later.
        memoryGamePatterns[machine] = nil
    end
    activePlayers[player] = nil
end

local function completeMachine(machine)
    machineCompletedEvent:Fire()
    machine.ProximityPrompt.Enabled = false
    machine.BrickColor = BrickColor.new("Lime green")
    task.wait(COOLDOWN_DURATION)
    machine.ProximityPrompt.Enabled = true
    machine.BrickColor = BrickColor.new("Medium stone grey")
end

local function createMachine(position, machineType)
    local machine = Instance.new("Part"); machine.Size = Vector3.new(5, 6, 3); machine.Position = position; machine.Anchored = true; machine.BrickColor = BrickColor.new("Medium stone grey"); machine.Material = Enum.Material.Metal; machine.Name = "Machine"; machine:SetAttribute("Type", machineType); machine.Parent = Workspace
    machineProgress[machine] = {}
    local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Repair Machine"; prompt.ObjectText = "Machine (" .. machineType .. ")"; prompt.HoldDuration = 0; prompt.Enabled = true; prompt.Parent = machine

    prompt.Triggered:Connect(function(player)
        if activePlayers[player] then return end -- Player is already busy
        activePlayers[player] = machine

        local mType = machine:GetAttribute("Type")
        if mType == "SkillCheck" then
            startSkillCheckEvent:FireClient(player, machine)
        elseif mType == "Memory" then
            local level = GameStateManager:GetCurrentLevel()
            local gridSize = math.min(3 + math.floor((level-1)/2), 6); local patternLength = gridSize
            local pattern = {}; for i=1,patternLength do table.insert(pattern, math.random(1,gridSize*gridSize)) end
            memoryGamePatterns[machine] = pattern
            startMemoryEvent:FireClient(player, machine, gridSize, pattern)
        elseif mType == "Classic" then
            local puzzle = CLASSIC_PUZZLES[math.random(1, #CLASSIC_PUZZLES)]
            startClassicEvent:FireClient(player, machine, puzzle)
        end
    end)
end

-- Event Listeners
skillCheckResultEvent.OnServerEvent:Connect(function(player, machine, wasSuccessful)
    if activePlayers[player] ~= machine then return end
    if not machineProgress[machine][player] then machineProgress[machine][player] = 0 end
    if wasSuccessful then
        machineProgress[machine][player] += 1
        if machineProgress[machine][player] >= SKILL_CHECKS_NEEDED then
            resetPlayerProgress(player, machine); completeMachine(machine)
        else
            task.wait(0.5); startSkillCheckEvent:FireClient(player, machine)
        end
    else
        machineProgress[machine][player] = math.max(0, machineProgress[machine][player] - 1)
        resetPlayerProgress(player, machine) -- Fail resets the whole attempt
    end
end)

memoryResultEvent.OnServerEvent:Connect(function(player, machine, wasSuccessful)
    if activePlayers[player] ~= machine or not wasSuccessful then return end
    resetPlayerProgress(player, machine); completeMachine(machine)
end)

classicResultEvent.OnServerEvent:Connect(function(player, machine, wasSuccessful)
    if activePlayers[player] ~= machine or not wasSuccessful then return end
    resetPlayerProgress(player, machine); completeMachine(machine)
end)

-- Initialize machines
local machineTypes = {"SkillCheck", "Memory", "Classic"}
for _, pos in ipairs(MACHINE_POSITIONS) do createMachine(pos, machineTypes[math.random(1,#machineTypes)]) end
print("MachineManager initialized for all machine types.")

-- Background loop to check for players walking away
while task.wait(1) do
    for player, machine in pairs(activePlayers) do
        if not player.Parent or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            resetPlayerProgress(player, machine) -- Player left or has no character
        else
            local distance = (player.Character.HumanoidRootPart.Position - machine.Position).Magnitude
            if distance > MAX_INTERACTION_DISTANCE then
                print(player.Name .. " walked away from machine " .. machine.Name .. ". Cancelling.")
                cancelEvent:FireClient(player)
                resetPlayerProgress(player, machine)
            end
        end
    end
end
