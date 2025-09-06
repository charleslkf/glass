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
