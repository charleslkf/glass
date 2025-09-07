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

--[=[
	Initializes the InteractionManager, connecting to interaction events.
]=]
function InteractionManager:Init()
	-- Listen for unhook requests from the client
	EventManager.UnhookRequestEvent.OnServerEvent:Connect(function(player, targetPlayer)
		self:OnUnhookRequest(player, targetPlayer)
	end)

	EventManager.RequestOpenGateEvent.OnServerEvent:Connect(function(player, gateModel)
		self:OnRequestOpenGate(player, gateModel)
	end)

	print("InteractionManager Initialized")
end

--[=[
-- A BindableEvent that fires when any survivor escapes
InteractionManager.SurvivorEscaped = Instance.new("BindableEvent")

--[=[
	Handles a request from a player to open an exit gate.
]=]
function InteractionManager:OnRequestOpenGate(player: Player, gateModel: Model)
	if not player or not gateModel or not player.Character then return end
	if not CollectionService:HasTag(gateModel, "PoweredGate") then
		warn(player.Name .. " tried to open a gate that isn't powered.")
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

		-- Create the escape trigger zone
		local escapeZone = Instance.new("Part")
		escapeZone.Name = "EscapeZone"
		escapeZone.Size = mainPart.Size
		escapeZone.CFrame = mainPart.CFrame
		escapeZone.Anchored = true
		escapeZone.CanCollide = false
		escapeZone.Transparency = 1
		escapeZone.Parent = gateModel

		escapeZone.Touched:Connect(function(otherPart)
			local model = otherPart:FindFirstAncestorOfClass("Model")
			if model then
				local touchedPlayer = game:GetService("Players"):GetPlayerFromCharacter(model)
				if touchedPlayer and PlayerManager:GetRole(touchedPlayer) ~= "Killer" then
					self:OnSurvivorEscaped(touchedPlayer)
				end
			end
		end)
	end

	CollectionService:RemoveTag(gateModel, "PoweredGate")
	CollectionService:AddTag(gateModel, "OpenGate")
end

--[=[
	Handles the logic for when a survivor successfully escapes.
]=]
function InteractionManager:OnSurvivorEscaped(player: Player)
	if not player then return end

	-- Prevent double-escapes
	local playerState = PlayerManager:GetPlayerState(player)
	if playerState == "Escaped" then return end

	print(player.Name .. " has escaped!")
	PlayerManager:SetPlayerState(player, "Escaped") -- A new state to prevent further interaction

	-- Remove the character from the game
	if player.Character then
		player.Character:Destroy()
	end

	-- Notify other systems (like RoundManager)
	self.SurvivorEscaped:Fire(player)
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
