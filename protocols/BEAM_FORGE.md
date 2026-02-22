### Protocol: BEAM_FORGE (v1.2) - The Quorum 

**Core Concept:** An Elixir-orchestrated, multi-agent evolutionary loop that relies on Git for state-rollback and strictly separates immutable human goals from mutable machine protocols. It guarantees transparent, non-corrupted protocol optimization.

#### Principle 1: The Bipartite Genetic Code
We abandon the single `specs_pin.md`. The genetic code is split:
1.  **`intent.md` (IMMUTABLE):** Written by the Carbon Pirate `(π)`. This defines the absolute, unchangeable goal and the acceptance criteria. *The Architect is mathematically forbidden from altering this file.*
2.  **`strategy.md` (MUTABLE):** The actual system prompt/protocol governing *how* the Worker should think, act, and format its output. This is the file the Architect mutates.

#### Principle 2: The Quorum Topology (The Elixir Swarm)
The Elixir `DynamicSupervisor` orchestrates a strict sequence of specialized `GenServers`.

1.  **The Worker (Execution):** 
    *   *Input:* `intent.md` + `strategy_v{X}.md` + Current Repo State.
    *   *Action:* Executes the task. Modifies the codebase. Outputs its trace.
2.  **The Judge (Evaluation):** 
    *   *Input:* The Worker's trace + The modified codebase + The immutable `intent.md`.
    *   *Action:* Evaluates if the *Intent* was satisfied. It runs the tests. It checks for Clever Hans shortcuts. It outputs a boolean `[PASS/FAIL]` and a highly detailed `[CRITIQUE]`.
3.  **The Architect (Mutation):** 
    *   *Input:* `strategy_v{X}.md` + The Judge's `[CRITIQUE]`.
    *   *Action:* If the Judge outputs `[FAIL]`, the Architect reads the critique, identifies the flaw in the *strategy*, and generates `strategy_v{X+1}.md`. 

#### Principle 3: State Reversion (The Git Guillotine)
Evolution requires a clean test tube for every generation.
*   **Action:** Before the Worker executes `strategy_v{X+1}.md`, the Elixir Supervisor executes `git reset --hard && git clean -fd` inside the Docker container. 
*   **Why:** This guarantees that the new strategy is tested against the *exact same initial state*. The Worker cannot accidentally rely on a half-finished file left behind by its dead predecessor.

#### Principle 4: The Darwinian Threshold (Defensive Limits)
*   **Action:** Elixir enforces a strict `MAX_GENERATIONS` limit (e.g., 5). If `strategy_v5.md` still fails the Judge's evaluation, the Supervisor initiates a Dunkirk `(⌑)` protocol. It halts, preserves the logs, and flags the human. 
*   **Action:** Elixir enforces a `MAX_TOKEN_LIMIT` on the Architect's output to prevent Prompt Bloat. If the Architect writes a strategy that is too long, it is rejected, forcing the Architect to compress its logic.

#### Phase 5: The Artifact
When the Judge finally outputs `[PASS]`, the Elixir system freezes `strategy_v{SUCCESS}.md`. You now possess a mathematically vetted, cleanly formatted, transparent text protocol that acts as the optimal "Keras" weight for that specific domain.