# Gameplay Sprint 1 Roadmap

This document outlines the next phase of development, focusing on implementing core gameplay mechanics and interactive features (the "meat").

## Milestone 1: Interactive Minigames

**Objective:** To transform the placeholder machine interactions into fully playable minigames.

### Task 1.1: Implement the Classic Machine Minigame
- **Status:** Done
- **Logic:**
    - When a player interacts with a "ClassicMachine" part, a new UI will appear on their screen.
    - The UI will present the "pipe-connecting" puzzle grid.
    - The client will handle the drawing logic and input.
    - When the player believes they have solved it, the client will send the solution to the server.
    - The `ClassicMachine.lua` module on the server will validate the solution using its `ValidateSolution` function.
    - If correct, the machine will be marked as complete.

### Task 1.2: Implement the Memory Machine Minigame
- **Status:** Done
- **Logic:**
    - Create a UI for the memory game (a grid of buttons).
    - When interacted with, the server will generate a pattern and send it to the client.
    - The client will display the pattern, then hide it.
    - The player must click the buttons in the correct sequence.
    - The client will send the player's attempt to the server for validation.

### Task 1.3: Implement the Skill Check Machine Minigame
- **Status:** Done
- **Logic:**
    - Create a UI for the skill check (e.g., a moving bar and a target zone).
    - When interacted with, the client will begin the skill check sequence.
    - The client will report successes or failures to the server, which will track the overall progress.

### Task 1.4: Create a Puzzle Library for the Classic Machine
- **Status:** To Do
- **Logic:**
    - Refactor the minigame to pull puzzle layouts from a central library module instead of being hardcoded in the UI script.
    - Create several more solvable 5x5 puzzle layouts to add to the library.
    - When a Classic Machine minigame starts, the server will randomly select a puzzle from the library to present to the player.

## Milestone 2: Interactive Abilities

**Objective:** To implement the first set of real character abilities.

### Task 2.1: Implement Stunner Ability
- **Status:** To Do
- **Logic:**
    - Replace the `DefaultSurvivorAbility` for the "Stunner" role.
    - The ability could be: When used, fire a short-range projectile. If it hits the Killer, the Killer is frozen for a few seconds.
    - This will require a new `RemoteEvent` for firing and server-side logic to handle the projectile and the stun effect.

### Task 2.2: Implement Helper Ability
- **Status:** To Do
- **Logic:**
    - Replace the `DefaultSurvivorAbility` for the "Helper" role.
    - The ability could be: When used, grant a temporary speed boost to all other nearby survivors.
    - This will require checking distances on the server and applying a temporary change to the other players' character `WalkSpeed`.

## Milestone 3: Interactive Shop

**Objective:** To make the shop UI functional.

### Task 3.1: Populate the Shop
- **Status:** To Do
- **Logic:**
    - Add items to the shop UI (e.g., character skins, different abilities).
    - Display the player's current currency (from the `DataManager`) in the UI.

### Task 3.2: Implement Purchases
- **Status:** To Do
- **Logic:**
    - When a player clicks a "Buy" button, a `RemoteEvent` will be sent to the server.
    - The server will check if the player has enough currency via the `DataManager`.
    - If they do, the server will deduct the currency, add the item to the player's "Unlocks" in their data, and save the data.
    - The server will then notify the client of the successful purchase.
