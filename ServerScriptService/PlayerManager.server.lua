-- ServerScriptService/PlayerManager.server.lua

local Players = game:GetService("Players")

local SURVIVOR_HEALTH = 200
local KILLER_HEALTH = 2500

local function setupPlayer(player)
    -- Called when a player joins the game

    local function onCharacterAdded(character)
        -- Called when the player's character spawns
        local humanoid = character:WaitForChild("Humanoid")

        -- Check the player's role and set health accordingly
        local role = player:GetAttribute("Role")
        if role == "Killer" then
            humanoid.MaxHealth = KILLER_HEALTH
            humanoid.Health = KILLER_HEALTH
        else -- Survivor, Stunner, Helper, or nil all get survivor health
            humanoid.MaxHealth = SURVIVOR_HEALTH
            humanoid.Health = SURVIVOR_HEALTH
        end
    end

    -- Connect the function to the CharacterAdded event
    player.CharacterAdded:Connect(onCharacterAdded)

    -- Also handle the case where the character already exists when this script runs
    if player.Character then
        onCharacterAdded(player.Character)
    end

    -- Listen for role changes
    player:GetAttributeChangedSignal("Role"):Connect(function()
        local character = player.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local newRole = player:GetAttribute("Role")
        if newRole == "Killer" then
            humanoid.MaxHealth = KILLER_HEALTH
            humanoid.Health = KILLER_HEALTH
            print(player.Name .. "'s health set to " .. KILLER_HEALTH .. " (Killer)")
        else -- Survivor, Stunner, Helper, or nil
            humanoid.MaxHealth = SURVIVOR_HEALTH
            humanoid.Health = SURVIVOR_HEALTH
            if newRole then
                print(player.Name .. "'s health set to " .. SURVIVOR_HEALTH .. " (" .. newRole .. ")")
            end
        end
    end)
end

-- Connect the setup function for each player who joins
Players.PlayerAdded:Connect(setupPlayer)

-- Also set up any players who are already in the game when the script runs
for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end
