# GLOSSARY: System Architecture

**Industrial Grade definitions for the `ralph-sandbox-swarm` infrastructure.**

## I. Infrastructure

### **The Host**
**Your Local Machine.**
The computer where you run the commands. It holds the source code, the credentials, and the "Brain" (You). It is the only place where persistent data is guaranteed to be safe.

### **The Mothership**
**The Control Repository.**
The `ralph-sandbox-swarm` folder containing the scripts (`lsprite.sh`, `ralph.sh`) and logic. It is mounted into every container so all agents share the same tools.

### **The Sandbox**
**The Disposable Container.**
*(formerly "Cave")*
A temporary, isolated environment where the agent works. It creates a safety wall between the agent's code and your Host. If the agent breaks the Sandbox, you just delete it.

### **The Template**
**The Saved Environment.**
*(formerly "Lair" / Docker Image)*
A Sandbox that has been "frozen" with specific tools installed (like Rust, Python, or Node). You use a Template to spawn new Sandboxes without having to reinstall tools every time.

## II. Agency

### **The Sprite**
**The Active Worker.**
The running combination of a **Sandbox** (Body) + **Persona** (Mind). It is the entity that actually performs the work.

### **The Persona**
**The Job Description.**
*(formerly "Soul" - stored in `souls/`)*
A text file (e.g., `souls/architect.md`) that tells the generic AI model who it is and what its goals are. Without a Persona, the Sprite is just a chatbot.

### **The Identity**
**The Digital Fingerprint.**
*(formerly "Sigil")*
The Git Name, Email, and SSH Key assigned to a specific Sprite. It ensures every line of code can be traced back to the specific agent that wrote it.

## III. Workflow

### **Ralph**
**The Heartbeat.**
*(The `ralph.sh` script)*
The recursive process running inside the Sprite: **Read Specs -> Write Code -> Test -> Commit.** It is the core concept of autonomous execution.

### **Progress**
**The Memory.**
*(The `progress.txt` file, formerly "The Ledger")*
An append-only log file where the agent records its actions. Agents read this to understand the project history. Lines are never deleted, only added.

### **Setup**
**Seasoning.**
The act of installing tools/dependencies inside a Sandbox to prepare it for work.

### **Save Template**

**Enshrining.**

The command (`lsprite.sh save`) that saves a running Sandbox as a permanent **Template**.
