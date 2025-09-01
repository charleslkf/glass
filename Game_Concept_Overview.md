# Game Concept Overview

## 1. Inspiration and Aspirations
This game draws inspiration from several well-known titles. The goal is to create a game, developed collaboratively between me and my dad, that achieves similar popularity and recognition. The core gameplay will revolve around the theme of **"forsaken"** and will incorporate elements from three distinct games.

## 2. Game Structure and Setting
- **Setting:** The game is set in the woods, not in a traditional elevator-based environment.
- **Goal:** Players work towards a specific goal or limit (10 days or 10 levels). A leaderboard will track the fastest completion times.
- **Round Size:** Each round features a maximum of **10 players**.
- **The Killer:** At the start of each round, one player is randomly chosen as the killer. This role is kept for the entire round. A visible bar will indicate a player's chance of being selected in future rounds.

## 3. Gameplay Mechanics
### Player Roles
Players are divided into three roles:
- **Stunners (Attackers):** Focused on confronting the killer.
- **Survivors:** Focused on completing objectives.
- **Helpers:** Possess the unique ability to regenerate other players' stamina and provide boosts.

### Items and Abilities
- **Items:** **Med kits** and **energy drinks** will appear on the floor. Each player can only carry two items at a time.
- **Character Abilities:** Every character has a unique ability, which may come with a price tag.
- **Skins:** Skins will be available for all characters, with each costing the same amount.

---
# Game Manual

This section details the specific rules and mechanics of the game.

## Minigame Mechanics

There are three types of machines that survivors can repair to win the round.

### 1. Classic Machine (Pipe Puzzle)
- **Objective:** Connect the green Start tile to the red End tile by rotating the pipe pieces.
- **How to Play:**
    - Interact with the machine to open the puzzle window.
    - The puzzle is a 5x5 grid of pipes.
    - Click on a blue (straight) or orange (L-shaped) pipe to rotate it 90 degrees clockwise.
    - Form a continuous, unbroken path from the green tile to the red tile.
    - Once you believe the path is complete, press the "Submit" button.
- **Note:** The UI will automatically close if you walk too far away from the machine.

### 2. Memory Machine
- **Objective:** Correctly repeat a pattern shown on a grid of buttons.
- **How to Play:**
    - Interact with the machine to open the puzzle window.
    - The game will flash a sequence of buttons on the 3x3 grid. Watch carefully.
    - After the pattern is shown, click the buttons in the exact same order.
    - The game will automatically submit your solution after you've clicked the correct number of buttons.
- **Note:** The UI will automatically close if you walk too far away from the machine.

### 3. Skill Check Machine
- **Objective:** Successfully complete a series of 3 timed skill checks.
- **How to Play:**
    - Interact with the machine to trigger a skill check. A bar will appear on your screen.
    - A white cursor will move from left to right across the bar.
    - Press the **Spacebar** when the cursor is inside the green "success zone".
    - If you succeed, another skill check will be triggered after a short delay.
    - If you fail (miss the zone or don't press the spacebar in time), your progress on the machine resets to zero.
    - After 3 consecutive successes, the machine is repaired.
- **Note:** The UI will automatically close if you walk too far away from the machine.

## Character Abilities

### Stunner Ability: Flashbang
- **Role:** Stunner
- **Key:** Q
- **Effect:** Fires a fast-moving yellow projectile forward.
- **How to Use:**
    - Aim at the Killer and press 'Q'.
    - If the projectile hits the Killer, they will be "stunned" (unable to move) for 3 seconds.
    - The server will perform a distance check to ensure the hit was legitimate.
- **Cooldown:** 30 seconds.
