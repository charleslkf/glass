# 1. Handle DataStore Failures Gracefully

*   **Status:** Accepted
*   **Date:** 2025-09-03

## Context and Problem Statement

When testing the game in Roblox Studio, the `DataStoreService` API is disabled by default unless explicitly enabled by the developer in the game's settings. Our initial `DataManager` code attempted to call `:GetAsync()` to load player data. When this API call inevitably failed in a default Studio environment, the code's error handling path was to immediately kick the player from the session with the message "There was an error loading your data."

This behavior made it impossible to test the game in Studio without first performing a manual configuration step, creating a significant barrier to rapid development and testing.

## Decision Drivers

*   The need for a smooth, "out-of-the-box" testing experience for developers.
*   The principle of failing gracefully; the game should not crash or become unplayable due to a predictable, non-critical service failure in a development context.
*   The behavior for a new player is to create default data. A failed data load can be treated similarly for the duration of a single session.

## Considered Options

1.  **Kick the Player (Current Implementation):** Continue with the existing logic. This is safe for a live game but extremely hostile to development.
2.  **Do Nothing:** Ignore the failure and proceed without loading or creating data. This would likely lead to numerous other errors downstream, as other scripts expect player data to exist.
3.  **Load Default Data:** If the `:GetAsync()` call fails, treat the player as if they were a new player and create a default data set for them to use during that session.

## Decision Outcome

Chosen option: **"Load Default Data"**.

We will modify the `DataManager`'s error handling path. If the `pcall` for `:GetAsync()` returns `success == false`, instead of kicking the player, the script will now:
1.  Log a descriptive warning to the console, explaining that the data load failed and default data is being used.
2.  Create a temporary, default set of player data (e.g., zero currency, no unlocks).
3.  Allow the player to join the game with this default data.

This change only affects the current session; it does not attempt to save this default data back to the DataStore upon failure.

### Consequences

*   **Positive:** Developers can immediately test the game in Roblox Studio without any special configuration. The game is more resilient to DataStore service outages during development.
*   **Negative:** None. This change does not negatively impact the live game environment, where DataStore access is expected to be available.
*   **Risks:** A developer might forget that they are playing with default data and be confused why their saved data is not present. The descriptive warning log is intended to mitigate this risk.
