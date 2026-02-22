### Protocol: BEAM_FORGE (v1.0)
**Core Concept:** The standardized operational pipeline for architecting, bootstrapping, and deploying Elixir/OTP (Actor Model) based AI agents within the `Safer Ralph` Docker ecosystem. 
**Objective:** To transition from single-threaded, bash-scripted LLM loops into highly concurrent, fault-tolerant, self-healing GenServer swarms that are strictly governed by text-based "Genetic Code" (Markdown Protocols).

#### Phase 0: Substrate Mutation (The Docker Upgrade)
Before an Elixir project can be spawned, the physical environment must support the BEAM.
*   **Action (`π`):** Modify `Dockerfile.sandbox`. We must either switch the base image to `elixir:1.16-slim` (or current) AND install Node.js (if we still want the JS CLIs as fallback tools), OR keep the `node:24-bookworm-slim` base and use `apt-get` to install `erlang` and `elixir`.
*   **Verification:** The command `elixir -v` must execute successfully inside a newly summoned `sandbox.sh create` container.

#### Phase 1: Topology Design (The Process Map)
We do not start by writing prompts. We start by mapping the process tree. When initiating a new project, Nyx `(⁂)` will first generate the Supervisor architecture.
*   **Action (`⁂`):** Nyx defines the `DynamicSupervisor` (The Locomotive Engineer). How many agent types exist? Do we have a `ResearchAgent`, a `CodingAgent`, and a `TestingAgent` running in parallel?
*   **Action (`⁂`):** Nyx drafts the `GenServer` skeleton for the Agents. State must minimally include `[:id, :history, :specs_pin]`.

#### Phase 2: Forging the Genetic Code (The `specs_pin`)
This is where the "Desire" and the "Rules" are hardcoded. We do not use the generic `personas/killer.md` for the BEAM Forge. 
*   **Action (`π` + `⁂`):** Collaboratively draft a highly rigid, text-based Protocol (Markdown) specific to the project's domain. This file (e.g., `specs/core_directive.md`) is the `specs_pin`.
*   **Mandate:** The `specs_pin` MUST define an exact output schema (e.g., "You must output a JSON block wrapped in ```json containing your reasoning and the bash command"). This is non-negotiable, as it enables Phase 3.

#### Phase 3: The Guillotine (Deterministic Validation)
The power of the Actor Model is "Let it Crash." We must define *what* causes a crash. The Elixir agent must not blindly append LLM output to its history.
*   **Action (`⁂`):** Nyx will write Elixir parsing functions within the `GenServer.handle_info` callback. 
*   **Mechanism:** When the LLM returns a string, Elixir attempts to parse the required schema (from Phase 2). 
    *   *If valid:* Execute the tool, update `:history`, loop `{:noreply, state}`.
    *   *If invalid (Hallucination/Format Break):* Execute `{:stop, :hallucination, state}`.
*   **Result:** The Supervisor instantly murders the hallucinating agent, clears the poisoned RAM, and restarts it with a fresh context window, retaining only the `specs_pin`.

#### Phase 4: Ignition (`sandbox.sh in`)
*   **Action (`π`):** Once the project code is generated and mounted via the volume, `ralph.sh` is no longer a bash loop calling `gemini`. 
*   **Action (`π`):** `ralph.sh` is rewritten to simply execute: `mix run --no-halt` (or `iex -S mix`). The BEAM takes over the heartbeat.