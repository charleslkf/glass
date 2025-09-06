# Forsaken: Project Roadmap

This document outlines the consolidated development plan for the project. It tracks features that are complete, features that need to be improved to align with the new design, and features that are brand new.

---

## I. Foundational Systems (Core Engine)

- [x] **Core Managers:** A modular manager-based architecture is in place (`GameStateManager`, `RoundManager`, `PlayerManager`, etc.).
- [x] **Data Persistence:** `DataManager` is implemented for saving/loading player data (`Currency`, `Unlocks`).
- [x] **Event System:** A centralized `EventManager` for client-server communication is implemented.
- [x] **Health & Damage:** `PlayerManager` handles a basic health and damage system.
- [x] **Sound & VFX:** `SoundManager` and `VFXManager` are in place for client-side feedback.

---

## II. Core Gameplay Loop & Mechanics

### Features to be Improved / Refactored
- [x] **Player Roles & Abilities:** Refactor the old `Stunner`/`Helper` system into the new class-based system (Survivalist, Sentinel, Support) with their unique perks.
- [x] **Killer Gameplay:** Expand the Killer's abilities beyond just attacking. Implement the full sequence: downing, picking up, carrying, and hooking a survivor.
- [ ] **Refine Survivor Interactions (Unhooking):** Implement contextual interactions for survivors, starting with the ability to unhook teammates.
- [ ] **Survivor Win Condition:** Update the game loop. Repairing the three machines should now power two Exit Gates. The 'Endgame Collapse' sequence needs to be implemented.
- [ ] **Shop & Purchase Logic:** Implement the logic for purchasing items from the shop UI. The `DataManager` needs to be updated to handle these transactions.

### New Features to be Implemented
- [ ] **Sacrificial Hooks:** Design and implement the hook objects and the sacrifice progression mechanic.
- [ ] **Chase Mechanics: Pallets & Vaults:** Implement pallet and window vault objects that can be used by survivors to interact with the environment during a chase.
- [ ] **Tracking System: Scratch Marks:** Implement the visual system that makes running survivors leave temporary scratch marks visible only to the Killer.
- [ ] **Endgame Collapse:** Implement the timer and associated mechanics for the final phase of the game after the machines are repaired.
- [ ] **In-Game Items:** Implement the full lifecycle for items: spawning on the map, being picked up by players (with inventory limits), and being used (e.g., Med-Kit for healing).

---

## III. Minigames & Objectives

- [x] **Classic Machine:** The server-side validation logic (BFS) and client-side UI/controller are complete.
- [x] **Memory Machine:** The server-side pattern generation/validation and client-side UI/controller are complete.
- [x] **Skill Check Machine:** The server-side success tracking and client-side `TweenService`-based UI/controller are complete.

### Features to be Improved / Refactored
- [ ] **General Skill Checks:** Adapt the skill check mechanic from the `SkillCheckMachine` to be a general mechanic that can occur during other interactions (like repairing machines or healing).
- [ ] **Puzzle Library:** Refactor the `ClassicMachineGui` to pull from a library of puzzles instead of using a single hardcoded layout, to improve replayability.

---

## IV. Meta-Progression & UI

- [x] **Basic Shop UI:** The client-side `ShopUIController` programmatically creates a basic shop interface.

### Features to be Improved / Refactored
- [ ] **Data Model for Meta-Progression:** The `DataManager`'s `Unlocks` table needs to be expanded to support the new "Bloodweb" concept of perks, characters, add-ons, and offerings.

### New Features to be Implemented
- [ ] **"Bloodweb" System:** Design and implement the UI and underlying logic for the node-based progression screen where players spend currency to unlock new items and perks.
- [ ] **New Character & Perk Implementation:** Implement the actual gameplay effects of the new survivor perks (Adrenaline, Guardian, Botany Knowledge, etc.).
- [ ] **Player Inventory UI:** Create a simple UI on the main game screen to show the items a player is currently carrying.
