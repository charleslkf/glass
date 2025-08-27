# Technical Development Roadmap

This document outlines the specific coding tasks required to build the game, starting with the core gameplay loop.

## Milestone 1: Core Gameplay Loop Implementation

**Objective:** To create a functional round-based system on the server that can manage players, states, and timers.

### Task 1.1: Enhance the `GameStateManager`
- **Status:** Complete
- **File:** `ServerScriptService/GameStateManager.lua`
- **Logic:**
    - Add a `state` variable (e.g., "Lobby", "InRound", "Intermission").
    - Create functions to change the state (`SetState`).
    - Fire a `BindableEvent` whenever the state changes so other server scripts can react.

### Task 1.2: Enhance the `RoundManager`
- **Status:** Complete
- **File:** `ServerScriptService/RoundManager.lua`
- **Logic:**
    - Listen for state changes from `GameStateManager`.
    - **On "Lobby" state:**
        - Check player count. If enough players are present, start a countdown timer.
    - **On "InRound" state:**
        - Call `PlayerManager` to assign roles (killer/survivor).
        - Start the main round timer.
    - **On "Intermission" state:**
        - Reset machines and player positions.
        - Start a short intermission timer before returning to the Lobby state.

### Task 1.3: Enhance the `PlayerManager`
- **Status:** To Do
- **File:** `ServerScriptService/PlayerManager.lua`
- **Logic:**
    - Add a function `AssignRoles()` that takes the list of players.
    - Inside `AssignRoles()`, randomly select one player and assign them the "Killer" role.
    - Assign the "Survivor" role to all other players.
    - Store the roles in a table, mapping player objects to their role string.

### Task 1.4: Connect Machines to the Game Loop
- **Status:** To Do
- **File:** `ServerScriptService/MachineManager.lua`
- **Logic:**
    - Modify the `completeMachine` function. Instead of just adding time, it should also report the completion to the `RoundManager`.
    - The `RoundManager` will then check if the level goal has been met to advance to the next level.

## Milestone 2: Player Systems & Abilities
**Objective:** Implement health, roles, and unique character abilities.

- **Task 2.1: Health & Damage System**
    - **File:** `ServerScriptService/PlayerManager.lua`
    - **Logic:** Create a `TakeDamage(player, amount)` function. When a player's health reaches 0, handle their death. Implement the killer's attack logic.
- **Task 2.2: Implement Player Roles**
    - **File:** `ServerScriptService/PlayerManager.lua`
    - **Logic:** Expand `AssignRoles` to include "Stunner" and "Helper" roles.
- **Task 2.3: Character Ability System**
    - **File:** New module `ServerScriptService/AbilityManager.lua`
    - **Logic:** Create a framework to trigger abilities with a `UseAbility(player)` function.
    - **File:** New script `StarterPlayer/StarterPlayerScripts/AbilityUIController.client.lua`
    - **Logic:** Create a new UI to show the player's ability and its cooldown.

## Milestone 3: Economy & Customization
**Objective:** Build the in-game economy and shop.

- **Task 3.1: Currency & Data Persistence**
    - **File:** New module `ServerScriptService/DataManager.lua`
    - **Logic:** Use Roblox's `DataStoreService` to save and load player data (currency, unlocks).
- **Task 3.2: Shop UI**
    - **File:** New script `StarterPlayer/StarterPlayerScripts/ShopUIController.client.lua`
    - **Logic:** Create a shop UI for purchasing characters and skins.

## Milestone 4: Polish
**Objective:** Improve the user experience.

- **Task 4.1: Sound Integration**
    - **Logic:** Add sound effects for key events like machine interaction, skill checks, and abilities.
- **Task 4.2: Visual Effects (VFX)**
    - **Logic:** Add particle effects for events like machine completion and killer attacks.

## Milestone 5: Events & Live-Ops
**Objective:** Build the framework for seasonal events.

- **Task 5.1: Event System**
    - **File:** New module `ServerScriptService/EventManager.lua`
    - **Logic:** Create a system to define and manage events with start/end dates and special content.
