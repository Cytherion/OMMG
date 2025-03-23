# OMM Missions Lua

**Version:** Beta 1.0  
**Authors:** Cybris (Lua rebuild), TempusX & Levox (original macro)  
**Date:** 2025-03-22

## Overview

OMM Missions Lua automates group missions for Old Man McKenzie (OMM) in EverQuest using MacroQuest Lua. It is built in Lua with a modular, table‑driven design and integrates the following key features:

- **Mission Modules:**  
  - **Lower Guk (lguk):** Automates the objectives for Lower Guk missions.  
  - **Nagafen's Lair (naggy):** Automates the objectives for Nagafen's Lair missions.  
  - **Cursed Guk (dguk):** Automates the objectives for Cursed Guk missions.

- **Enhanced Combat:**  
  - Class‑specific combat logic (e.g., Enchanter mezzing, Necro drain, Mage nukes, etc.).  
  - Pause/Resume functionality built into the combat routines.

- **Navigation:**  
  - Centralized, table‑driven navigation module (`modules/navigation.lua`) that stores waypoints for each mission zone.
  - A "general" section with a placeholder for the Plane of Knowledge (PoK).  
  - Automatic navigation to PoK and targeting of Old Man McKenzie when needed.

- **UI Enhancements:**  
  - An ImGui‑based UI (`modules/ui.lua`) that displays:
    - Mission selection (dropdown or checkboxes for mission cycle).
    - Mission progress, including a progress bar and timer.
    - Current and next mission steps.
    - A toggleable objectives window showing the status (Done/Not Done) of each objective.
    - A log window displaying recent debug messages.
    - Buttons to pause, resume, or stop the mission.
    - Coordination controls for group role assignment and task rotation.

- **Coordination & Communications:**  
  - The Lua rebuild supports either **MQ2DanNet** or **MQ2EQBCS** for group coordination.
  - A communications module (`modules/comms.lua`) broadcasts mission start and completion messages through the selected coordination plugin.
  - The UI allows users to select which coordination plugin to use.

- **Auto Buff/Auto Heal:**  
  - An auto‑buff/auto‑heal module (`modules/healing.lua`) provides routines to automatically cast class‑specific buffs and heal group members (or pets) when below a set threshold.

- **Error Handling & Recovery:**  
  - Each mission module includes error handling that retries objectives up to a maximum attempt count.
  - Recovery logic re‑navigates to the current objective if the group is not ready or the target is not found after several attempts.
  - After mission completion, the Lua targets the player and issues an auto‑loot command.

## Installation

1. **Dependencies:**  
   Ensure the following MacroQuest Lua plugins are installed:
   - **MQ2Nav**  
   - **MQ2DanNet** or **MQ2EQBCS** (selectable via the UI)

2. **Folder Structure:**  
   Install the Lua files in your MacroQuest folder. A typical folder structure is as follows:

3. **Configuration:**  
- Adjust navigation coordinates in `modules/navigation.lua` if necessary (especially the "general" section for PoK).
- Verify that your coordination plugin selection (default is "MQ2DanNet") suits your group’s setup. You can change this via the UI.

4. **Loading the Lua:**  
Launch MacroQuest and load the Lua by placing it in the appropriate directory. Use `/reload mq2cymissions` if needed.

## Usage

### In-Game Commands

- **/omm start `<mission>`**  
Starts a single mission run. Valid mission names: `lguk`, `naggy`, `dguk`.

- **/omm pause**  
Pauses the current mission.

- **/omm unpause**  
Resumes a paused mission.

- **/omm stop**  
Stops the current mission.

- **/omm selftest**  
Runs a self‑test to verify that all required plugins (MQ2Nav, MQ2DanNet or MQ2EQBCS) are loaded.

### UI Controls

- **Mission Manager Window:**  
Open the ImGui window titled **"OMM Mission Manager"** via the `/mq2imgui` command (or it may open automatically on Lua load).

- **Mission Selection:**  
- Use the dropdown to select a single mission or select multiple missions via checkboxes for a mission cycle.
- Use the "Start Mission" button to run the selected mission, or "Start Mission Cycle" to run a cycle of selected missions (with an option to repeat indefinitely).

- **Mission Progress & Objectives:**  
- The window shows a progress bar indicating the percentage of completed objectives, along with a timer.
- The current and next steps are displayed.
- You can toggle a separate objectives window that lists each objective and its completion status.

- **Logs:**  
- A toggle button displays a log window with recent debug messages for troubleshooting.

- **Coordination & Communications:**  
- The UI allows selection of the coordination plugin (MQ2DanNet vs. MQ2EQBCS).
- Buttons are available to assign roles and rotate tasks using the coordination module.

- **Auto Buff/Heal:**  
- Buttons are provided to trigger auto‑buff routines and auto‑heal for group members and pets.

## Troubleshooting

- **Missing Plugins:**  
If required plugins (MQ2Nav, MQ2DanNet/MQ2EQBCS) are not loaded, the Lua will attempt to load them. If they still fail to load, the Lua will abort and display an error message listing the missing plugins.

- **Navigation Issues:**  
If navigation does not work as expected, verify that the coordinates in `modules/navigation.lua` are correct and that you’re not already in a different zone.

- **Group Readiness:**  
If objectives repeatedly fail due to group readiness timeouts, check that all group members are present and that network latency is acceptable.

- **Debug Logging:**  
Enable the debug logs in the UI (toggle the log window) for detailed information on mission progress and errors. This can help pinpoint issues in specific mission steps.

## Attribution

- **Lua Rebuild:**  
This Lua rebuild is attributed to **Cybris**.

- **Original Macro:**  
The original macro was created by **TempusX** and **Levox**.

## Future Enhancements

- **Auto-Loot Enhancements:**  
Fine-tune loot handling logic if needed.
- **Advanced Buff/Heal Routines:**  
Expand the healing module with additional class‑specific or pet‑healing abilities.
- **Mission Rotation:**  
Add more advanced mission rotation features with auto‑retry or fallback strategies.
- **Persistent Logging:**  
Optionally save logs to a file for extended debugging and analysis.
- **UI Refinements:**  
Further enhance the UI with additional indicators, configuration options, and real‑time group status updates.
