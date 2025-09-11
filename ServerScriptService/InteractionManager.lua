--!strict
--[=[
	@class InteractionManager
	Manages contextual interactions in the game, such as unhooking.
]=]
local InteractionManager = {}
InteractionManager.__index = InteractionManager

local ServerScriptService = game:GetService("ServerScriptService")
local EventManager = require(ServerScriptService.EventManager)
local PlayerManager = require(ServerScriptService.PlayerManager)

local CollectionService = game:GetService("CollectionService")

local INTERACTION_DISTANCE = 10

-- Loot table for chests
local chestLootTable = {
	-- FOR TESTING: All items have 1 charge and equal weight.
	{Name = "Med-Kit", Charges = 1, Weight = 25},
	{Name = "Decoy", Charges = 1, Weight = 25},
	{Name = "Picklock", Charges = 1, Weight = 25},
	{Name = "Key", Charges = 1, Weight = 25},
}

-- Helper function to get a random item from a weighted table
local function getRandomItem(lootTable)
	local totalWeight = 0
	for _, item in ipairs(lootTable) do
		totalWeight = totalWeight + item.Weight
	end
	print("[DEBUG] Total loot weight:", totalWeight)

	local randomNum = math.random(1, totalWeight)
	print("[DEBUG] Random loot number:", randomNum)

	local currentWeight = 0
	for _, item in ipairs(lootTable) do
		currentWeight = currentWeight + item.Weight
		if randomNum <= currentWeight then
			print("[DEBUG] Selected item:", item.Name)
			return item
		end
	end
end

-- A BindableEvent that fires when any survivor escapes
InteractionManager.SurvivorEscaped = Instance.new("BindableEvent")

--[=[
	Initializes the InteractionManager, connecting to interaction events.
]=]
function InteractionManager:Init()
	print("[DEBUG] InteractionManager:Init() called.")
	-- Listen for unhook requests from the client
	EventManager.UnhookRequestEvent.OnServerEvent:Connect(function(player, targetPlayer)
		self:OnUnhookRequest(player, targetPlayer)
	end)
	print("[DEBUG] Connected UnhookRequestEvent.")

	EventManager.RequestOpenGateEvent.OnServerEvent:Connect(function(player, gateName)
		self:OnRequestOpenGate(player, gateName)
	end)
	print("[DEBUG] Connected RequestOpenGateEvent.")

	EventManager.SurvivorEscapedRequestEvent.OnServerEvent:Connect(function(player)
		print("[DEBUG] SurvivorEscapedRequestEvent received on server for player: " .. player.Name)
		self:OnSurvivorEscaped(player)
	end)
	print("[DEBUG] Connected SurvivorEscapedRequestEvent.")

	EventManager.RequestOpenHatchEvent.OnServerEvent:Connect(function(player, hatch)
		self:OnRequestOpenHatch(player, hatch)
	end)
	print("[DEBUG] Connected RequestOpenHatchEvent.")

	print("InteractionManager Initialized")
end

function InteractionManager:OnRequestOpenHatch(player, hatch)
	if not player or not hatch or not player.Character then return end

	-- 1. Validation
	if not hatch:IsA("BasePart") or not hatch:HasTag("Hatch") then
		warn(player.Name .. " tried to open something that isn't a hatch.")
		return
	end

	if hatch:GetAttribute("State") ~= "Visible" then
		warn(player.Name .. " tried to open a hatch that isn't visible or is already open.")
		return
	end

	if PlayerManager:GetItemName(player) ~= "Key" then
		warn(player.Name .. " tried to open the hatch without a Key.")
		return
	end

	local dist = (player.Character.HumanoidRootPart.Position - hatch.Position).Magnitude
	if dist > INTERACTION_DISTANCE then
		warn(player.Name .. " tried to open the hatch from too far away.")
		return
	end

	print(player.Name .. " is using a Key to open the hatch!")
	EventManager.PlaySoundEvent:FireClient(player, "UseKey")

	-- 2. Consume Key and Escape
	PlayerManager:UseItemCharge(player)
	hatch:SetAttribute("State", "Open")
	-- For now, escaping is instant.
	self:OnSurvivorEscaped(player)
end

--[=[
	Handles a request from a player to search a chest.
]=]
function InteractionManager:OnRequestSearchChest(player: Player, chest: BasePart)
	if not player or not chest or not player.Character then return end
	if PlayerManager:HasItem(player) then
		print(player.Name .. " tried to search a chest but already has an item.")
		return
	end

	local dist = (player.Character.HumanoidRootPart.Position - chest.Position).Magnitude
	if dist > INTERACTION_DISTANCE then
		warn(player.Name .. " tried to search a chest from too far away.")
		return
	end

	print(player.Name .. " is searching " .. chest.Name)

	-- Get a random item from the loot table
	local item = getRandomItem(chestLootTable)
	if item then
		PlayerManager:GiveItem(player, item.Name, item.Charges)
	end

	-- Make the chest unusable for a while
	local prompt = chest:FindFirstChildOfClass("ProximityPrompt")
	if prompt then
		prompt.Enabled = false
	end

	chest.BrickColor = BrickColor.new("Black")

	task.delay(30, function()
		chest.BrickColor = BrickColor.new("Brown")
		if prompt then
			prompt.Enabled = true
		end
	end)
