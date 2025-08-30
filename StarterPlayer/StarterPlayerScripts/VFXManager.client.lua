--!strict
--[=[
	@client
	@class VFXManager
	This client-side module handles creating and managing visual effects (VFX).
]=]
local VFXManager = {}

-- A dictionary to hold our VFX templates
local vfxTemplates = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local PlayVFXEvent = GameEvents:WaitForChild("PlayVFXEvent")

--[=[
	Initializes the VFXManager and pre-loads the effects.
]=]
function VFXManager:Init()
	print("VFXManager initializing...")

	-- In the future, we can populate this from a folder in ReplicatedStorage
	-- For now, we'll define a placeholder effect here.
	local machineCompleteVFX = Instance.new("ParticleEmitter")
	machineCompleteVFX.Name = "MachineCompleteVFX"
	-- Properties for a simple explosion/poof effect
	machineCompleteVFX.Texture = "rbxassetid://267683423" -- Smoke texture
	machineCompleteVFX.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	machineCompleteVFX.LightEmission = 1
	machineCompleteVFX.Size = NumberSequence.new(1, 5)
	machineCompleteVFX.Transparency = NumberSequence.new(0, 1)
	machineCompleteVFX.Lifetime = NumberRange.new(0.5, 1)
	machineCompleteVFX.Rate = 50
	machineCompleteVFX.Speed = NumberRange.new(5, 10)
	machineCompleteVFX.EmissionDirection = Enum.NormalId.Top
	machineCompleteVFX.Shape = Enum.ParticleEmitterShape.Sphere

	vfxTemplates["MachineComplete"] = machineCompleteVFX

	print("VFXManager initialized.")
end

--[=[
	Plays a VFX at a specific position.
	@param vfxName string The name of the effect to play.
	@param position Vector3 The world position to play the effect at.
]=]
function VFXManager:PlayVFX(vfxName: string, position: Vector3)
	local vfxTemplate = vfxTemplates[vfxName]
	if vfxTemplate then
		-- Create a temporary part to host the particle emitter
		local vfxPart = Instance.new("Part")
		vfxPart.Anchored = true
		vfxPart.CanCollide = false
		vfxPart.Transparency = 1
		vfxPart.Position = position
		vfxPart.Parent = workspace

		-- Clone the emitter into the part
		local emitter = vfxTemplate:Clone()
		emitter.Parent = vfxPart

		-- Emit a burst of particles
		emitter:Emit(20)

		-- Clean up the part and emitter after a short delay
		game.Debris:AddItem(vfxPart, 2)

		print("Playing VFX: " .. vfxName .. " at " .. tostring(position))
	else
		warn("Attempted to play unknown VFX: " .. vfxName)
	end
end

-- Initialize the manager when the script runs
VFXManager:Init()

-- Listen for the event from the server
PlayVFXEvent.OnClientEvent:Connect(function(vfxName: string, position: Vector3)
	VFXManager:PlayVFX(vfxName, position)
end)

return VFXManager
