local MapBuilder = {}

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local HOOK_POSITIONS = {
	Vector3.new(-20, 5, 20),
	Vector3.new(20, 5, 20),
	Vector3.new(-20, 5, -20),
	Vector3.new(20, 5, -20),
}

function MapBuilder.BuildMap()
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

	for _, pos in ipairs(HOOK_POSITIONS) do
		local hook = Instance.new("Part")
		hook.Size = Vector3.new(2, 10, 2)
		hook.Position = pos
		hook.Anchored = true
		hook.BrickColor = BrickColor.new("Really black")
		hook.Name = "Hook"
		hook.Parent = mapContainer
		CollectionService:AddTag(hook, "Hook")
		print("Created hook at", pos)
	end

	print("Map build complete.")
end

return MapBuilder
