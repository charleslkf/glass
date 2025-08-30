# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.23] - 2025-08-30

### Fixed
- **Rojo Sync Configuration**: Updated `default.project.json` to use a more specific path for `StarterPlayerScripts`. This prevents conflicts with default objects in the user's place file and resolves the Rojo sync failure.

## [1.0.22] - 2025-08-30

### Fixed
- **Client Scripts Not Loading**: Fixed a critical bug where client-side scripts were not being loaded into the game. The `default.project.json` file was updated to include the `StarterPlayer` directory in the Rojo sync, allowing the `ShopUIController` and other future client scripts to run.

## [1.0.21] - 2025-08-30

### Added
- **Shop UI Foundation**: Created the foundational client-side UI for the shop.
  - A new `ShopUIController.client.lua` script in `StarterPlayerScripts` now programmatically creates the shop UI.
  - The UI consists of a main shop frame and a button to toggle its visibility.

## [1.0.20] - 2025-08-30

### Added
- **DataManager and Data Persistence**: Created the foundational `DataManager.lua` module to handle saving and loading player data using `DataStoreService`.
  - The manager saves and loads a player's "Currency" and "Unlocks".
  - It connects to `PlayerAdded` and `PlayerRemoving` events to manage data automatically.
  - Includes error handling (`pcall`) for robust DataStore requests.
- The `DataManager` is now initialized on startup.

## [1.0.19] - 2025-08-30

### Added
- **Ability System Foundation**: Created the foundational framework for a modular character ability system.
  - Created a new `AbilityManager.lua` controller to load and manage abilities.
  - Created a new `ServerScriptService/CharacterAbilities` directory.
  - Added placeholder modules for `DefaultSurvivorAbility` and `DefaultKillerAbility`.
  - Added a placeholder `AbilityUIController.client.lua` script to `StarterPlayerScripts` for future UI work.
- The `AbilityManager` is now initialized on startup.

## [1.0.18] - 2025-08-30

### Added
- **Expanded Player Roles**: The `AssignRoles` function in `PlayerManager` was enhanced to assign new roles. In addition to "Killer" and "Survivor", it now assigns "Stunner" and "Helper" roles if there are enough players in the round.

## [1.0.17] - 2025-08-30

### Removed
- **Debug Code**: Removed the temporary `task.delay` from `RoundManager` that was used to test the killer attack mechanic. The feature is now complete and clean.

## [1.0.16] - 2025-08-30

### Added
- **Killer Attack Mechanic**: Implemented a `KillerAttack(killer, target)` function in `PlayerManager`.
- A debug test was added to `RoundManager` to have a Killer attack a Survivor 5 seconds into the round, allowing for testing of the health and damage system.

## [1.0.15] - 2025-08-30

### Added
- **Health System Foundation**: Implemented the foundational logic for player health in `PlayerManager.lua`.
  - Players are now assigned a default health value when they join.
  - A `TakeDamage(player, amount)` function was added to manage health reduction and player death.
  - Player health data is now cleaned up when they leave the game.
- The `PlayerManager` is now initialized from `Main.server.lua` to ensure its event listeners are active.

## [1.0.14] - 2025-08-30

### Changed
- **Documentation**: Updated `CHANGELOG.md` to include all prior bug fixes and diagnostic versions.

## [1.0.13] - 2025-08-30

### Fixed
- **Invisible Machine Bug**: Fixed a subtle race condition that prevented machine parts from being rendered visibly. The `task.delay` used for debugging was removed from `RoundManager`, and the main round timer was restored, resulting in a stable and visible part creation process.

## [1.0.8] - 2025-08-29

### Added
- **Debug Logging**: Added a `print` statement to `MachineManager` to diagnose an issue with invisible machine parts.

## [1.0.7] - 2025-08-29

### Fixed
- **Game Loop Not Starting**: Fixed a critical bug where the `RoundManager` would not process the initial game state, preventing the game loop from ever starting.

## [1.0.6] - 2025-08-29

### Changed
- **Documentation**: Updated `CHANGELOG.md` to include previously missed entries.

## [1.0.5] - 2025-08-29

### Added
- **Visible Machines**: The `MachineManager` now creates a physical `Part` in the `workspace` for each machine, making the game's objectives visible.
- The `ResetAllMachines` function now also destroys these parts to clean up the workspace between rounds.

## [1.0.4] - 2025-08-29

### Fixed
- **Server Crash on Init**: Fixed a critical bug in `RoundManager.lua` where incorrect syntax (`:Connect` instead of `.Event:Connect`) was used for `BindableEvents`, causing the server scripts to crash on startup.

## [1.0.3] - 2025-08-29

### Added
- **Game Logic Entry Point**: Created `Main.server.lua` to act as the main entry point for the game, which initializes the `RoundManager` and starts the game loop.

### Fixed
- Resolved an issue where the game logic modules were not being loaded or run.

## [1.0.2] - 2025-08-29

### Added
- **Modular Minigame System**: Refactored the machine system into a modular architecture.
- **Classic Machine Minigame**: Implemented the full server-side logic for the "pipe" or "flow" puzzle.
- **Placeholder Minigames**: Added placeholder modules for `MemoryMachine.lua` and `SkillCheckMachine.lua`.
- **Game Loop Integration**: The `RoundManager` now listens for `MachineCompleted` events.

### Changed
- **Project Baseline**: This version represents a complete, clean baseline of the project.
- Updated `Game_Concept_Overview.md` with the detailed rules for the Classic Machine.

## [1.0.1] - 2025-08-29

### Added
- **Initial Project Setup**: Foundational scripts, documentation, and configuration.
- `CHANGELOG.md` file created.
