# Test Plan for Generator Objective (v2.6.0)

This document outlines the steps to test and verify the implementation of the core generator objective on the `feat/generator-objective` branch.

### **Setup**
1.  In your VS Code terminal, ensure you are on the correct branch by running: `git checkout feat/generator-objective`
2.  Pull the latest changes from the repository: `git pull`
3.  Start the Rojo server: `.\rojo.exe serve`
4.  Open your Roblox place file in Roblox Studio and connect to the Rojo server.

### **Testing Steps**
1.  **Start a Local Server:** In the "Test" tab of Roblox Studio, start a local server with **2 or more players**. A round will not start with fewer than 2 players.
2.  **Check Server Logs for Spawning:** Open the "Output" window. In the dropdown menu at the top of the window, select the "Server" context to view server-side logs. At the beginning of the round, you should see the message: `Spawning 5 generators for the round.`
3.  **Verify Generators In-Game:** Join the game as a survivor and explore the map. You should be able to find **5 machines**. All 5 of these machines should be the "Skill Check" type. The "Classic Machine" (pipe puzzle) and "Memory Machine" should not be present.
4.  **Complete the Objective:** As a survivor, interact with and complete all 5 of the Skill Check machines.
5.  **Check Server Logs for Completion:** After the fifth and final machine is repaired, check the server Output window again. You should see the new message: `All machines completed! Triggering Endgame.`
6.  **Confirm Final Round Behavior:** Immediately after the "Triggering Endgame" message appears, the round should end, and the game should transition to the intermission screen. This is the expected behavior for now, as the exit gate functionality has not yet been implemented.

If all of these steps are successful, it confirms that the foundational MVP objective is working correctly.
