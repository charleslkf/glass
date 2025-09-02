--!strict
--[=[
	@client
	@class VFXManager
	This client-side module handles creating and managing visual effects (VFX).
]=]
local VFXManager = {}

-- A dictionary to hold our VFX templates
local vfxTemplates = {}
local vfxAnchor = nil -- The permanent anchor part for our effects

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local PlayVFXEvent = GameEvents:WaitForChild("PlayVFXEvent")

--[=[
	Creates the permanent anchor part for hosting VFX.
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

	-- In the future, we can populate this from a folder in ReplicatedStorage
	-- For now, we'll define a placeholder effect here.
	local machineCompleteVFX = Instance.new("ParticleEmitter")
	machineCompleteVFX.Name = "MachineCompleteVFX"
	-- Properties for a simple explosion/poof effect
	-- Leaving out the Texture property as it was causing the effect to not render.
	machineCompleteVFX.Color = ColorSequence.new(Color3.fromRGB(200, 200, 200))
	machineCompleteVFX.LightEmission = 0.5
	machineCompleteVFX.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.5, 3),
		NumberSequenceKeypoint.new(1, 1),
	})
	machineCompleteVFX.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.8, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	machineCompleteVFX.Lifetime = NumberRange.new(0.5, 1)
	machineCompleteVFX.Rate = 0 -- We will emit manually
	machineCompleteVFX.Speed = NumberRange.new(5, 10)
	machineCompleteVFX.EmissionDirection = Enum.NormalId.Top
	machineCompleteVFX.Shape = Enum.ParticleEmitterShape.Sphere
	vfxTemplates["MachineComplete"] = machineCompleteVFX

	-- VFX for Helper Ability
	local helperAbilityVFX = Instance.new("ParticleEmitter")
	helperAbilityVFX.Name = "HelperAbilityVFX"
	helperAbilityVFX.Texture = "rbxassetid://107020857059981"
	helperAbilityVFX.Color = ColorSequence.new(Color3.fromRGB(100, 255, 100)) -- Greenish healing color
	helperAbilityVFX.LightEmission = 0.7
	helperAbilityVFX.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0),
	})
	helperAbilityVFX.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.2, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	helperAbilityVFX.Lifetime = NumberRange.new(0.8)
	helperAbilityVFX.Rate = 0
	helperAbilityVFX.Speed = NumberRange.new(2, 5)
	helperAbilityVFX.EmissionDirection = Enum.NormalId.Top
	helperAbilityVFX.Shape = Enum.ParticleEmitterShape.Cylinder
	helperAbilityVFX.ShapeStyle = Enum.ParticleEmitterShapeStyle.Outwards
	vfxTemplates["HelperAbility"] = helperAbilityVFX

	print("VFXManager initialized.")
end

--[=[
	Plays a VFX at a specific position.
	@param vfxName string The name of the effect to play.
	@param position Vector3 The world position to play the effect at.
]=]
function VFXManager:PlayVFX(vfxName: string, position: Vector3)
	local vfxTemplate = vfxTemplates[vfxName]
	if vfxTemplate and vfxAnchor then
		-- Move the anchor part to the desired position
		vfxAnchor.Position = position

		-- Clone the emitter into the anchor
		local emitter = vfxTemplate:Clone()
		emitter.Parent = vfxAnchor

		-- Emit a burst of particles
		emitter:Emit(20)

		-- Clean up only the emitter after a short delay
		game.Debris:AddItem(emitter, 2)

		print("Playing VFX: " .. vfxName .. " at " .. tostring(position))
	else
		warn("Attempted to play unknown VFX or anchor does not exist: " .. vfxName)
	end
end

-- Initialize the manager when the script runs
VFXManager:Init()

-- Listen for the event from the server
PlayVFXEvent.OnClientEvent:Connect(function(vfxName: string, position: Vector3)
	VFXManager:PlayVFX(vfxName, position)
end)

return VFXManager
