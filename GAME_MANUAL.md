# D.N.F: The Official Game Manual

Welcome to D.N.F. This manual provides a comprehensive overview of the game's rules, objectives, and mechanics to guide both players and future development.

## 1. Game Overview

"D.N.F" is an asymmetrical survival horror game for up to four players. One player takes on the role of the supernatural **Killer**, whose goal is to hunt and sacrifice the other players. The remaining players are **Survivors**, who must work together to power up the Exit Gates and escape.

A round of "D.N.F" is a tense and strategic experience that unfolds in three acts:

*   **Act I: The Opening:** Survivors must find and repair three complex machines while avoiding the Killer.
*   **Act II: The Mid-Game:** The Killer actively hunts, downs, and hooks Survivors, forcing the team to balance repairing with risky rescues.
*   **Act III: The Endgame Collapse:** Once all machines are repaired, a timed endgame sequence begins. Survivors must open one of two Exit Gates and escape before the timer runs out.

## 2. Winning & Losing

The two sides have clear and opposing goals.

### Survivor Win Condition: Escape
To win, the Survivor team must achieve the following:
1.  **Repair 3 Machines:** This powers up the two Exit Gates on the map.
2.  **Open an Exit Gate:** Approach a powered gate and complete a timed interaction to open it.
3.  **Escape:** At least one Survivor must run through the opened gate to secure a win for the team.

### Killer Win Condition: Sacrifice
To win, the Killer must prevent the Survivors' escape by hunting and sacrificing them on hooks. A perfect game for the Killer results in all four Survivors being eliminated.

## 3. The Killer

The Killer is the antagonist of the match. Their objective is to down and hook Survivors.

**Core Abilities:**
*   **Attack:** The Killer can perform a basic attack to injure Survivors. It takes two hits to put a healthy Survivor into the "Downed" state.
*   **Pickup & Carry:** The Killer can pick up a downed Survivor and carry them to a sacrificial hook.
*   **Hook:** While carrying a Survivor, the Killer can interact with a hook to place the Survivor on it.

## 4. The Survivors

Survivors must use teamwork, stealth, and the environment to complete their objectives and escape.

### Survivor States
A Survivor's ability to perform actions depends on their current health state:
*   **Healthy:** Can perform all actions at normal speed.
*   **Injured:** Can perform all actions, but may be slower at some. Can be healed by other Survivors or with a Med-Kit.
*   **Downed:** Cannot move or perform most actions. Must be healed by a teammate.
*   **Carried:** Being carried by the Killer. Cannot perform any actions.
*   **Hooked:** Placed on a sacrificial hook. Must be rescued by a teammate.
*   **Escaped:** Has successfully left the match.

### Survivor Roles
At the start of a round, each Survivor is assigned a role with unique perks. (Note: Currently, only one perk per role is implemented).
*   **The Sentinel:** A defensive specialist.
*   **The Support:** A healing-focused role.
*   **The Survivalist:** A master of self-preservation.

## 5. Objectives & Interactions

### The Machines
There are three unique machines on the map that must be repaired. Each one has a different minigame:
*   **Classic Machine:** A logic puzzle requiring the player to connect pipes on a grid.
*   **Memory Machine:** A test of short-term memory where the player must repeat a sequence.
*   **Skill Check Machine:** A test of timing and reflexes.

### In-Game Items
Survivors can find items in chests placed around the map.
*   **Chests:** Interact with a chest to receive an item. A chest can only be searched once per cooldown period.
*   **Med-Kit:** A limited-charge item that allows a Survivor to heal themselves from the "Injured" state to "Healthy". This is used by pressing the **Right Mouse Button**.

### Other Interactions
*   **Unhooking:** A healthy or injured Survivor can approach a hooked teammate and press the **Interaction Key (`E`)** to rescue them.
*   **Opening Gates:** After all machines are repaired, a Survivor can approach an Exit Gate and press the **Interaction Key (`E`)** to open it.

## 6. The HUD (Heads-Up Display)

The HUD provides players with critical information during the match.

### ASCII UI Layout

```
+--------------------------------------------------------------------------+
| [OBJECTIVE_INFO]                                                         |
|   Machines Repaired: X / Y                                               |
|   Time Left: MM:SS                                                       |
|                                                                          |
|                                                                          |
|                                [ANNOUNCEMENT_TEXT]                         |
|                                                                          |
|                                                                          |
|                                                                          |
|                                                                          |
|                                                                          |
|                                                                          |
|                                                              [ITEM_ICON] |
+--------------------------------------------------------------------------+
```

### UI Element Descriptions

*   **[OBJECTIVE_INFO]:** (Top-Left) Appears during the main round.
    *   **Machines Repaired:** Shows the number of machines completed out of the total.
    *   **Time Left:** Shows the time remaining in the round before the Killer wins automatically.

*   **[ANNOUNCEMENT_TEXT]:** (Top-Center) A large text label that shows important game state information, such as:
    *   "Waiting for more players..."
    *   "Round starting in: X"
    *   "YOU ARE THE KILLER" / "YOU ARE A SURVIVOR"
    *   The large **Endgame Collapse** countdown timer.

*   **[ITEM_ICON]:** (Bottom-Right) An icon representing the item the Survivor is currently holding (e.g., a Med-Kit). Appears when an item is picked up and disappears when it is used up.
