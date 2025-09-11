--!strict
--[=[
	@client
	@class VFXManager
	This client-side module handles creating and managing visual effects (VFX).
]=]
local VFXManager = {}

-- A dictionary to hold our VFX templates
local vfxParticleTemplates = {}
local vfxDecalTemplates = {}
local vfxAnchor = nil -- The permanent anchor part for our particle effects

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local PlayVFXEvent = GameEvents:WaitForChild("PlayVFXEvent")

--[=[
	Creates the permanent anchor part for hosting particle VFX.
]=]
local function createVFXAnchor()
	local part = Instance.new("Part")
	part.Name = "VFX_Anchor"
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(1, 1, 1)
	part.Parent = workspace
	return part
end

--[=[
	Initializes the VFXManager and pre-loads the effects.
]=]
function VFXManager:Init()
	print("VFXManager initializing...")

	vfxAnchor = createVFXAnchor()

	-- ### PARTICLE EFFECTS ###

	local machineCompleteVFX = Instance.new("ParticleEmitter")
	machineCompleteVFX.Name = "MachineCompleteVFX"
	machineCompleteVFX.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
	machineCompleteVFX.LightEmission = 0.5
	machineCompleteVFX.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 3), NumberSequenceKeypoint.new(1, 1)})
	machineCompleteVFX.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.8, 0.5), NumberSequenceKeypoint.new(1, 1)})
	machineCompleteVFX.Lifetime = NumberRange.new(0.5, 1)
	machineCompleteVFX.Rate = 0
	machineCompleteVFX.Speed = NumberRange.new(5, 10)
	machineCompleteVFX.EmissionDirection = Enum.NormalId.Top
	machineCompleteVFX.Shape = Enum.ParticleEmitterShape.Sphere
	vfxParticleTemplates["MachineComplete"] = machineCompleteVFX

	local helperAbilityVFX = Instance.new("ParticleEmitter")
	helperAbilityVFX.Name = "HelperAbilityVFX"
	helperAbilityVFX.Texture = "rbxassetid://107020857059981"
	helperAbilityVFX.Color = ColorSequence.new(Color3.fromRGB(100, 255, 100))
	helperAbilityVFX.LightEmission = 0.7
	helperAbilityVFX.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 0)})
	helperAbilityVFX.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.2, 0.5), NumberSequenceKeypoint.new(1, 1)})
	helperAbilityVFX.Lifetime = NumberRange.new(0.8)
	helperAbilityVFX.Rate = 0
	helperAbilityVFX.Speed = NumberRange.new(2, 5)
	helperAbilityVFX.EmissionDirection = Enum.NormalId.Top
	helperAbilityVFX.Shape = Enum.ParticleEmitterShape.Cylinder
	vfxParticleTemplates["HelperAbility"] = helperAbilityVFX

	-- ### DECAL EFFECTS ###
	vfxDecalTemplates["DecoyVFX"] = "rbxassetid://117166078"


	print("VFXManager initialized.")
end

--[=[
	Plays a VFX at a specific position.
	@param vfxName string The name of the effect to play.
	@param position Vector3 The world position to play the effect at.
]=]
function VFXManager:PlayVFX(vfxName: string, position: Vector3)
	-- Check for particle effects first
	local particleTemplate = vfxParticleTemplates[vfxName]
	if particleTemplate and vfxAnchor then
		vfxAnchor.Position = position
		local emitter = particleTemplate:Clone()
		emitter.Parent = vfxAnchor
		emitter:Emit(20)
		game.Debris:AddItem(emitter, 2)
		print("Playing Particle VFX: " .. vfxName .. " at " .. tostring(position))
		return
	end

	-- Check for decal effects
	local decalId = vfxDecalTemplates[vfxName]
	if decalId then
		-- Raycast down to find the ground
		local rayOrigin = position + Vector3.new(0, 5, 0)
		local rayDirection = Vector3.new(0, -10, 0)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

		if raycastResult then
			local decalPart = Instance.new("Part")
			decalPart.Anchored = true
			decalPart.CanCollide = false
			decalPart.Transparency = 1
			decalPart.Size = Vector3.new(5, 0.1, 5)
			decalPart.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)

			local decal = Instance.new("Decal")
			decal.Texture = decalId
			decal.Face = Enum.NormalId.Top
			decal.Parent = decalPart

			decalPart.Parent = workspace
			game.Debris:AddItem(decalPart, 10) -- Decal lasts for 10 seconds

			print("Playing Decal VFX: " .. vfxName .. " at " .. tostring(raycastResult.Position))
		else
			warn("Could not place decal VFX, no surface found below: " .. vfxName)
		end
		return
	end

	warn("Attempted to play unknown VFX: " .. vfxName)
end

-- Initialize the manager when the script runs
VFXManager:Init()

-- Listen for the event from the server
PlayVFXEvent.OnClientEvent:Connect(function(vfxName: string, position: Vector3)
	VFXManager:PlayVFX(vfxName, position)
end)

return VFXManager
