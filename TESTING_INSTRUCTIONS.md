# Final Testing Instructions for Complete Refactor (v2.5.1)

This version should contain the complete refactoring and all the bug fixes we've discussed. Here is a comprehensive set of tests to verify that everything is working correctly.

Please launch a playtest in Studio with **at least 4 players** to ensure all roles can be assigned (Killer, Sentinel, Support, Survivalist).

## 1. Game Start & Role Assignment
-   **Check Server Logs:** At the start of the round, confirm that the logs show all four roles being assigned and their perks being equipped correctly.
-   **Expected Result:** There should be **no errors or warnings** about invalid perks in the server output.

## 2. Machine Spawning
-   **Visual Check:** Confirm that you can see all three machine blocks in the game world.
-   **Expected Result:** They should be resting properly on the ground (not floating or stuck in the floor). The server logs should show `"Found ground at: ..."` messages for each machine.

## 3. PC Controls
-   **Support:** As the player assigned the "Support" role, press 'Q' and then try Left-Clicking. Both should trigger the healing ability.
-   **Sentinel:** As the player assigned the "Sentinel" role, press 'Q' and then try Left-Clicking. Both should fire the stun projectile.
-   **Killer:** As the player assigned the "Killer" role, aim at a survivor and press 'Q' and then try Left-Clicking. Both should trigger the attack.

## 4. Tablet Controls
-   **Emulator:** In Studio, go to the "Test" tab and enable the Device Emulator. Select a tablet like an iPad.
-   **Visual Check:** Confirm a circular, semi-transparent grey button appears on the bottom-right of the screen.
-   **Functionality:** Tapping the button should perform the primary action for each role (Heal for Support, Projectile for Sentinel, Attack for Killer).

## 5. Stun Mechanic
-   **Hit Test:** As the Sentinel, hit the Killer with the stun projectile.
-   **Expected Result:** The Killer should be frozen for 3 seconds and then recover. The server log should only show **one** hit event per projectile. The permanent-stun bug should be gone.
-   **Miss Test:** As the Sentinel, fire the projectile but miss any players.
-   **Expected Result:** The projectile should fire and disappear. There should be no errors in the server log.

---

If all of these tests pass, the task is complete. Please let me know the results.
