# Protocol: RALPH_ALIGNMENT (v1.0)

**Core Concept:** Formalizes the interface between a Project Repository and the Safer Ralph "Mothership." It ensures that every agent "jacking in" has perfect situational awareness and that all environmental gains are persisted across ephemeral container boundaries.

## 1. The Holy Trinity of State
Every project MUST maintain these three files in its root to be "Ralph-Aligned."

1.  **`specs/` (The Intent)**: One markdown file per "Topic of Concern." This is the immutable source of truth for *what* is being built.
2.  **`IMPLEMENTATION_PLAN.md` (The Strategy)**: A prioritized list of tasks derived from the specs. This acts as the "Instruction Pointer" for the loop.
3.  **`AGENTS.md` (The Heart)**: A concise operational guide. Ralph (the harness) will automatically prepend current session context here.

## 2. The Persistence Layer
Because containers are ephemeral, all environment mutations MUST be recorded in the **Safe**.

- **`.env.agent`**: Every `$PATH` change, alias, or environment variable installed by an agent MUST be appended to this file.
- **Protocol**: `echo 'export PATH=$PATH:/new/tool/bin' >> .env.agent`
- **Re-hydration**: `ralph.sh` automatically sources this file at the start of every strike.

## 3. The Handoff Mandate
No agent may exit without leaving a trace. Every `progress.txt` entry and commit message MUST provide clarity for the next "Poor Bastard."

- **Structured Handoff**: Every `progress.txt` entry ends with:
  ```markdown
  ### HANDOFF
  - **TOOLCHAIN**: [Status of compilers/libs]
  - **BLOCKERS**: [What stopped you?]
  - **NEXT STEP**: [The very next command to run]
  ```

## 4. The Forge Signal (`!!NEEDS_SNAPSHOT!!`)
When a machine-intensive state is reached (e.g., 2GB of dependencies installed in `/root`), the agent signals the Human to "Freeze" the state.

- **Marker**: Agent writes `!!NEEDS_SNAPSHOT!!` in `progress.txt`.
- **Human Action**: Run `sandbox.sh save <id> <template_name>`.
- **Outcome**: The next `sandbox.sh go` will use this template, bypassing the install phase.

## 5. Mothership Feedback (The Anti-Fragility Loop)
If an agent discovers a global improvement (a new persona, a better regex, a syscall reference):
- It proposes the change to the `mothership/` directory (if mounted).
- This ensures the Mothership learns from every project it hosts.

**STATUS: RATIFIED. ALL PERSONAS MUST ADHERE TO THIS PROTOCOL.**
