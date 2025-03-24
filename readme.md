# OMM Missions Lua

**Version:** Beta 1.0  
**Authors:** Cybris (Lua rebuild), TempusX & Levox (original macro)  
**Date:** 2025-03-22

## Overview

OMM Missions Lua automates group missions for Old Man McKenzie (OMM) in EverQuest using MacroQuest Lua. It features a modular, table‑driven design with robust coordination between group members via a driver/follower system. Key enhancements include:

- **Mission Modules:**  
  - **Lower Guk (lguk):** Automates objectives for Lower Guk missions.  
  - **Nagafen's Lair (naggy):** Automates objectives for Nagafen's Lair missions.  
  - **Cursed Guk (dguk):** Automates objectives for Cursed Guk missions.

- **Driver/Follow Coordination:**  
  - A designated driver runs full mission logic and broadcasts synchronization messages.
  - Followers run the full combat, healing, and buff routines but wait for the driver’s sync signals to progress, keeping the group in step.
  - A UI dropdown allows selection of the driver from the group member list.

- **Enhanced Combat & Auto Buff/Heal:**  
  - Class‑specific combat routines (e.g., mezzing, draining, nuking) and pause/resume functionality.
  - Auto‑buff and auto‑heal modules ensure both group members and pets are maintained during missions.

- **Navigation:**  
  - A centralized, table‑driven navigation module stores waypoints for each mission zone.
  - A "general" section includes a placeholder for the Plane of Knowledge (PoK), with automatic navigation and targeting of Old Man McKenzie when needed.

- **UI Enhancements:**  
  - An ImGui‑based UI displays mission selection (both single and cycle modes), progress (via a progress bar and timer), current and next mission steps, objectives status, and a log window.
  - Additional UI controls include pause/resume, stop, and coordination options (assign roles, rotate tasks).
  - A self‑test command verifies required plugins.

- **Coordination & Communications:**  
  - The Lua supports either **MQ2DanNet** or **MQ2EQBCS** for group coordination.
  - A communications module broadcasts mission start, completion, and synchronization messages.
  - The UI enables users to select the desired coordination plugin.

- **Error Handling & Recovery:**  
  - Each mission module retries objectives up to a maximum count and includes recovery logic that re‑navigates to the objective if necessary.
  - After mission completion, the Lua issues an auto‑loot command.

## Installation

1. **Dependencies:**  
   Ensure the following MacroQuest Lua plugins are installed:
   - **MQ2Nav**
   - **MQ2DanNet** or **MQ2EQBCS** (selectable via the UI)

2. **Folder Structure:**  
   Place the Lua files in your MacroQuest folder with a structure similar to:

3. **Configuration:**  
- Adjust navigation coordinates in `modules/navigation.lua` as needed (especially the "general" section for PoK).
- Use the UI to select the coordination plugin (MQ2DanNet vs. MQ2EQBCS) and to choose the driver from your group.
- The driver is chosen via the UI dropdown; followers will automatically follow sync messages broadcast by the driver.

4. **Loading the Lua:**  
Launch MacroQuest and load the Lua by placing it in the appropriate directory. You may use `/reload mq2cymissions` if necessary.

## Usage

### In-Game Commands

- **/omm start `<mission>`**  
Runs a single mission. Valid mission names: `lguk`, `naggy`, `dguk`.

- **/omm pause**  
Pauses the current mission.

- **/omm unpause**  
Resumes a paused mission.

- **/omm stop**  
Stops the current mission.

- **/omm selftest**  
Runs a self‑test to verify required plugins (MQ2Nav, MQ2DanNet/MQ2EQBCS) are loaded.

### UI Controls

- **Mission Manager Window:**  
Open the ImGui window titled **"OMM Mission Manager"** (automatically opens on Lua load or via `/mq2imgui`).

- **Mission Selection:**  
- Use the dropdown to select a single mission.
- Use checkboxes for multi‑mission cycle selection and choose whether to repeat the cycle.

- **Driver Selection:**  
- A dropdown lists current group members; select the designated driver.
- The driver’s name is stored and used to synchronize mission progress.

- **Mission Progress & Objectives:**  
- A progress bar shows the percentage of completed objectives along with a timer.
- Current and next mission steps are displayed.
- Toggle a separate objectives window to view each objective’s status.

- **Logs:**  
- A toggle button displays a log window with recent debug messages for troubleshooting.

- **Coordination Controls:**  
- Choose between MQ2DanNet and MQ2EQBCS for group coordination.
- Buttons allow assignment of roles and task rotation, broadcasting these actions to the group.

- **Auto Buff/Heal:**  
- Buttons trigger auto‑buff routines and auto‑heal functions for both group members and pets.

### Group Synchronization

- **Driver/Follower Logic:**  
The designated driver runs full mission logic and broadcasts sync messages after each objective. All group members (including followers) run full mission logic but wait for the sync message before proceeding to the next objective. This ensures that everyone remains at the same point in the mission.

## Troubleshooting

- **Missing Plugins:**  
If required plugins (MQ2Nav, MQ2DanNet/MQ2EQBCS) are missing, the Lua will attempt to load them. If they remain missing, the Lua aborts and displays an error with the missing plugins.

- **Navigation Issues:**  
Check that the coordinates in `modules/navigation.lua` are correct and that you’re not in a different zone.

- **Group Readiness:**  
If objectives fail due to group readiness timeouts, ensure all group members are present and that network latency is acceptable.

- **Synchronization Issues:**  
Ensure that the designated driver is correctly selected via the UI and that all group members are receiving the broadcast sync messages (check the log window for debug messages).

- **Debug Logging:**  
Toggle the log window via the UI to review debug output for troubleshooting mission progress and errors.

## Attribution

- **Lua Rebuild:**  
This Lua rebuild is attributed to **Cybris**.
- **Original Macro:**  
The original macro was created by **TempusX** and **Levox**.

## Future Enhancements

- **Auto-Loot Enhancements:**  
Further refine loot handling if needed.
- **Advanced Buff/Heal Routines:**  
Expand the healing module with additional class‑specific or pet‑healing abilities.
- **Mission Rotation:**  
Add more sophisticated mission rotation features with auto‑retry or fallback strategies.
- **Persistent Logging:**  
Optionally save logs to a file for extended debugging.
- **Additional UI Refinements:**  
Further enhance UI indicators and real‑time status updates for improved group coordination.