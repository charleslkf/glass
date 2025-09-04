# Project Forsaken (Working Title)

This repository contains the source code for "Project Forsaken," an asymmetrical survival horror game built on the Roblox platform.

## About The Game

"Project Forsaken" is inspired by successful titles like "Dead by Daylight." One player takes on the role of a powerful Killer, while the remaining players team up as resourceful Survivors.

The core gameplay loop involves Survivors attempting to complete objectives (repairing 5 generators) to power the exit gates and escape, while the Killer hunts them and attempts to eliminate them. The game features a roster of unique Killers and a flexible, perk-based customization system for Survivors.

## Getting Started

This project uses [Rojo](https://rojo.space/) to sync the source code from this repository into a Roblox place file.

### Prerequisites
-   Roblox Studio
-   [Rojo CLI](https://rojo.space/docs/v7/getting-started/installation/)

### How to Run and Test

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-username/your-repository-name.git
    cd your-repository-name
    ```
2.  **Switch to the Correct Branch:**
    Before testing a new feature, always check which branch to use. For example:
    ```bash
    git checkout main
    git pull
    ```
3.  **Start the Rojo Server:**
    In your terminal, at the root of the project, run the following command:
    ```bash
    rojo serve
    ```
4.  **Connect in Roblox Studio:**
    *   Open your Roblox place file.
    *   In the top menu, go to the **"Plugins"** tab and click the **"Rojo"** button.
    *   Click **"Connect"**. The Rojo server will begin syncing the files into your game instance.
5.  **Run a Test Server:**
    *   In the top menu, go to the **"Test"** tab.
    *   Click the **"Start"** button to launch a local server with one or more players. The number of players required may vary depending on the test.

This setup will allow you to test the latest changes in a live Studio environment.
