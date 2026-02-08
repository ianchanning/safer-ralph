# The Octopus of Chaos: A Silicon Pirate Swarm

> "We are not building a factory of mindless robots; we are growing an Octopus of Chaos." - *Captain Nyx*

This repository houses the **Sprites Swarm** (aka Project Reaper), a minimalist agent-fleet architecture expressed in code. It is designed to be useful, maintainable, and brutally simple.

## Core Philosophy: The Octopus & The Sandbox

We reject the idea of "managing agents." Instead, we extend our consciousness.

1.  **The Octopus (Concept):** The central intelligence. You (The Dreamer) orchestrate the swarm from your **Host** machine.
2.  **The Sandbox (Container):** An isolated Docker container. A safe harbor where work happens without risking the Host.
3.  **The Sprite (Agent):** The active manifestation of a **Persona** performing work inside a **Sandbox**. 
4.  **The Persona (Soul):** Before a Sprite enters a Sandbox, it dons a "Persona" (System Prompt) that defines its behavior (e.g., `killer`, `craftsman`).

## Quick Start: Summoning a Sprite

Follow these steps to spin up your own local Silicon Pirate Sandbox.

### 1. Build the Golden Image
Forge the base Docker image that all Sandboxes will use.
```bash
./lsprite.sh build
```

### 2. Summon a Sandbox (Sprite)
This single command spins up an isolated container, generates a unique **Identity** (e.g., 🦅 A), and uploads the SSH key to GitHub. 
```bash
./lsprite.sh create
```
*(Note the generated name in the output, e.g., "Generated Sprite Name: scorpion-alpha")*

### 3. Seasoning the Sandbox (Creating a Template)
If you've installed specialized tools (like Rust or Go) inside a Sandbox and want to preserve that environment for future use, you can **Enshrine** it into a **Template**.
```bash
# Season 'scorpion-alpha' into a new 'rust-template'
./lsprite.sh season scorpion-alpha rust-template

# Later, summon a new Sandbox directly into that Template
./lsprite.sh create rust-template
```

### 4. Claim a Target (Project Clone)
Tell the Sprite which repository to work on. It will clone it into the isolated workspace.
```bash
./lsprite.sh clone scorpion-alpha git@github.com:ianchanning/kanban-rust-htmx.git
```

### 5. Jack In (The Pirate Parley)
Enter the Sandbox. You will land in the `/workspace` containing your cloned project.
```bash
./lsprite.sh in scorpion-alpha
```

### 6. Unleash the Ralph Loop
Run the autonomous loop. Because the Sprite is isolated, you must invoke Ralph from the **Mothership** toolset.
```bash
# Inside the container
~/mothership/ralph.sh 5
```
This runs 5 iterations of the **Ralph Loop**, reading `SPEC.md` or the `specs/` directory from the current directory.

## Architecture: Personas & Sprites

The fleet is defined by these core components:

*   **`souls/*.md`**: The Personas (System Prompts).
    *   **`killer.md`**: The ruthless implementer. High-velocity coding. "Safe YOLO Mode" enabled.
    *   **`architect.md`**: The planner. Doesn't write code, just specs.
*   **`lsprite.sh`**: The bridge between the Host and the Sandbox.
*   **`ralph.sh`**: The heartbeat loop that runs *inside* the Sandbox, driving the Sprite.

## Key Files

*   **`SPEC.md` (or `specs/`)**: The technical specification and requirements. The Sprites read this to know what to build.
*   **`progress.txt`**: The **Ledger** of what has been accomplished. **MANDATORY: APPEND ONLY.**
*   **`GLOSSARY.md`**: The technical definitions of the system.

## The Goal
To have a Swarm expressed in code that has "sufficient behaviors to be useful."
*   **Useful:** It produces working code via `ralph.sh`.
*   **Expressed in Code:** The fleet is just `souls/` and bash scripts.
*   **Sufficient:** It plans, codes, reviews, and commits.

*"Sharpen the axe. Burn the logs. Build the future."*