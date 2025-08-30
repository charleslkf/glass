--!strict
--[=[
	@class SkillCheckMachine
	Implements the skill-check puzzle minigame.
	The player must hit skill checks in sequence.
]=]
local SkillCheckMachine = {}
SkillCheckMachine.__index = SkillCheckMachine

--[=[
	Creates a new SkillCheckMachine instance.
	@param puzzleData table The data defining the puzzle.
	@return SkillCheckMachine The new machine instance.
]=]
function SkillCheckMachine.new(puzzleData: {CheckCount: number})
	local self = setmetatable({}, SkillCheckMachine)

	self.CheckCount = puzzleData.CheckCount or 5 -- Default to 5 checks
	self.IsCompleted = false

	return self
end

--[=[
	Validates a player's performance.
	Unlike other machines, this might be validated on the client with server trust
	or have progress reported incrementally.
	@param progress number The player's current progress.
	@return boolean Whether the machine is fully completed.
]=]
function SkillCheckMachine:UpdateProgress(progress: number)
	print("Updating progress for Skill Check Machine...")
	if progress >= self.CheckCount then
		self.IsCompleted = true
	end
	return self.IsCompleted
end

--[=[
	Resets the machine to its initial state.
]=]
function SkillCheckMachine:Reset()
	self.IsCompleted = false
	print("Skill Check Machine has been reset.")
end

return SkillCheckMachine
