local MapBuilder = {}

local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local HOOK_POSITIONS = {
	Vector3.new(-20, 5, 20),
	Vector3.new(20, 5, 20),
	Vector3.new(-20, 5, -20),
	Vector3.new(20, 5, -20),
}

local CHEST_POSITIONS = {
	Vector3.new(30, 2.5, 30),
	Vector3.new(-30, 2.5, -30),
	Vector3.new(30, 2.5, -30),
}

function MapBuilder.BuildMap(InteractionManager)
	print("Building map...")

	local mapContainer = Instance.new("Folder")
	mapContainer.Name = "Map"
	mapContainer.Parent = Workspace

	-- Create Gates
	local gatePositions = {
		GateA = Vector3.new(0, 5, 50),
		GateB = Vector3.new(0, 5, -50),
	}
	for gateName, pos in pairs(gatePositions) do
		local gateModel = Instance.new("Model")
		gateModel.Name = gateName
		gateModel.Parent = Workspace

		local mainPart = Instance.new("Part")
		mainPart.Name = "Main"
		mainPart.Size = Vector3.new(15, 12, 2)
		mainPart.Position = pos
		mainPart.Anchored = true
		mainPart.BrickColor = BrickColor.new("Institutional white")
		mainPart.Parent = gateModel

		gateModel.PrimaryPart = mainPart
		print("Created gate: " .. gateName)
	end

	for i, pos in ipairs(HOOK_POSITIONS) do
		local hookModel = Instance.new("Model")
		hookModel.Name = "Hook_" .. i
		hookModel.Parent = mapContainer

		local pole = Instance.new("Part")
		pole.Name = "Pole"
		pole.Size = Vector3.new(1, 10, 1)
		pole.Position = pos
		pole.Anchored = true
		pole.BrickColor = BrickColor.new("Really black")
		pole.Parent = hookModel

		local hookPart = Instance.new("Part")
		hookPart.Name = "HookPart"
		hookPart.Size = Vector3.new(1, 1, 3)
		hookPart.CFrame = pole.CFrame * CFrame.new(0, 3, -1)
		hookPart.Anchored = true
		hookPart.BrickColor = BrickColor.new("Really black")
		hookPart.Parent = hookModel

		local hangPoint = Instance.new("Attachment")
		hangPoint.Name = "HangPoint"
		hangPoint.Position = Vector3.new(0, -1, 1) -- Position relative to hookPart
		hangPoint.Parent = hookPart

		hookModel.PrimaryPart = pole
		CollectionService:AddTag(hookModel, "Hook")

		print("Created hook at", pos)
	end

	for _, pos in ipairs(CHEST_POSITIONS) do
		local chest = Instance.new("Part")
		chest.Size = Vector3.new(4, 3, 2)
		chest.Position = pos
		chest.Anchored = true
		chest.BrickColor = BrickColor.new("Brown")
		chest.Name = "Chest"
		chest.Parent = mapContainer
		CollectionService:AddTag(chest, "Chest")

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Search Chest"
		prompt.ObjectText = "Supply Chest"
		prompt.Parent = chest

		prompt.Triggered:Connect(function(player)
			InteractionManager:OnRequestSearchChest(player, chest)
		end)

		print("Created chest at", pos)
	end

	print("Map build complete.")

	-- Create the hatch
	local function createHatch(position)
		local hatch = Instance.new("Part")
		hatch.Name = "Hatch"
		hatch.Size = Vector3.new(10, 1, 10)
		hatch.Shape = Enum.PartShape.Cylinder
		hatch.Position = position
		hatch.Anchored = true
		hatch.CanCollide = false
		hatch.Transparency = 1
		hatch.Color = Color3.fromRGB(50, 50, 50)
		hatch.Parent = Workspace

		-- Attribute to track state: "Hidden", "Visible", "Open"
		hatch:SetAttribute("State", "Hidden")

		CollectionService:AddTag(hatch, "Hatch")
		print("Created hatch at " .. tostring(position))
	end

	createHatch(Vector3.new(0, 0.1, 0))
end

return MapBuilder
