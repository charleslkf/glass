# Changelog

All notable changes to this project will be documented in this file.

## [2.0.0] - 2025-08-27

### Added
- **UI Theming System:** Implemented a new `ThemeManager` module to centralize UI color management, allowing for easy theming. The initial implementation includes a full "Dark Theme" for all mini-game UIs.
- **Project Configuration:**
    - Added a `default.project.json` file to formally structure the project for use with Rojo.
    - Added a `VERSION` file to track build versions.
    - Added a `.gitkeep` file to the `StarterCharacterScripts` directory to ensure it is tracked by Git.
- **"Number Link" Mini-Game:** Re-implemented the "Number Link" mini-game, which was previously removed. The game is now stable.

### Changed
- **File Naming Convention:** Refactored key `ModuleScript` files (`GameStateManager`, `RoundManager`, `ThemeManager`) to remove the `.module` suffix from their filenames, standardizing the project structure and resolving critical loading errors.

### Fixed
- **Multiple Critical Loading Errors:** Resolved a series of `Infinite yield` errors on both the client and server. The root cause was a combination of filename mismatches and script dependencies failing to load in the correct order.
- **Multiple Syntax Errors:**
    - Fixed a server-side syntax error in `MachineManager.server.lua` caused by using the Lua keyword `end` as a table key.
    - Fixed a persistent, subtle client-side syntax error in `MachineUIController.client.lua` within the `runNumberLinkGame` function.

## [1.1.0] - 2025-08-23

### Added
- Implemented a visible in-game UI to display the round timer and game status.
- Integrated timer mechanics with gameplay events:
    - Completing a machine now adds 5 seconds to the round timer.
    - A survivor's death now removes 10 seconds from the round timer.

### Changed
- The minimum number of players required to start a round was lowered from 2 to 1 to facilitate easier testing.
- Refactored server-side script communication to be more direct and robust, removing the need for certain `BindableEvent`s.

### Fixed
- **Critical Game Start Bug:** Fixed a race condition that caused the main game loop to hang indefinitely, preventing rounds from ever starting. The fix involved moving the game start call to be before an infinite loop in `MachineManager`.
- **Module Loading Errors:** Resolved `Infinite yield` errors by renaming script files to use the `.module.lua` convention, ensuring they are correctly loaded as `ModuleScript`s.
- **Client Script Overwrite:** Restored the `MachineUIController.client.lua` script, which was accidentally overwritten, re-enabling the machine repair minigames.

## [1.0.0] - 2025-08-23

This marks the first stable release of the game. It includes a core gameplay loop and two fully functional mini-games.

### Added

- **Core Game Framework:**
    - `GameStateManager`: Tracks overall game progression through "days" or levels.
    - `RoundManager`: Manages the main game loop, including intermission, killer selection, and round timers.
    - `PlayerManager`: Assigns health to players based on their role (Killer, Survivor, etc.).
    - `EventSetup`: Reliably creates all necessary `RemoteEvent` instances for client-server communication.
- **Machine & Mini-Game System:**
    - `MachineManager`: A server-side script to control machine spawning and mini-game logic.
    - `MachineUIController`: A client-side script to render the UI and handle player input for all mini-games.
- **Two Complete Mini-Games:**
    - **Skill Check:** A timing-based challenge where the player must stop a moving bar in a target zone.
    - **Memory Game:** A pattern-replication challenge where the player must remember and repeat a sequence of highlighted tiles.
- **Gameplay Features:**
    - Players can walk away from a machine to safely cancel a mini-game in progress.
    - Mini-games require multiple successful stages to complete, with progress displayed on the UI.

### Removed

- **"Classic" Mini-Game:** An 8x8 grid-based, click-and-drag puzzle was initially developed but was completely removed from both client and server scripts due to a persistent, unresolvable bug that caused client-side crashes.

### Fixed

- **Critical Client-Side Crash:** Resolved a recurring `attempt to compare nil < number` error that caused severe instability. The fix involved implementing a defensive `pcall` (protected call) in the `RenderStepped` distance-checking function to gracefully handle race conditions where a machine object might be destroyed mid-frame.
- **Player State Logic Bug:** Fixed a server-side bug that prevented players from using a second machine after successfully completing a first one. The fix ensures the player's "active" status is correctly reset.
- **Initial `ProximityPrompt` Failures:** Addressed an early issue where machine prompts would not work, which was traced to a local Roblox Studio environment problem.
