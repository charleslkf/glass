# Changelog

All notable changes to this project will be documented in this file.

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
