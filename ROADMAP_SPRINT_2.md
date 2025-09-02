# Gameplay Sprint 2 Roadmap

**Objective:** To build the systems for player progression, including the item shop and in-game pickups.

## Milestone 1: Functional Shop UI

- **Status:** To Do
- **Task:** Populate the shop window with placeholder items for sale (we can start with a few skins or abilities).
- **Task:** Make the UI display the player's current currency, which we already have saved in the `DataManager`.

## Milestone 2: Purchase Logic

- **Status:** To Do
- **Task:** Implement the full client-to-server logic for purchasing an item.
- **Task:** The server will validate the purchase (checking the player's currency), deduct the cost, and save the new item to the player's `DataStore` unlocks.

## Milestone 3: In-Game Item Spawning

- **Status:** To Do
- **Task:** Implement a system that spawns pickup-able items (like Med-Kits and Energy Drinks, as mentioned in our Game Concept) in random locations around the map at the start of a round.

## Milestone 4: Item Functionality

- **Status:** To Do
- **Task:** Implement the logic for players to use these items. For example, using a Med-Kit would heal them, and an Energy Drink could provide a temporary speed boost.
