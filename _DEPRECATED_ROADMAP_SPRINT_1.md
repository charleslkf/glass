# Gameplay Sprint 1 Roadmap

This document outlines the next phase of development, focusing on implementing core gameplay mechanics and interactive features (the "meat").

## Milestone 1: Interactive Minigames

**Objective:** To transform the placeholder machine interactions into fully playable minigames.

### Task 1.1: Implement the Classic Machine Minigame
- **Status:** Done

### Task 1.2: Implement the Memory Machine Minigame
- **Status:** Done

### Task 1.3: Implement the Skill Check Machine Minigame
- **Status:** Done

### Task 1.4: Create a Puzzle Library for the Classic Machine
- **Status:** To Do
- **Logic:**
    - Refactor the minigame to pull puzzle layouts from a central library module instead of being hardcoded in the UI script.
    - Create several more solvable 5x5 puzzle layouts to add to the library.
    - When a Classic Machine minigame starts, the server will randomly select a puzzle from the library to present to the player.

## Milestone 2: Interactive Abilities

**Objective:** To implement the first set of real character abilities.

### Task 2.1: Implement Stunner Ability
- **Status:** Done

### Task 2.2: Implement Helper Ability
- **Status:** Done

## Milestone 3: Bug Smashing & Polish

**Objective:** To fix all outstanding bugs in the core gameplay systems and ensure all features have correct feedback.

### Task 3.1: Stabilize Client-Side Architecture
- **Status:** Done
- **Logic:**
    - Diagnosed and fixed numerous cascading crashes on the client.
    - Refactored core managers (`SoundManager`, `VFXManager`) into proper `ModuleScript`s to ensure reliable loading and prevent race conditions.

### Task 3.2: Fix Ability & Combat Feedback
- **Status:** Done
- **Logic:**
    - Fixed bugs that prevented sound and visual effects from playing for the Helper and Stunner abilities.
    - Replaced the entire `ClickDetector`-based attack system with a more robust client-side detection and server-side validation system to fix the Killer's attack.

## Milestone 4: Interactive Shop

**Objective:** To make the shop UI functional.

### Task 4.1: Populate the Shop
- **Status:** To Do
- **Logic:**
    - Add items to the shop UI (e.g., character skins, different abilities).
    - Display the player's current currency (from the `DataManager`) in the UI.

### Task 4.2: Implement Purchases
- **Status:** To Do
- **Logic:**
    - When a player clicks a "Buy" button, a `RemoteEvent` will be sent to the server.
    - The server will check if the player has enough currency via the `DataManager`.
    - If they do, the server will deduct the currency, add the item to the player's "Unlocks" in their data, and save the data.
    - The server will then notify the client of the successful purchase.
