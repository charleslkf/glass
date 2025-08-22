# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **Initial Game Framework:**
    - `GameStateManager` to track level progression.
    - `RoundManager` for the core game loop, including intermissions, rounds, and win/loss conditions.
    - `PlayerManager` to handle player health and roles.
    - `EventSetup` to create all necessary `RemoteEvent`s for mini-game communication.
- **Core Gameplay Mechanics:**
    - Role assignment system for "Killer", "Survivor", "Stunner", and "Helper".
    - Level progression from 1 to 10.
    - Round timer that can be modified by in-game events (machine completion, survivor elimination).
    - Post-round "gate open" phase.
- **Machine Mini-Games:**
    - A `MachineManager` that spawns three different types of interactive machines ("SkillCheck", "Memory", "Classic").
    - A client-side `MachineUIController` to handle the UI for all mini-games.
    - Implementation of three unique mini-games.
    - "Walk away to cancel" feature for all mini-games, allowing players to disengage.
    - Progress indicators ("X / 6") for multi-stage mini-games.

### Changed
- **Skill Check Game:**
    - Increased required successes from 4 to 6.
    - Slowed down the bar movement speed for easier gameplay.
    - Added a 1.5-second delay before the mini-game starts.
    - Failure no longer reduces progress.
- **Memory Game:**
    - Changed to a multi-stage challenge requiring 6 successes.
    - Pattern length is now fixed at 5 tiles.
- **Classic Machine Game:**
    - Redesigned from a 'click-click' puzzle to a 'click-and-drag' mechanic.
    - Puzzle pairs now include matching colors.
    - Grid size increased from 6x6 to 8x8 for more spacious puzzles.

### Fixed
- Fixed a bug where `ProximityPrompt` events would not fire due to a Roblox Studio environment issue (resolved by reinstalling Studio).
- Fixed a client-side error `invalid argument #1 (Vector2 expected, got Vector3)` in the Classic Machine's input handling.
- Fixed a bug where the client would close the UI after each successful stage of a multi-stage mini-game instead of waiting for the final completion signal from the server.
