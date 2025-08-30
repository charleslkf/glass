# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2025-08-29

### Added
- **Modular Minigame System**: Refactored the machine system into a modular architecture.
  - Created a new directory `ServerScriptService/MachineMinigames` to house individual minigame logic.
  - `MachineManager.lua` now acts as a controller that loads and manages these modules.
- **Classic Machine Minigame**: Implemented the full server-side logic for the "pipe" or "flow" puzzle as described in the Game Concept Overview.
- **Placeholder Minigames**: Added placeholder modules for `MemoryMachine.lua` and `SkillCheckMachine.lua` for future implementation.
- **Game Loop Integration**: The `RoundManager` now listens for `MachineCompleted` events from the `MachineManager`. It tracks the number of completed machines and can end the round when the objective is met, creating a win condition for survivors.

### Changed
- **Project Baseline**: This version represents a complete, clean baseline of the project after a full reset and re-implementation to resolve persistent workflow issues.
- Updated `Game_Concept_Overview.md` with the detailed rules for the Classic Machine.

## [1.0.1] - 2025-08-29

### Added
- **Initial Project Setup**: Created the foundational structure of the game.
- **Core Scripts**: `GameStateManager`, `RoundManager`, `PlayerManager`, `MachineManager`.
- **Game Loop Logic**: Implemented the basic, non-interactive game loop.
- **Project Documentation**: `GUIDELINES.md`, `ROADMAP.md`, `Game_Concept_Overview.md`.
- **Configuration**: `default.project.json` and `VERSION` file.
- `CHANGELOG.md` file created.
