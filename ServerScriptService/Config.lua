--[=[
	@module Config
	A module to hold global configuration settings for the game.
]=]
local Config = {
	-- Set to true to allow the game to start with only 1 player for easy testing in Studio.
	-- Set to false for production or multiplayer testing.
	SOLO_TEST_MODE = true,
}

return Config