end

--[=[
	Handles a request from a player to open an exit gate.
]=]
function InteractionManager:OnRequestOpenGate(player: Player, gateName: string)
	if not player or not gateName or not player.Character then return end

	local gateModel = game:GetService("Workspace"):FindFirstChild(gateName)
	if not gateModel then
		warn(player.Name .. " tried to open a gate that doesn't exist: " .. gateName)
		return
	end

	if gateModel:GetAttribute("State") ~= "Powered" then
		warn(player.Name .. " tried to open a gate that isn't powered or is already open.")
		return
	end

	local dist = (player.Character.HumanoidRootPart.Position - gateModel:GetPrimaryPartCFrame().Position).Magnitude
	if dist > INTERACTION_DISTANCE then
		warn(player.Name .. " tried to open a gate from too far away.")
		return
	end

	print(player.Name .. " is opening " .. gateModel.Name)

	-- For now, the opening is instant.
	local mainPart = gateModel:FindFirstChild("Main") or gateModel:FindFirstChildOfClass("BasePart")
	if mainPart then
		mainPart.Transparency = 0.8
		mainPart.CanCollide = false
	end

	gateModel:SetAttribute("State", "Open")
end

--[=[
	Handles the logic for when a survivor successfully escapes.
]=]
function InteractionManager:OnSurvivorEscaped(player: Player)
	print("[DEBUG] OnSurvivorEscaped called for: " .. tostring(player))
	if not player then
		print("[DEBUG] OnSurvivorEscaped: Player is nil. Aborting.")
		return
	end

	-- Prevent double-escapes
	local playerState = PlayerManager:GetPlayerState(player)
	print("[DEBUG] OnSurvivorEscaped: Current state is " .. tostring(playerState))
	if playerState == "Escaped" then
		print("[DEBUG] OnSurvivorEscaped: Player has already escaped. Aborting.")
		return
	end

	print(player.Name .. " has escaped!")
	PlayerManager:SetPlayerState(player, "Escaped") -- A new state to prevent further interaction

	-- Remove the character from the game
	if player.Character then
		print("[DEBUG] OnSurvivorEscaped: Destroying character for " .. player.Name)
		player.Character:Destroy()
	end

	-- Notify other systems (like RoundManager)
	print("[DEBUG] OnSurvivorEscaped: Firing SurvivorEscaped event.")
	self.SurvivorEscaped:Fire(player)
	print("[DEBUG] OnSurvivorEscaped: Firing PlaySoundEvent.")
	EventManager.PlaySoundEvent:FireAllClients("WinningSound")
	print("[DEBUG] OnSurvivorEscaped: Finished.")
end

--[=[
	Handles a request from a player to unhook another player.
]=]
function InteractionManager:OnUnhookRequest(player: Player, targetPlayer: Player)
	-- 1. Validation
	if not player or not targetPlayer or not player.Character or not targetPlayer.Character then return end
	if PlayerManager:GetPlayerState(targetPlayer) ~= "Hooked" then
		warn(player.Name .. " tried to unhook " .. targetPlayer.Name .. " but they are not hooked.")
		return
	end

	-- Handle self-unhook attempts
	if player == targetPlayer then
		if PlayerManager:GetItemName(player) == "Picklock" then
			print(player.Name .. " is using a Picklock to unhook themselves.")
			EventManager.PlaySoundEvent:FireClient(player, "UsePicklock")
			PlayerManager:UseItemCharge(player)
			-- If they have a picklock, the logic proceeds as normal below.
		else
			-- In the future, this could be a chance-based system.
			-- For now, you can only self-unhook with a picklock.
			warn(player.Name .. " tried to unhook themselves without a Picklock.")
			return
		end
	else -- It's another player unhooking them
		local myState = PlayerManager:GetPlayerState(player)
		if myState == "Hooked" or myState == "Carried" or myState == "Downed" then
			warn(player.Name .. " tried to unhook while in an invalid state: " .. myState)
			return
		end

		local dist = (player.Character.HumanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude
		if dist > INTERACTION_DISTANCE then
			warn(player.Name .. " tried to unhook from too far away.")
			return
		end
	end


	print(player.Name .. " is unhooking " .. targetPlayer.Name)

	-- 2. Find and destroy the weld
	local foundWeld = false
	for _, hookModel in ipairs(CollectionService:GetTagged("Hook")) do
		local hookPart = hookModel:FindFirstChild("HookPart")
		if hookPart then
			local hookWeld = hookPart:FindFirstChild("HookWeld")
			if hookWeld and hookWeld.Part1 == targetPlayer.Character.HumanoidRootPart then
				hookWeld:Destroy()
				foundWeld = true
				break
			end
		end
	end

	if not foundWeld then
		warn("Could not find the HookWeld for " .. targetPlayer.Name)
		-- Still proceed to change state, as the player might have been unhooked by other means
	end

	-- 3. Change player state
	PlayerManager:SetPlayerState(targetPlayer, "Injured")
end


return InteractionManager
