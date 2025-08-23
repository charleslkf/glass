-- ServerScriptService/MachineManager.server.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local GameStateManager = require(ServerScriptService:WaitForChild("GameStateManager"))
local RoundManager = require(ServerScriptService:WaitForChild("RoundManager"))

-- Events
local startSkillCheckEvent = ReplicatedStorage:WaitForChild("StartSkillCheckMiniGame")
local skillCheckResultEvent = ReplicatedStorage:WaitForChild("SkillCheckResult")
local startMemoryEvent = ReplicatedStorage:WaitForChild("StartMemoryMiniGame")
local memoryResultEvent = ReplicatedStorage:WaitForChild("MemoryResult")
local cancelEvent = ReplicatedStorage:WaitForChild("CancelMiniGame")
local miniGameCompleteEvent = ReplicatedStorage:WaitForChild("MiniGameComplete")

local MACHINE_POSITIONS = { Vector3.new(0,3,20), Vector3.new(20,3,0), Vector3.new(0,3,-20), Vector3.new(-20,3,0), Vector3.new(15,3,15), Vector3.new(-15,3,-15) }
local COOLDOWN_DURATION = 25
local SKILL_CHECKS_NEEDED = 6
local MEMORY_GAMES_NEEDED = 6
local MAX_INTERACTION_DISTANCE = 20

-- State tracking tables
local machineProgress = {}
local activePlayers = {} -- [player] = machineInstance

local function triggerNewMemoryGame(player, machine, progress)
    local gridSize = 3; local patternLength = 5
    local pattern = {}; for i = 1, patternLength do table.insert(pattern, math.random(1, gridSize * gridSize)) end
    startMemoryEvent:FireClient(player, machine, gridSize, pattern, progress, MEMORY_GAMES_NEEDED)
end

local function resetPlayerProgress(player)
    if not player or not activePlayers[player] then
        print("DEBUG: resetPlayerProgress called for player " .. tostring(player) .. " but they were not in activePlayers.")
        return
    end

    local machine = activePlayers[player]
    if machine and machineProgress[machine] and machineProgress[machine][player] then
        machineProgress[machine][player] = 0
    end

    if player then
        activePlayers[player] = nil
        print("SUCCESS: Player " .. player.Name .. " has been reset and can now use other machines.")
    end
end

local function completeMachine(machine, player)
    miniGameCompleteEvent:FireClient(player)
    task.wait(1.5)
    RoundManager:AddTime(5)
    machine.ProximityPrompt.Enabled = false; machine.BrickColor = BrickColor.new("Lime green"); task.wait(COOLDOWN_DURATION); machine.ProximityPrompt.Enabled = true; machine.BrickColor = BrickColor.new("Medium stone grey")
end

local function createMachine(position, machineType)
    local machine = Instance.new("Part"); machine.Size = Vector3.new(5, 6, 3); machine.Position = position; machine.Anchored = true; machine.BrickColor = BrickColor.new("Medium stone grey"); machine.Material = Enum.Material.Metal; machine.Name = "Machine"; machine:SetAttribute("Type", machineType); machine.Parent = Workspace
    machineProgress[machine] = {}
    local prompt = Instance.new("ProximityPrompt"); prompt.ActionText = "Repair Machine"; prompt.ObjectText = "Machine (" .. machineType .. ")"; prompt.HoldDuration = 0; prompt.Enabled = true; prompt.RequiresLineOfSight = false; prompt.Parent = machine

    prompt.Triggered:Connect(function(player)
        if activePlayers[player] then return end
        activePlayers[player] = machine

        -- Manually reset progress for this player at this machine, don't call resetPlayerProgress here
        if not machineProgress[machine] then machineProgress[machine] = {} end
        machineProgress[machine][player] = 0

        local mType = machine:GetAttribute("Type")
        if mType == "SkillCheck" then
            startSkillCheckEvent:FireClient(player, machine, 0, SKILL_CHECKS_NEEDED)
        elseif mType == "Memory" then
            triggerNewMemoryGame(player, machine, 0)
        end
    end)
end

-- Event Listeners
skillCheckResultEvent.OnServerEvent:Connect(function(player, machine, wasSuccessful)
    if activePlayers[player] ~= machine then return end
    if not machineProgress[machine][player] then machineProgress[machine][player] = 0 end
    if wasSuccessful then
        machineProgress[machine][player] += 1
        local currentProgress = machineProgress[machine][player]
        if currentProgress >= SKILL_CHECKS_NEEDED then
            completeMachine(machine, player); resetPlayerProgress(player)
        else
            task.wait(0.5); startSkillCheckEvent:FireClient(player, machine, currentProgress, SKILL_CHECKS_NEEDED)
        end
    else
        task.wait(0.5); startSkillCheckEvent:FireClient(player, machine, machineProgress[machine][player], SKILL_CHECKS_NEEDED)
    end
end)

memoryResultEvent.OnServerEvent:Connect(function(player, machine, wasSuccessful)
    if activePlayers[player] ~= machine then return end
    if not machineProgress[machine][player] then machineProgress[machine][player] = 0 end
    if wasSuccessful then
        machineProgress[machine][player] += 1
        local currentProgress = machineProgress[machine][player]
        if currentProgress >= MEMORY_GAMES_NEEDED then
            completeMachine(machine, player); resetPlayerProgress(player)
        else
            task.wait(0.5); triggerNewMemoryGame(player, machine, currentProgress)
        end
    else
        task.wait(0.5); triggerNewMemoryGame(player, machine, machineProgress[machine][player])
    end
end)

cancelEvent.OnServerEvent:Connect(function(player, machine)
    -- This event is fired by the client if they walk away.
    if activePlayers[player] == machine then
        print("Server received cancel event for player " .. player.Name .. ". Resetting progress.")
        resetPlayerProgress(player)
    end
end)

-- Initialize machines
local machineTypes = {"SkillCheck", "Memory"}
for _, pos in ipairs(MACHINE_POSITIONS) do createMachine(pos, machineTypes[math.random(1,#machineTypes)]) end
print("MachineManager initialized, now with fewer machine types.")

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

-- Start the main game loop
task.spawn(function()
    RoundManager:Start()
end)
