--!strict
--[=[
    @class ClassicMachine
    Handles the server-side logic for the "Classic" pipe-connecting machine minigame.
]=]
local ClassicMachine = {}
ClassicMachine.__index = ClassicMachine

--[=[
	Creates a new ClassicMachine instance.
	@param puzzleData table The data defining the puzzle (e.g., grid size).
	@return ClassicMachine The new machine instance.
]=]
function ClassicMachine.new(puzzleData: {GridSize: number})
	local self = setmetatable({}, ClassicMachine)

	self.GridSize = puzzleData.GridSize or 5 -- Default to a 5x5 grid
	self.IsCompleted = false

	return self
end

--[=[
	Validates a solution submitted by a player for the classic pipe puzzle.
	@param solution table The player's submitted solution data.
	@return boolean Whether the solution is correct.
]=]
function ClassicMachine:ValidateSolution(solution: table): boolean
    -- For now, we will accept any solution as valid for testing purposes.
    -- In the future, this will contain the actual grid validation logic.
    print("ClassicMachine: Validating solution (currently auto-passing).")
    self.IsCompleted = true
    return true
end

--[=[
	Resets the machine to its initial state.
]=]
function ClassicMachine:Reset()
	self.IsCompleted = false
	print("Classic Machine has been reset.")
end

return ClassicMachine
