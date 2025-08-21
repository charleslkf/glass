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
    - Implementation of three unique mini-games:
        - **Skill Check:** A timing-based moving bar game.
        - **Memory:** A pattern-replication game on a grid whose difficulty scales with the game level.
        - **Classic:** A "matching pairs" puzzle with pathfinding to prevent line crossing.
    - "Walk away to cancel" feature for all mini-games, allowing players to disengage.
