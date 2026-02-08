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



*(formerly "Cave")*



A temporary, isolated environment where the agent works. It creates a safety wall between the agent's code and your Host. If the agent breaks the Sandbox, you just delete it.



### **The Template**

**The Saved Environment.**

*(formerly "Lair" / Docker Image)*

A Sandbox that has been "frozen" with specific tools installed (like Rust, Python, or Node). You use a Template to spawn new Sandboxes without having to reinstall tools every time.



## II. Agency



### **The Identity**

**The Active Worker.**

The active manifestation of a **Persona** performing work inside a **Sandbox**. It combines the environment (Body), the behavior (Mind), and the digital fingerprint (Git Name, Email, and SSH Key).



### **The Persona**

**The Job Description.**

*(formerly "Soul")*

A text file (e.g., `personas/architect.md`) that tells the generic AI model who it is and what its goals are. Without a Persona, the Identity is just a chatbot.



## III. Workflow



### **Ralph**

**The Heartbeat.**

*(The `ralph.sh` script)*

The recursive process running inside the Sandbox: **Read Specs -> Write Code -> Test -> Commit.** It is the core concept of autonomous execution.



### **Progress**

**The Memory.**

*(The `progress.txt` file, formerly "The Ledger")*

An append-only log file where the agent records its actions. Agents read this to understand the project history. Lines are never deleted, only added.



### **Setup**

**Seasoning.**

The act of installing tools/dependencies inside a Sandbox to prepare it for work.



### **Save Template**

**Enshrining.**

The command (`sandbox.sh save`) that saves a running Sandbox as a permanent **Template**.


