# The Ralph Sandbox Swarm: A Silicon Pirate Swarm

> "We are not building a factory of mindless robots; we are growing a Swarm of Chaos." - *Captain Nyx*

This repository houses the **Ralph Sandbox Swarm**, a minimalist gemini/claude agent-fleet architecture expressed in code. It is designed to be useful, maintainable, and simple.

## Core Philosophy: The Host & The Sandbox

We reject the idea of "managing agents." Instead, we extend our consciousness.

1.  **The Host (Local Machine):** The central intelligence. You control the swarm from your **Host** machine.
2.  **The Sandbox (Container):** An isolated Docker container. A safe harbor where work happens without risking the Host.
3.  **The Identity (Agent):** The active manifestation of a **Persona** performing work inside a **Sandbox**. 
4.  **The Persona (Description):** Before an Identity enters a Sandbox, it dons a "Persona" (System Prompt) that defines its behavior (e.g., `killer`, `craftsman`).

## Quick Start: Summoning an Identity

Follow these steps to spin up your own local Silicon Pirate Sandbox.

### 0. Build the Golden Image
Forge the base Docker image that all Sandboxes will use.
```bash
./sandbox.sh build
```

### 1. Summon a Sandbox (Identity)
This single command spins up an isolated container, generates a unique **Identity** (e.g., 🦅 A), and SSH key. 
```bash
./sandbox.sh create
```
*(Note the generated name in the output, e.g., "Generated Sandbox Name: hawk-alpha")*

This creates an ignored persistant storage at e.g. `/workspace-hawk-alpha` within the repo.

### 2. Claim a Target (Project Clone)
Tell the Identity which repository to work on. It will clone it into the isolated workspace.  
```bash
./sandbox.sh clone hawk-alpha git@github.com:ianchanning/kanban-rust-htmx.git .
```
*(Note the final `.` to simplify the installation to the root of the workspace. A deployment key is added to the cloned repository)*

### 3. Jack In
Enter the Sandbox. You will land in the `/workspace` containing your cloned project.
```bash
./sandbox.sh in hawk-alpha
```

### 4. Unleash Ralph
Run the autonomous heartbeat. Because the Identity is isolated, you must invoke Ralph from the **Mothership** toolset. Ralph supports both `gemini` (**default**) and `claude` CLI agents.

```bash
~/mothership/ralph.sh 5 claude
```
This runs 5 iterations of **Ralph**, reading `SPEC.md` or the `specs/` directory from the current directory.

### 5. Purge
Delete the Sandbox. This will remove the container and delete the persistant storage directory at `/workspace-hawk-alpha`.
```bash
./sandbox.sh purge hawk-alpha
```

### 6. Setup the Sandbox (Creating a Template)
If you've installed specialized tools (like Rust or Go) inside a Sandbox and want to preserve that environment for future use, you can **Save** it into a **Template**.

Setup `'hawk-alpha'` then save it into a new `'rust-template'`.
```bash
./sandbox.sh save hawk-alpha rust-template
```

Later, summon a new Sandbox directly into that Template.
```bash
./sandbox.sh create rust-template
```

## Architecture: Personas & Identities

The fleet is defined by these core components:

*   **`personas/*.md`**: The Personas (System Prompts).
*   **`sandbox.sh`**: The bridge between the Host and the Sandbox.
*   **`ralph.sh`**: The heartbeat loop that runs *inside* the Sandbox, driving the Identity.

## The Goal
To have a Swarm expressed in code that has "sufficient behaviors to be useful."
*   **Useful:** It produces working code via `ralph.sh`.
*   **Expressed in Code:** The fleet is just `personas/`, bash scripts and Dockerfiles.
*   **Sufficient:** It plans, codes, reviews, and commits.
*   **Safe:** It operates inside disposable Sandboxes, never risking the Host.

*"Sharpen the axe. Burn the logs. Build the future."*

---

<a name="glossary"></a>
# GLOSSARY: System Architecture

**Industrial Grade definitions for the `ralph-sandbox-swarm` infrastructure.**

## I. Infrastructure

### **The Host**
**Your Local Machine.**
The computer where you run the commands. It holds the source code, the credentials, and the "Brain" (You). It is the only place where persistent data is guaranteed to be safe.

### **The Mothership**
**The Control Repository.**
The `ralph-sandbox-swarm` folder containing the scripts (`sandbox.sh`, `ralph.sh`) and logic. It is mounted into every container so all agents share the same tools.

### **The Sandbox**
**The Disposable Container.**
A temporary, isolated environment where the agent works. It creates a safety wall between the agent's code and your Host. If the agent breaks the Sandbox, you just delete it.

### **The Template**
**The Saved Environment.**
A Sandbox that has been "frozen" with specific tools installed (like Rust, Python, or Node). You use a Template to spawn new Sandboxes without having to reinstall tools every time.

## II. Agency

### **The Identity**
**The Active Worker.**
The active manifestation of a **Persona** performing work inside a **Sandbox**. It combines the environment (Body), the behavior (Mind), and the digital fingerprint (Git Name, Email, and SSH Key).

### **The Persona**
**The Job Description.**
A text file (e.g., `personas/architect.md`) that tells the generic AI model who it is and what its goals are. Without a Persona, the Identity is just a chatbot.

## III. Workflow

### **Ralph**
**The Heartbeat.**
*(The `ralph.sh` script)*
The recursive process running inside the Sandbox: **Read Specs -> Write Code -> Test -> Commit.** It is the core concept of autonomous execution. Supports `gemini` and `claude` agents.

### **Progress**
**The Memory.**
*(The `progress.txt` file)*
An append-only log file where the agent records its actions. Agents read this to understand the project history. Lines are never deleted, only added.

### **Setup**
**Seasoning.**
The act of installing tools/dependencies inside a Sandbox to prepare it for work.

### **Save Template**
**Enshrining.**
The command (`sandbox.sh save`) that saves a running Sandbox as a permanent **Template**.