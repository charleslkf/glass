local KillerManager = {}
KillerManager.__index = KillerManager

local ServerScriptService = game:GetService("ServerScriptService")
local EventManager = require(ServerScriptService.EventManager)
local PlayerManager

local carryingInfo = {} -- { [killerPlayer] = survivorPlayer }

function KillerManager:Initialize(playerManager)
    PlayerManager = playerManager
    print("KillerManager Initialized")

    -- For now, we are just setting up the structure.
    -- EventManager.PickupRequestEvent.OnServerEvent:Connect(function(killerPlayer, targetSurvivorPlayer)
    --     self:PickupSurvivor(killerPlayer, targetSurvivorPlayer)
    -- end)
    -- EventManager.HookRequestEvent.OnServerEvent:Connect(function(killerPlayer)
    --     self:HookSurvivor(killerPlayer)
    -- end)
    -- EventManager.DropRequestEvent.OnServerEvent:Connect(function(killerPlayer)
    --     self:DropSurvivor(killerPlayer)
    -- end)
end

function KillerManager:DropSurvivor(killerPlayer)
    if not carryingInfo[killerPlayer] then return end

    local survivorPlayer = carryingInfo[killerPlayer]
    print("Killer " .. killerPlayer.Name .. " is dropping " .. survivorPlayer.Name)

    -- Unweld
    local killerChar = killerPlayer.Character
    if killerChar then
        local weld = killerChar:FindFirstChild("HumanoidRootPart"):FindFirstChild("CarryWeld")
        if weld then weld:Destroy() end
    end

    -- Update states
    PlayerManager:SetPlayerState(killerPlayer, "Healthy") -- Or whatever the default killer state is
    PlayerManager:SetPlayerState(survivorPlayer, "Downed")
    carryingInfo[killerPlayer] = nil
end

function KillerManager:HookSurvivor(killerPlayer)
    if not carryingInfo[killerPlayer] then
        warn(killerPlayer.Name .. " is not carrying anyone.")
        return
    end

    local survivorPlayer = carryingInfo[killerPlayer]
    local killerChar = killerPlayer.Character
    if not killerChar then return end

    -- Find nearest hook
    local killerRoot = killerChar:FindFirstChild("HumanoidRootPart")
    if not killerRoot then return end

    local nearestHook, nearestDist = nil, 10 -- Max hook distance
    for _, hook in ipairs(game:GetService("CollectionService"):GetTagged("Hook")) do
        local dist = (killerRoot.Position - hook.Position).Magnitude
        if dist < nearestDist then
            nearestHook = hook
            nearestDist = dist
        end
    end

    if not nearestHook then
        warn("No hook found in range for " .. killerPlayer.Name)
        return
    end

    print("Hooking " .. survivorPlayer.Name .. " at " .. tostring(nearestHook.Position))

    -- Unweld from killer
    local carryWeld = killerRoot:FindFirstChild("CarryWeld")
    if carryWeld then carryWeld:Destroy() end

    -- Weld to hook
    local survivorRoot = survivorPlayer.Character and survivorPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not survivorRoot then return end

    survivorRoot.CFrame = nearestHook.CFrame * CFrame.new(0, -2.5, 0)
    local hookWeld = Instance.new("WeldConstraint")
    hookWeld.Part0 = nearestHook
    hookWeld.Part1 = survivorRoot
    hookWeld.Parent = nearestHook
    hookWeld.Name = "HookWeld"

    -- Update states
    PlayerManager:SetPlayerState(killerPlayer, "Healthy")
    PlayerManager:SetPlayerState(survivorPlayer, "Hooked")
    carryingInfo[killerPlayer] = nil
end

function KillerManager:PickupSurvivor(killerPlayer, survivorPlayer)
    -- 1. Validate states
    if PlayerManager:GetRole(killerPlayer) ~= "Killer" then
        warn(killerPlayer.Name .. " is not a Killer.")
        return
    end

    if PlayerManager:GetPlayerState(survivorPlayer) ~= "Downed" then
        warn(survivorPlayer.Name .. " is not downed, cannot pick up.")
        return
    end

    print("Killer " .. killerPlayer.Name .. " is picking up " .. survivorPlayer.Name)

    -- 2. Update states
    PlayerManager:SetPlayerState(killerPlayer, "Carrying")
    PlayerManager:SetPlayerState(survivorPlayer, "Carried")
    carryingInfo[killerPlayer] = survivorPlayer

    -- 3. Weld the characters
    local killerChar = killerPlayer.Character
    local survivorChar = survivorPlayer.Character
    if not (killerChar and survivorChar) then return end

    local killerRoot = killerChar:FindFirstChild("HumanoidRootPart")
    local survivorRoot = survivorChar:FindFirstChild("HumanoidRootPart")
    if not (killerRoot and survivorRoot) then return end

    -- Move survivor to killer
    survivorRoot.CFrame = killerRoot.CFrame * CFrame.new(0, 2, 1)

    -- Create weld
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = killerRoot
    weld.Part1 = survivorRoot
    weld.Parent = killerRoot
    weld.Name = "CarryWeld"

    print("Weld created between " .. killerPlayer.Name .. " and " .. survivorPlayer.Name)
end


return KillerManager
