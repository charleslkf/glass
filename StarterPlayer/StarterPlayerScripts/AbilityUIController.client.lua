--!strict
--[=[
	@client
	@class AbilityUIController
	This client-side script handles the input to use abilities.
]=]
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local UseAbilityEvent = GameEvents:WaitForChild("UseAbilityEvent")
local ReportStunnerHit = GameEvents:WaitForChild("ReportStunnerHit")

local PlayerRoles = ReplicatedStorage:WaitForChild("PlayerRoles") -- Assuming roles are replicated for client checks

print("AbilityUIController loaded for player.")

local STUN_PROJECTILE_SPEED = 100
local STUN_PROJECTILE_LIFETIME = 2 -- seconds

local function fireStunProjectile()
	local character = LocalPlayer.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Create the projectile part
	local projectile = Instance.new("Part")
	projectile.Size = Vector3.new(1, 1, 2)
	projectile.Color = Color3.new(1, 1, 0) -- Yellow
	projectile.Material = Enum.Material.Neon
	projectile.CanCollide = false
	projectile.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3) -- Spawn in front
	projectile.Velocity = humanoidRootPart.CFrame.LookVector * STUN_PROJECTILE_SPEED
	projectile.Parent = workspace

	-- Add to Debris service to auto-delete after lifetime
	Debris:AddItem(projectile, STUN_PROJECTILE_LIFETIME)

	-- Handle hit detection
	projectile.Touched:Connect(function(hit)
		local hitModel = hit:FindFirstAncestorOfClass("Model")
		if hitModel then
			local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
			if hitPlayer and hitPlayer ~= LocalPlayer then
				-- Check if the hit player is the Killer
				if PlayerRoles:GetAttribute(tostring(hitPlayer.UserId)) == "Killer" then
					print("Stunner projectile hit the Killer!")
					ReportStunnerHit:FireServer(hitPlayer)
					projectile:Destroy() -- Destroy on hit
				end
			end
		end
	end)
end


local function onInputBegan(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.Q then
		-- Fire the generic event so the server can handle cooldowns, etc.
		UseAbilityEvent:FireServer()

		-- Also, execute the client-side visual part of the ability
		-- In the future, we would get the player's equipped ability name here
		-- For now, we assume if they have a role that's not killer, they might be stunner
		local myRole = PlayerRoles:GetAttribute(tostring(LocalPlayer.UserId))
		if myRole == "Stunner" then
			print("Player is Stunner, firing projectile.")
			fireStunProjectile()
		end
	end
end

-- Listen for input
UserInputService.InputBegan:Connect(onInputBegan)
