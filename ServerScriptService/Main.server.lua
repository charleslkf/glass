--[=[
	@script Main.server
	DIAGNOSTIC VERSION: This script is temporarily modified to test the MachineManager in isolation.
]=]

print("[Diagnostic Test v2] Starting...")

local ServerScriptService = game:GetService("ServerScriptService")
local MachineManager = require(ServerScriptService.MachineManager)

-- Initialize only the MachineManager and its dependencies
MachineManager:Init()
print("[Diagnostic Test v2] MachineManager Initialized.")

-- Wait a moment before creating the machine
wait(3)

print("[Diagnostic Test v2] Calling CreateMachine...")
MachineManager:CreateMachine("ClassicMachine", {})

print("[Diagnostic Test v2] Script finished.")
