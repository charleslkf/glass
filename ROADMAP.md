# Technical Development Roadmap (v2)

This roadmap outlines the development plan for "Project Forsaken," based on the updated Game Concept Overview. It prioritizes building the foundational systems first and then layering on features that add depth and variety.

---

## Milestone 1: Foundational Gameplay Loop
**Objective:** Implement the core "1 vs Many" survival loop. This is the Minimum Viable Product (MVP).

*   **Task 1.1: Implement Generator System**
    *   **Logic:** Create a system to spawn 5 generators. Survivors can repair them. Implement the skill-check minigame for repairs.
*   **Task 1.2: Implement Exit Gates**
    *   **Logic:** When all 5 generators are repaired, power the two exit gates. Survivors must complete an interaction to open them.
*   **Task 1.3: Basic Killer/Survivor Interaction**
    *   **Logic:** Implement the Killer's basic attack. Implement the three Survivor health states (Healthy, Injured, Downed).
*   **Task 1.4: Implement Sacrificial Hooks**
    *   **Logic:** Allow the Killer to pick up Downed Survivors and place them on hooks. Allow other Survivors to rescue them. Implement the 3-hook sacrifice system.
*   **Task 1.5: Implement Chase Mechanics**
    *   **Logic:** Add basic window vaults and droppable pallets for Survivors. Add "Scratch Marks" for the Killer to track running Survivors.

---

## Milestone 2: The Perk System
**Objective:** Implement the flexible perk system, which is the core of the Survivor experience.

*   **Task 2.1: Perk System Backend**
    *   **Logic:** Create a system to manage all available perks and a data structure to store which perks a player has unlocked and equipped.
*   **Task 2.2: Implement Initial Perk Set**
    *   **Logic:** Code the functionality for a starting set of 5-10 perks (e.g., faster healing, faster repairs, temporary speed boosts).
*   **Task 2.3: Perk Loadout UI**
    *   **Logic:** Create a pre-game UI where players can select their 4-perk loadout from the perks they have unlocked.

---

## Milestone 3: Killer Variety
**Objective:** Introduce multiple, unique Killers to create gameplay variety.

*   **Task 3.1: Refactor Ability System for Variety**
    *   **Logic:** Update the `AbilityManager` to handle multiple, unique Killer abilities without the hardcoded `if/elseif` structure.
*   **Task 3.2: Implement Killer 1: "The Trapper"**
    *   **Logic:** Design and code the ability to place traps that immobilize Survivors.
*   **Task 3.3: Implement Killer 2: "The Wraith"**
    *   **Logic:** Design and code the ability to turn invisible and ambush Survivors.

---

## Milestone 4: Meta-Progression
**Objective:** Build the systems that will drive long-term player engagement and retention.

*   **Task 4.1: Currency System**
    *   **Logic:** Award players with in-game currency based on their performance in a match.
*   **Task 4.2: Unlock System (The "Bloodweb")**
    *   **Logic:** Design and implement a progression tree where players spend currency to unlock new Perks, Items, and Add-ons.
*   **Task 4.3: Implement the Store**
    *   **Logic:** Create a UI and the backend logic for players to purchase new playable characters (Killers/Survivors) and cosmetics.

---

## Milestone 5: Polish & Quality of Life
**Objective:** Improve the overall user experience with audio-visual feedback and UI enhancements.

*   **Task 5.1: Advanced Sound Design**
    *   **Logic:** Implement directional audio, a "heartbeat" sound for Survivors when the Killer is near, and unique sounds for each Killer's ability.
*   **Task 5.2: Visual Effects (VFX)**
    *   **Logic:** Add VFX for Killer abilities, generator explosions, successful skill checks, and environmental interactions.
*   **Task 5.3: UI Overhaul**
    *   **Logic:** Refine the in-game HUD to clearly display player states, objectives, and perk cooldowns.
