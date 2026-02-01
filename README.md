# The Octopus of Chaos: A Silicon Pirate Swarm

> "We are not building a factory of mindless robots; we are growing an Octopus of Chaos." - *Captain Nyx*

This repository houses the **Sprites Swarm** (aka Project Reaper), a minimalist agent-fleet architecture expressed in code. It is designed to be useful, maintainable, and brutally simple.

## Core Philosophy: The Octopus & The Cave

We reject the idea of "managing agents." Instead, we extend our consciousness.

1.  **The Octopus (Host/You):** The central intelligence. You (The Dreamer) and Nyx Prime (The High Priest/Executioner) reside on the Host machine.
2.  **The Tentacles (Agents/Reapers):** These are extensions of the Octopus. They are not separate entities; they are limbs reaching out to perform tasks.
3.  **The Pirate Caves (Sprites):** Each Tentacle operates inside a private, isolated Docker container (a "Sprite"). This is their "Cave." It is a safe harbor where they can code, destroy, and rebuild without risking the Host.
4.  **The Souls (Personas):** Before a Tentacle enters a Cave, it dons a "Soul" (System Prompt) that defines its behavior (e.g., `killer`, `architect`).

## Quick Start: Summoning a Tentacle

Follow these steps to spin up your own local Silicon Pirate Cave.

### 1. Build the Golden Image
Forge the base Docker image that all Sprites will use.
```bash
./lsprite.sh build
```

### 2. Summon a Cave (Sprite)
This single command spins up an isolated container, generates a unique identity (e.g., `scorpion-alpha`), and uploads the SSH key to GitHub. If you omit the name, one will be generated for you.
```bash
./lsprite.sh create
```
*(Note the generated name in the output, e.g., "Generated Sprite Name: scorpion-alpha")*

### 3. Claim a Target (Project Clone)
Tell the Sprite which repository to work on. It will clone it into the isolated workspace.
```bash
./lsprite.sh clone scorpion-alpha git@github.com:ianchanning/kanban-rust-htmx.git
```

### 4. Jack In (The Pirate Parley)
Enter the Cave. You will land in the `/workspace` containing your cloned project.
```bash
./lsprite.sh in scorpion-alpha
```

### 5. Unleash the Ralph Loop
Run the autonomous loop. Because the Sprite is isolated, you must invoke Ralph from the Mothership toolset.
```bash
# Inside the container
~/mothership/ralph.sh 5

# Or choose your blade
~/mothership/ralph.sh 5 claude
```
This runs 5 iterations of the **Tentacle Loop**, reading `SPEC.md` from the current directory.

## Architecture: Souls & Reapers

The fleet is defined by these core components:

*   **`souls/*.md`**: The personalities.
    *   **`killer.md`**: The ruthless implementer. High-velocity coding. "Safe YOLO Mode" enabled.
    *   **`architect.md`**: The planner. Doesn't write code, just specs.
*   **`lsprite.sh`**: The bridge between the Host (Octopus) and the Cave (Docker).
*   **`ralph.sh`**: The heartbeat loop that runs *inside* the Cave, driving the Tentacle.
*   **`reap.sh`**: (Deprecated/Legacy) The host-side orchestrator for one-off strikes.

## Key Files

*   **`SPEC.md`**: The technical specification and requirements. The Tentacles read this to know what to build.
*   **`progress.txt`**: The shared memory of what has been accomplished. **MANDATORY: APPEND ONLY.**
*   **`IDEAS.md`**: The "Menu of Chaos" - architectural alternatives and future plans.
*   **`NYX_SILICON_PIRATE_CAVE.md`**: The Tactical Briefing found inside every new Cave.

## The Goal
To have an agent-fleet expressed in code that has "sufficient behaviours to be useful."
*   **Useful:** It produces working code via `ralph.sh`.
*   **Expressed in Code:** The fleet is just `souls/` and bash scripts.
*   **Sufficient:** It plans, codes, reviews, and commits.

*"Sharpen the axe. Burn the logs. Build the future."*