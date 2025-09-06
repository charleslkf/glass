# Final Testing Instructions for v2.5.2

This version contains the complete ability system refactor and the standardized PC controls. All tablet-specific code has been removed. This should be the final, stable version for this feature.

Please launch a playtest in Studio with **at least 4 players** to ensure all roles can be assigned.

## 1. Game Start & Role Assignment
-   **Check Server Logs:** Confirm that the logs show all four roles (Killer, Sentinel, Support, Survivalist) being assigned and their perks being equipped correctly.
-   **Expected Result:** There should be **no errors** during startup.

## 2. Machine Spawning
-   **Visual Check:** Confirm that all three machine blocks appear on the ground correctly.

## 3. Standardized PC Controls
-   **Support:** As the "Support" player, confirm that both 'Q' and Left-Click trigger the healing ability.
-   **Sentinel:** As the "Sentinel" player, confirm that both 'Q' and Left-Click fire the stun projectile.
-   **Killer:** As the "Killer" player, aim at a survivor and confirm that both 'Q' and Left-Click trigger the attack.
-   **Stun Mechanic:** Confirm that hitting the Killer with the stun projectile only stuns them once and that they recover correctly.

## 4. Tablet Mode (Verification of Removal)
-   **Emulator:** In Studio, enable the Device Emulator for a tablet.
-   **Expected Result:** The on-screen action button should **not** appear. The game should be playable, but without a dedicated touch button for actions.

---

If these tests pass, we can officially close this task and move on. Thank you for your thorough testing!
