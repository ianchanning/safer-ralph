# The Ralph Sandbox Swarm: A Silicon Pirate Swarm

> "We are not building a factory of mindless robots; we are growing a Swarm of Chaos." - *Captain Nyx*

This repository houses the **Ralph Sandbox Swarm**, a minimalist agent-fleet architecture expressed in code. It is designed to be useful, maintainable, and brutally simple.

## Core Philosophy: The Host & The Sandbox

We reject the idea of "managing agents." Instead, we extend our consciousness.

1.  **The Host (Local Machine):** The central intelligence. You orchestrate the swarm from your **Host** machine.
2.  **The Sandbox (Container):** An isolated Docker container. A safe harbor where work happens without risking the Host.
3.  **The Identity (Agent):** The active manifestation of a **Persona** performing work inside a **Sandbox**. 
4.  **The Persona (Description):** Before an Identity enters a Sandbox, it dons a "Persona" (System Prompt) that defines its behavior (e.g., `killer`, `craftsman`).

## Quick Start: Summoning an Identity

Follow these steps to spin up your own local Silicon Pirate Sandbox.

### 1. Build the Golden Image
Forge the base Docker image that all Sandboxes will use.
```bash
./sandbox.sh build
```

### 2. Summon a Sandbox (Identity)
This single command spins up an isolated container, generates a unique **Identity** (e.g., 🦅 A), and uploads the SSH key to GitHub. 
```bash
./sandbox.sh create
```
*(Note the generated name in the output, e.g., "Generated Sandbox Name: scorpion-alpha")*

### 3. Setup the Sandbox (Creating a Template)
If you've installed specialized tools (like Rust or Go) inside a Sandbox and want to preserve that environment for future use, you can **Save** it into a **Template**.
```bash
# Setup 'scorpion-alpha' then save it into a new 'rust-template'
./sandbox.sh save scorpion-alpha rust-template

# Later, summon a new Sandbox directly into that Template
./sandbox.sh create rust-template
```

### 4. Claim a Target (Project Clone)
Tell the Identity which repository to work on. It will clone it into the isolated workspace.
```bash
./sandbox.sh clone scorpion-alpha git@github.com:ianchanning/kanban-rust-htmx.git
```

### 5. Jack In
Enter the Sandbox. You will land in the `/workspace` containing your cloned project.
```bash
./sandbox.sh in scorpion-alpha
```

### 6. Unleash Ralph
Run the autonomous heartbeat. Because the Identity is isolated, you must invoke Ralph from the **Mothership** toolset.
```bash
# Inside the container
~/mothership/ralph.sh 5
```
This runs 5 iterations of **Ralph**, reading `SPEC.md` or the `specs/` directory from the current directory.

## Architecture: Personas & Identities

The fleet is defined by these core components:

*   **`personas/*.md`**: The Personas (System Prompts).
*   **`sandbox.sh`**: The bridge between the Host and the Sandbox.
*   **`ralph.sh`**: The heartbeat loop that runs *inside* the Sandbox, driving the Identity.

## Key Files

*   **`SPEC.md` (or `specs/`)**: The technical specification and requirements. The Identities read this to know what to build.
*   **`progress.txt`**: **Progress**. The record of what has been accomplished. **MANDATORY: APPEND ONLY.**
*   **`GLOSSARY.md`**: The technical definitions of the system.

## The Goal
To have a Swarm expressed in code that has "sufficient behaviors to be useful."
*   **Useful:** It produces working code via `ralph.sh`.
*   **Expressed in Code:** The fleet is just `personas/` and bash scripts.
*   **Sufficient:** It plans, codes, reviews, and commits.
*   **Safe:** It operates inside disposable Sandboxes, never risking the Host.

*"Sharpen the axe. Burn the logs. Build the future."*