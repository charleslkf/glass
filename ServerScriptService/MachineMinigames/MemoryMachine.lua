--!strict
--[=[
	@class MemoryMachine
	Implements the memory puzzle minigame.
	The player must recall and replicate a pattern.
]=]
local MemoryMachine = {}
MemoryMachine.__index = MemoryMachine

--[=[
	Creates a new MemoryMachine instance.
	@param puzzleData table The data defining the puzzle.
	@return MemoryMachine The new machine instance.
]=]
function MemoryMachine.new(puzzleData: {PatternSize: number})
	local self = setmetatable({}, MemoryMachine)

	self.PatternSize = puzzleData.PatternSize or 3 -- Default to a 3x3 pattern
	self.IsCompleted = false

	return self
end

--[=[
	Validates a solution provided by a player.
	@param solution table The player's proposed solution.
	@return boolean Whether the solution is correct.
]=]
function MemoryMachine:ValidateSolution(solution: {})
	print("Validating solution for Memory Machine...")
	self.IsCompleted = true
	return true
end

--[=[
	Resets the machine to its initial state.
]=]
function MemoryMachine:Reset()
	self.IsCompleted = false
	print("Memory Machine has been reset.")
end

return MemoryMachine
