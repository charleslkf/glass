# Changelog

All notable changes to this project will be documented in this file.

## [2.4.0] - 2025-09-02

### Added
- **Complete Minigame Suite**: Implemented the full server and client-side logic for the remaining two minigames:
  - **Memory Machine**: A memory-based puzzle where players must repeat a sequence.
  - **Skill Check Machine**: A timing-based challenge requiring multiple successful skill checks.
- **Interactive Character Abilities**: Implemented the full functionality for the Stunner and Helper roles:
  - **Stunner Ability ("Flashbang")**: The Stunner can now fire a projectile that stuns the Killer on impact.
  - **Helper Ability ("Healing Aura")**: The Helper can now emit an AoE pulse that heals nearby survivors and provides a temporary speed boost to all affected players, including the Helper.
- **Client-Side Attack System**: Replaced the unreliable `ClickDetector` with a modern, robust client-side attack detection system. The client now detects clicks and informs the server, which then validates the attack. This is a major architectural improvement.

### Fixed
- **Numerous Ability Feedback Bugs**: Resolved a long series of cascading bugs that prevented ability sound and visual effects from working. This multi-step process involved:
  - Fixing multiple client-side script crashes caused by race conditions and incorrect asset IDs.
  - Refactoring client-side managers from `LocalScript`s to `ModuleScript`s to align with Roblox best practices and ensure reliable loading.
  - Fixing flawed event listener logic in the `SoundManager`.
  - Ensuring the `VFXManager` is correctly initialized.
- **Killer Attack Registration**: Fixed the critical bug where the Killer's attacks were not being registered by the server.

### Changed
- **Code Architecture**: Refactored `SoundManager` and `VFXManager` into `ModuleScript`s, improving the overall stability and structure of the client-side codebase.
- **Sound Placeholders**: Replaced invalid sound asset IDs with working placeholders to ensure functional auditory feedback.

## [1.0.55] - 2025-08-31

### Added
- **Playable Classic Machine Minigame**: Implemented the first fully playable minigame, "Classic Machine". This is a major feature that includes:
  - A new UI for the pipe-connecting puzzle, generated programmatically.
  - Client-side logic for rotating the pipe tiles.
  - Server-side validation logic using a Breadth-First Search (BFS) algorithm to verify a correct solution.
  - Sound and visual effects upon successful completion.

### Fixed
- **Minigame Unresponsiveness**: Fixed a series of complex bugs that prevented the minigame from working, including:
  - An input bug where UI elements were blocking clicks.
  - A visual bug where placeholder graphics did not rotate.
  - A server crash caused by an initialization race condition.
  - A networking bug where the server would incorrectly reject correct solutions.
- **Unsolvable Puzzle**: Replaced the initial, unsolvable puzzle layout with a new, verified solvable layout.
- **Round Goal Counter**: Fixed a bug where the `RoundManager` was not correctly counting the number of machines to complete.

### Changed
- **Minigame Networking**: Refactored the `MachineManager` to use unique string IDs for identifying machines instead of passing full objects over the network, making the system more robust.
- **Roadmap**: Updated `ROADMAP_SPRINT_1.md` to mark the Classic Machine task as "Done" and added a new task to create a library of puzzles for future replayability.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.38] - 2025-08-30

### Added
- **New Roadmap**: Created `ROADMAP_SPRINT_1.md` to outline the next phase of development, focusing on implementing interactive gameplay features ("the meat").

### Changed
- Marked the original `ROADMAP.md` as complete. The project has now moved from foundational systems to gameplay implementation.

## [1.0.37] - 2025-08-30

### Fixed
- **VFX Not Rendering**: Restored the custom properties (color, size, transparency, etc.) to the machine completion `ParticleEmitter`, but omitted the invalid `Texture` ID that was causing the effect to fail silently. The VFX is now visible and has a custom appearance.

## [1.0.36] - 2025-08-30

### Changed
- **VFX System (Diagnostic)**: Simplified the `ParticleEmitter` creation in `VFXManager` to a bare-bones version to test the hypothesis that a specific property was causing the visual effect to not render.

## [1.0.35] - 2025-08-30

### Fixed
- **VFX Not Rendering**: Refactored the `VFXManager` to use a single, permanent anchor part for hosting particle effects instead of creating temporary parts. This is a more robust solution that fixes the replication bug causing effects to be invisible.

## [1.0.34] - 2025-08-30

### Fixed
- **VFX Not Rendering**: Fixed a bug where the particle effect for machine completion was not visible. A `wait()` was added to the `VFXManager` to ensure the effect's container part replicates to the client before particles are emitted.

## [1.0.33] - 2025-08-30

### Added
- **VFX System Foundation**: Created the foundational client-side `VFXManager.client.lua` to handle playing visual effects.
- **Machine Completion VFX**: The `MachineManager` now fires a remote event when a machine is completed, and the `VFXManager` listens for this event to play a particle effect at the machine's location.

## [1.0.32] - 2025-08-30

### Added
- **Ability Usage Mechanic**: Implemented the full loop for using an ability.
  - Players are now equipped with a default ability when roles are assigned.
  - `AbilityUIController` now listens for the 'Q' key press and fires a `RemoteEvent` to the server.
  - `AbilityManager` listens for this event and executes the player's equipped ability.

## [1.0.31] - 2025-08-30

### Changed
- **Code Cleanup**: Removed diagnostic `print` statements from `PlayerManager.lua` that were used to debug the Click-to-Attack feature.

## [1.0.30] - 2025-08-30

### Added
- **Diagnostic Logging**: Added more detailed `print` statements to the `PlayerManager` to debug an issue where the `ClickDetector` for the killer attack was not being created.

## [1.0.29] - 2025-08-30

### Added
- **Click-to-Attack Mechanic**: Implemented the killer's primary attack mechanic.
  - A `ClickDetector` is now added to each player's character when they spawn.
  - When a player with the "Killer" role clicks on another player, it now triggers the `KillerAttack` function, dealing damage.

## [1.0.28] - 2025-08-30

### Added
- **Machine Interaction**: Players can now interact with machines.
  - A `ProximityPrompt` is now added to each machine part, allowing players to trigger an interaction (default key 'E').
  - The debug timer that automatically completed machines was removed in favor of this new, player-driven mechanic.

## [1.0.27] - 2025-08-30

### Changed
- Updated the `GUIDELINES.md` to include a new section on the user acting as "eyes and hands" for tasks inside Roblox Studio.

### Fixed
- **Invalid Sound ID**: Replaced the invalid sound ID with a user-provided, valid one (`3997124966`) in `SoundManager.client.lua`. This finally resolves the sound asset loading error.

## [1.0.26] - 2025-08-30

### Fixed
- **Invalid Sound ID**: Replaced an invalid `SoundId` in `SoundManager.client.lua` that was causing an asset loading error. The sound effect for machine completion should now play correctly.

## [1.0.25] - 2025-08-30

### Fixed
- **Sound System Testing**: Re-added a `task.delay` debug trigger to `RoundManager.lua`. This was previously removed and prevented the sound system from being tested. This allows the `MachineComplete` sound effect to be triggered for verification.

## [1.0.24] - 2025-08-30

### Added
- **Sound System Foundation**: Created the foundational client-side `SoundManager.client.lua` to handle playing sound effects.
- **Event Manager**: Created a new `EventManager.lua` to manage global `RemoteEvent`s.
- **Machine Completion Sound**: The `MachineManager` now fires a remote event when a machine is completed, and the `SoundManager` listens for this event to play a "success" sound. This serves as the first implementation and test of the sound system.

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
