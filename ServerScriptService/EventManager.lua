--!strict
--[=[
	@class EventManager
	Manages and creates global RemoteEvents for server-client communication.
]=]
local EventManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create a folder to hold all game events
local eventsFolder = Instance.new("Folder")
eventsFolder.Name = "GameEvents"
eventsFolder.Parent = ReplicatedStorage

-- Create specific events
EventManager.PlaySoundEvent = Instance.new("RemoteEvent")
EventManager.PlaySoundEvent.Name = "PlaySoundEvent"
EventManager.PlaySoundEvent.Parent = eventsFolder

EventManager.UseAbilityEvent = Instance.new("RemoteEvent")
EventManager.UseAbilityEvent.Name = "UseAbilityEvent"
EventManager.UseAbilityEvent.Parent = eventsFolder

EventManager.PlayVFXEvent = Instance.new("RemoteEvent")
EventManager.PlayVFXEvent.Name = "PlayVFXEvent"
EventManager.PlayVFXEvent.Parent = eventsFolder

EventManager.ShowMachineUI = Instance.new("RemoteEvent")
EventManager.ShowMachineUI.Name = "ShowMachineUI"
EventManager.ShowMachineUI.Parent = eventsFolder

EventManager.SubmitClassicMachineSolution = Instance.new("RemoteEvent")
EventManager.SubmitClassicMachineSolution.Name = "SubmitClassicMachineSolution"
EventManager.SubmitClassicMachineSolution.Parent = eventsFolder

EventManager.SubmitMemoryMachineSolution = Instance.new("RemoteEvent")
EventManager.SubmitMemoryMachineSolution.Name = "SubmitMemoryMachineSolution"
EventManager.SubmitMemoryMachineSolution.Parent = eventsFolder

EventManager.ShowMemoryMachinePattern = Instance.new("RemoteEvent")
EventManager.ShowMemoryMachinePattern.Name = "ShowMemoryMachinePattern"
EventManager.ShowMemoryMachinePattern.Parent = eventsFolder

EventManager.StartSkillCheck = Instance.new("RemoteEvent")
EventManager.StartSkillCheck.Name = "StartSkillCheck"
EventManager.StartSkillCheck.Parent = eventsFolder

EventManager.ReportSkillCheckResult = Instance.new("RemoteEvent")
EventManager.ReportSkillCheckResult.Name = "ReportSkillCheckResult"
EventManager.ReportSkillCheckResult.Parent = eventsFolder

EventManager.ReportStunnerHit = Instance.new("RemoteEvent")
EventManager.ReportStunnerHit.Name = "ReportStunnerHit"
EventManager.ReportStunnerHit.Parent = eventsFolder

EventManager.PlayerAttackEvent = Instance.new("RemoteEvent")
EventManager.PlayerAttackEvent.Name = "PlayerAttackEvent"
EventManager.PlayerAttackEvent.Parent = eventsFolder

EventManager.RequestCurrency = Instance.new("RemoteEvent")
EventManager.RequestCurrency.Name = "RequestCurrency"
EventManager.RequestCurrency.Parent = eventsFolder

EventManager.UpdateCurrencyDisplay = Instance.new("RemoteEvent")
EventManager.UpdateCurrencyDisplay.Name = "UpdateCurrencyDisplay"
EventManager.UpdateCurrencyDisplay.Parent = eventsFolder

-- Killer Gameplay Events
EventManager.PickupRequestEvent = Instance.new("RemoteEvent")
EventManager.PickupRequestEvent.Name = "PickupRequestEvent"
EventManager.PickupRequestEvent.Parent = eventsFolder

EventManager.HookRequestEvent = Instance.new("RemoteEvent")
EventManager.HookRequestEvent.Name = "HookRequestEvent"
EventManager.HookRequestEvent.Parent = eventsFolder

EventManager.DropRequestEvent = Instance.new("RemoteEvent")
EventManager.DropRequestEvent.Name = "DropRequestEvent"
EventManager.DropRequestEvent.Parent = eventsFolder

EventManager.PlayerStateChangedEvent = Instance.new("RemoteEvent")
EventManager.PlayerStateChangedEvent.Name = "PlayerStateChangedEvent"
EventManager.PlayerStateChangedEvent.Parent = eventsFolder

-- Survivor Interaction Events
EventManager.UnhookRequestEvent = Instance.new("RemoteEvent")
EventManager.UnhookRequestEvent.Name = "UnhookRequestEvent"
EventManager.UnhookRequestEvent.Parent = eventsFolder

EventManager.RequestOpenGateEvent = Instance.new("RemoteEvent")
EventManager.RequestOpenGateEvent.Name = "RequestOpenGateEvent"
EventManager.RequestOpenGateEvent.Parent = eventsFolder

	EventManager.UseItemEvent = Instance.new("RemoteEvent")
	EventManager.UseItemEvent.Name = "UseItemEvent"
	EventManager.UseItemEvent.Parent = eventsFolder

-- Endgame Events
EventManager.GatePoweredEvent = Instance.new("RemoteEvent")
EventManager.GatePoweredEvent.Name = "GatePoweredEvent"
EventManager.GatePoweredEvent.Parent = eventsFolder

EventManager.SurvivorEscapedRequestEvent = Instance.new("RemoteEvent")
EventManager.SurvivorEscapedRequestEvent.Name = "SurvivorEscapedRequestEvent"
EventManager.SurvivorEscapedRequestEvent.Parent = eventsFolder

EventManager.RequestOpenHatchEvent = Instance.new("RemoteEvent")
EventManager.RequestOpenHatchEvent.Name = "RequestOpenHatchEvent"
EventManager.RequestOpenHatchEvent.Parent = eventsFolder

-- This function is just to ensure the module is loaded and the events are created.
function EventManager:Init()
	print("EventManager initialized and events created.")
end

return EventManager
