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
	print("InteractionManager Initialized")
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
