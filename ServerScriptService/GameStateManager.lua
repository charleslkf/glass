--!strict
--[=[
	@class GameStateManager
	Manages the overall state of the game, such as "Lobby", "InRound", or "Intermission".
]=]
local GameStateManager = {}
GameStateManager.__index = GameStateManager

-- The current state of the game
GameStateManager.State = "Lobby"

-- A BindableEvent that fires when the state changes
GameStateManager.StateChanged = Instance.new("BindableEvent")

--[=[
	Sets the new game state and fires the StateChanged event.
	@param state string The new state to set.
]=]
function GameStateManager:SetState(state: string)
	if self.State ~= state then
		self.State = state
		self.StateChanged:Fire(state)
		print("Game state changed to: " .. state)
	end
end

return GameStateManager
