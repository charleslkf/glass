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
	@param puzzleData table The data defining the puzzle, like {GridSize = 3, PatternLength = 4}
	@return MemoryMachine The new machine instance.
]=]
function MemoryMachine.new(puzzleData: {GridSize: number, PatternLength: number})
	local self = setmetatable({}, MemoryMachine)

	self.GridSize = puzzleData.GridSize or 3
	self.PatternLength = puzzleData.PatternLength or 4
	self.CurrentPattern = {}
	self.IsCompleted = false

	return self
end

--[=[
	Generates a new random pattern for the minigame.
	The pattern is a sequence of {X, Y} coordinates.
	@return table The generated pattern.
]=]
function MemoryMachine:GeneratePattern()
	local pattern = {}
	for i = 1, self.PatternLength do
		local pos = {
			X = math.random(1, self.GridSize),
			Y = math.random(1, self.GridSize),
		}
		table.insert(pattern, pos)
	end
	self.CurrentPattern = pattern
	return pattern
end


--[=[
	Validates a solution provided by a player against the stored pattern.
	@param solution table The player's proposed solution, a sequence of {X, Y} coordinates.
	@return boolean Whether the solution is correct.
]=]
function MemoryMachine:ValidateSolution(solution: {{X: number, Y: number}})
	if #solution ~= #self.CurrentPattern then
		print("MemoryMachine: Solution length mismatch.")
		return false
	end

	for i, pos in ipairs(self.CurrentPattern) do
		local solutionPos = solution[i]
		if not solutionPos or solutionPos.X ~= pos.X or solutionPos.Y ~= pos.Y then
			print("MemoryMachine: Pattern mismatch at index " .. i)
			return false -- Mismatch found
		end
	end

	print("MemoryMachine: Solution is correct!")
	self.IsCompleted = true
	return true
end

--[=[
	Resets the machine to its initial state.
]=]
function MemoryMachine:Reset()
	self.CurrentPattern = {}
	self.IsCompleted = false
	print("Memory Machine has been reset.")
end

return MemoryMachine
