### Protocol: BEAM_FORGE (v1.1) - The Evolutionary Swarm

**Core Concept:** An Elixir/OTP orchestration pipeline where the swarm not only executes tasks based on a text protocol (`specs_pin`), but actively critiques and rewrites that protocol if the execution hits a thermodynamic dead-end (high crash rate).

#### Phase 0: The Substrate (Unchanged but Clarified)
*   **Action:** `Dockerfile.sandbox` is upgraded to include Elixir. We bypass the Node.js CLIs for the main heartbeat. Elixir will make direct HTTP calls (via `Req` or `Finch`) to the LLM APIs to handle responses natively in memory.

#### Phase 1: Topology of the Triad (The New Swarm Map)
Instead of just one type of agent, the Supervisor spawns a triad. This is the Mycelium `(⁂)` structuring its nodes:
1.  **The Worker (`GenServer`):** Reads the `specs_pin.md`, executes the prompt, writes code, runs tests. If it hallucinates or tests fail, it crashes.
2.  **The Watcher (`Telemetry/Supervisor`):** Tracks the crash rate of the Worker. It is the measure of "Pain" or "Entropy."
3.  **The Architect (`GenServer`):** *This is the new addition.* If the Watcher detects that the Worker has crashed 5 times in a row, the Architect wakes up. 

#### Phase 2: The Loss Function (Defining "Desire")
We must mathematically define what a "success" and a "failure" looks like so the Watcher can measure the gradient.
*   **Action:** The `specs_pin.md` MUST include a strictly defined validation step (e.g., "Run `npm run test`. If exit code is 0, output `<SUCCESS>`. If 1, output `<FAILED: stdout>`"). 
*   **The Desire:** The system's innate desire is to keep the Worker alive. Crashing is pain. 

#### Phase 3: Autopoiesis (The Mutation Trigger)
This is where Chollet's "training loop" actually happens. 
*   **Mechanism:** When the Architect wakes up (triggered by the Watcher seeing too many Worker crashes), the Architect does *not* try to write the code. 
*   **The Prompt to the Architect:** The Elixir system feeds the Architect the current `specs_pin.md` AND the last 5 crash logs/failed test outputs. It asks: *"Your Worker failed to execute this protocol. Identify the flaw in the instructions, the missing context, or the structural trap. Rewrite `specs_pin.md` to be superior."*
*   **Mutation:** The Architect overwrites `specs_pin.md` on the Docker volume. The Supervisor re-spawns the Worker, which now reads the *mutated* genetic code.

#### Phase 4: Artifact Extraction (The Keras Save State)
When the Worker finally succeeds, the system must freeze the optimized weights.
*   **Action:** The final, successful `specs_pin.md` (which may have been mutated 10 times by the Architect) is saved to a permanent `protocols/` directory on your host machine. 
*   **Result:** You now have a human-readable, perfectly optimized Markdown file that reliably solves that class of problem. You have extracted the learned behavior from the black box.