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

	EventManager.RequestSearchChestEvent.OnServerEvent:Connect(function(player, chest)
		self:OnRequestSearchChest(player, chest)
	end)
	print("[DEBUG] Connected RequestSearchChestEvent.")

	print("InteractionManager Initialized")
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
	-- For now, give a Med-Kit instantly with 2 charges.
	PlayerManager:GiveItem(player, "Med-Kit", 2)

	-- Make the chest unusable for a while
	chest.BrickColor = BrickColor.new("Black")
	chest.ProximityPrompt.Enabled = false
	task.delay(30, function()
		chest.BrickColor = BrickColor.new("Brown")
		chest.ProximityPrompt.Enabled = true
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

	print(player.Name .. " is unhooking " .. targetPlayer.Name)

	-- 2. Find and destroy the weld
	local foundWeld = false
	for _, hook in ipairs(CollectionService:GetTagged("Hook")) do
		local hookWeld = hook:FindFirstChild("HookWeld")
		if hookWeld and hookWeld.Part1 == targetPlayer.Character.HumanoidRootPart then
			hookWeld:Destroy()
			foundWeld = true
			break
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
