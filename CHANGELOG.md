# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
