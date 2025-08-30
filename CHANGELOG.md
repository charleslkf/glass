# Changelog

All notable changes to this project will be documented in this file.

## [3.4.0] - 2025-08-29
### Added
- **Project Recovery:** This version marks a full recovery from a catastrophic repository reset. All essential documentation, configuration, and script files have been restored.
- **Server-Side Architecture:** Implemented a `Main.server.lua` entry point to control the loading order of server modules, preventing race conditions and `Infinite yield` errors.
- **Status UI Object:** Added a `StringValue` named "Status" to `ReplicatedStorage` to be created on startup, fixing a client-side UI error.

### Changed
- **Server-Side Modularity:** Refactored `PlayerManager.server.lua` and `MachineManager.server.lua` into modules that can be started on command by `Main.server.lua`.
- **File Naming Convention:** Standardized all server module scripts by removing the `.module.lua` suffix, making `require()` calls cleaner.

### Fixed
- **Server-Side Syntax Error:** Fixed a critical syntax error in `MachineManager.server.lua` by changing the reserved keyword `end` to `["end"]` in a table key.
- **Client-Side Syntax Error:** Fixed a corresponding error in `MachineUIController.client.lua` to correctly read the `["end"]` key.
- **Client-Side Syntax Error:** Fixed a second subtle syntax error in `MachineUIController.client.lua` that was causing script failures.

*Note: The version history below this point is reconstructed from memory after the repository reset.*

---

## [1.1.0] - 2025-08-23

### Added
- Implemented a visible in-game UI to display the round timer and game status.
- Integrated timer mechanics with gameplay events.

### Changed
- Lowered the minimum number of players required to start a round to 1.

### Fixed
- Critical game start bug (race condition).
- Module loading errors.
- Restored an accidentally overwritten client script.

## [1.0.0] - 2025-08-23

### Added
- Core game framework (`GameStateManager`, `RoundManager`, `PlayerManager`, `EventSetup`).
- Machine and mini-game system (`MachineManager`, `MachineUIController`).
- Two complete mini-games (Skill Check, Memory Game).

### Removed
- A "Classic" mini-game due to unresolvable bugs.

### Fixed
- Critical client-side crash (`pcall` implementation).
- Player state logic bug.
- Initial `ProximityPrompt` failures.
