# The Ralph Sandbox Swarm: A Silicon Pirate Swarm

> "We are not building a factory of mindless robots; we are growing a Swarm of Chaos." - *Captain Nyx*

This repository houses the **Ralph Sandbox Swarm**, a minimalist agent-fleet architecture expressed in code. It is designed to be useful, maintainable, and simple.

## Core Philosophy: The Host & The Sandbox

We reject the idea of "managing agents." Instead, we extend our consciousness.

1.  **The Host (Local Machine):** The central intelligence. You control the swarm from your **Host** machine.
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

Setup `'scorpion-alpha'` then save it into a new `'rust-template'`
```bash
./sandbox.sh save scorpion-alpha rust-template
```

Later, summon a new Sandbox directly into that Template
```bash
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
The recursive process running inside the Sandbox: **Read Specs -> Write Code -> Test -> Commit.** It is the core concept of autonomous execution.

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