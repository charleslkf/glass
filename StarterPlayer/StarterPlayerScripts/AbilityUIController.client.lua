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

local LocalPlayer = Players.LocalPlayer

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local UseAbilityEvent = GameEvents:WaitForChild("UseAbilityEvent")
local PlayerAttackEvent = GameEvents:WaitForChild("PlayerAttackEvent")

local PlayerRoles = ReplicatedStorage:WaitForChild("PlayerRoles")

print("AbilityUIController loaded for player.")

local STUN_PROJECTILE_SPEED = 100
local STUN_PROJECTILE_LIFETIME = 2

--[=[
	Fires the Sentinel's client-side projectile.
]=]
local function fireStunProjectile()
	local character = LocalPlayer.Character
	if not character then return end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	SoundManager:PlaySound("StunnerAbility")

	local projectile = Instance.new("Part")
	projectile.Size = Vector3.new(1, 1, 2)
	projectile.Color = Color3.new(1, 1, 0)
	projectile.Material = Enum.Material.Neon
	projectile.CanCollide = false
	projectile.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
	projectile.Velocity = humanoidRootPart.CFrame.LookVector * STUN_PROJECTILE_SPEED
	projectile.Parent = workspace

	Debris:AddItem(projectile, STUN_PROJECTILE_LIFETIME)

	local connection
	connection = projectile.Touched:Connect(function(hit)
		local hitModel = hit:FindFirstAncestorOfClass("Model")
		if hitModel then
			local hitPlayer = Players:GetPlayerFromCharacter(hitModel)
			if hitPlayer and hitPlayer ~= LocalPlayer then
				if PlayerRoles:GetAttribute(tostring(hitPlayer.UserId)) == "Killer" then
					print("Sentinel projectile hit the Killer!")
					UseAbilityEvent:FireServer(hitPlayer)

					if connection then
						connection:Disconnect()
					end

					projectile:Destroy()
				end
			end
		end
	end)
end

--[=[
	Handles player input for abilities and attacks.
]=]
local function onInputBegan(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.Q then
		local myRole = PlayerRoles:GetAttribute(tostring(LocalPlayer.UserId))

		if myRole == "Sentinel" then
			print("Player is Sentinel, firing projectile.")
			fireStunProjectile()
		elseif myRole == "Support" then
			UseAbilityEvent:FireServer()
		else
			-- For other roles, maybe do nothing or fire a generic event
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = LocalPlayer:GetMouse()
		local target = mouse.Target

		if not target then return end

		local targetModel = target:FindFirstAncestorOfClass("Model")
		if targetModel then
			local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
			if targetPlayer and targetPlayer ~= LocalPlayer then
				print("Client detected attack on " .. targetPlayer.Name)
				PlayerAttackEvent:FireServer(targetPlayer)
			end
		end
	end
end

UserInputService.InputBegan:Connect(onInputBegan)
