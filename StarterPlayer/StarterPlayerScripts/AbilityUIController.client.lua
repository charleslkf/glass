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

local SoundManager = require(script.Parent:WaitForChild("SoundManager"))
local VFXManager = require(script.Parent:WaitForChild("VFXManager"))

local LocalPlayer = Players.LocalPlayer

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local UseAbilityEvent = GameEvents:WaitForChild("UseAbilityEvent")
local ReportStunnerHit = GameEvents:WaitForChild("ReportStunnerHit")

local PlayerRoles = ReplicatedStorage:WaitForChild("PlayerRoles")

print("AbilityUIController loaded for player.")

local STUN_PROJECTILE_SPEED = 100
local STUN_PROJECTILE_LIFETIME = 2

--[=[
	Fires the Stunner's client-side projectile.
]=]
local function fireStunProjectile()
	local character = LocalPlayer.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	-- Play the firing sound locally immediately
	SoundManager:PlaySound("StunnerAbility")

	-- Create the projectile part
	local projectile = Instance.new("Part")
	projectile.Size = Vector3.new(1, 1, 2)
	projectile.Color = Color3.new(1, 1, 0)
	projectile.Material = Enum.Material.Neon
	projectile.CanCollide = false
	projectile.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	projectile.Velocity = humanoidRootPart.CFrame.LookVector * STUN_PROJECTILE_SPEED
	projectile.Parent = workspace

	Debris:AddItem(projectile, STUN_PROJECTILE_LIFETIME)

	projectile.Touched:Connect(function(hit)
		local hitModel = hit:FindFirstAncestorOfClass("Model")
		if hitModel then
			local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
			if hitPlayer and hitPlayer ~= LocalPlayer then
				if PlayerRoles:GetAttribute(tostring(hitPlayer.UserId)) == "Killer" then
					print("Stunner projectile hit the Killer!")
					ReportStunnerHit:FireServer(hitPlayer)
					projectile:Destroy()
				end
			end
		end
	end)
end

--[=[
	Handles player input for abilities.
]=]
local function onInputBegan(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.Q then
		UseAbilityEvent:FireServer()

		local myRole = PlayerRoles:GetAttribute(tostring(LocalPlayer.UserId))

		if myRole == "Stunner" then
			print("Player is Stunner, firing projectile.")
			fireStunProjectile()
		end
	end
end

-- Listen for input
UserInputService.InputBegan:Connect(onInputBegan)
