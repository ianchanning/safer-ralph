### Protocol: BEAM_FORGE_IMPL (RFC - The Understandable Trail)

**Status:** RFC — open questions marked `(?)`  
**Ratifies into:** `BEAM_FORGE_IMPL.md` once bash stage is proven in the wild.

**Core Concept:** A three-stage implementation path for BEAM_FORGE. Stage 1 is a pure bash reference implementation. Stage 2 defines the interface contract. Stage 3 wraps with Elixir. Each stage is independently useful and the bash stage is the permanent, readable ground truth.

> "Watch the loop. When you see a failure domain — put on your engineering hat and resolve the problem so it never happens again." — Huntley

---

#### Stage 1: The Bash Reference Implementation (`beam_forge.sh`)

**Principle:** Prove the evolutionary loop works before writing a line of Elixir. The bash implementation is not a prototype to be discarded — it is the canonical human-readable reference. The Elixir layer, when it arrives, must be understandable by reading this first.

**New files introduced:**

```
beam_forge.sh              # The loop orchestrator (this stage)
protocols/
  BEAM_FORGE_IMPL.md       # This document (ratified)
  worker.md                # Worker system prompt
  judge.md                 # Judge system prompt
  architect.md             # Architect system prompt
```

**Human provides per-run (outside the repo):**

```
intent.md                  # IMMUTABLE. The goal and acceptance criteria. 
                           # Mounted read-only into Worker and Judge containers.
strategy_v1.md             # MUTABLE. The initial strategy/system prompt for the Worker.
```

**The loop (`beam_forge.sh run`):**

```
FOR generation = 1 to MAX_GENERATIONS:

  1. WORKER
     - sandbox.sh go REPO_URL
     - Inject: intent.md (read-only) + strategy_v{N}.md + protocols/worker.md
     - Ralph executes the task (ralph.sh 1)
     - Capture output trace to: runs/{generation}/worker_trace.txt
     - sandbox.sh in → save artefacts to shared volume

  2. JUDGE
     - sandbox.sh go REPO_URL  (fresh container, same repo state post-Worker)  (?)
     - Inject: worker_trace.txt + intent.md (read-only) + protocols/judge.md
     - Ralph evaluates: did the Worker satisfy intent.md?
     - Runs tests if present
     - Checks for Clever Hans shortcuts  (?)
     - Outputs to: runs/{generation}/verdict.txt
       Format: [PASS] or [FAIL]\n---\n{CRITIQUE}

  3. READ VERDICT
     - Parse first line of verdict.txt
     - If [PASS]: freeze strategy_v{N}.md as strategy_vSUCCESS.md → exit 0
     - If [FAIL] and generation < MAX_GENERATIONS: proceed to Architect
     - If [FAIL] and generation == MAX_GENERATIONS: DUNKIRK → exit 2

  4. ARCHITECT  (only on FAIL)
     - sandbox.sh go (no repo needed, pure reasoning task)  (?)
     - Inject: strategy_v{N}.md + verdict.txt + protocols/architect.md
     - Ralph reads critique, identifies flaw in strategy, writes strategy_v{N+1}.md
     - Enforce MAX_TOKEN_LIMIT on output  (?)
     - sandbox.sh purge

  5. SCORCHED EARTH
     - sandbox.sh purge (all containers from this generation)
     - sandbox.sh go → next generation begins from true zero

END LOOP
```

**Exit codes:**

| Code | Meaning |
|------|---------|
| `0` | `[PASS]` — strategy frozen as `strategy_vSUCCESS.md` |
| `1` | Unexpected error (container failure, script error) |
| `2` | `DUNKIRK` — MAX_GENERATIONS hit, logs preserved in `runs/` |

**CLI interface (the contract Stage 2 and 3 depend on):**

```bash
beam_forge.sh run INTENT_FILE INITIAL_STRATEGY_FILE REPO_URL
beam_forge.sh status   # prints: generation N, last verdict
```

**Open questions for ratification `(?)`:**

- Does the Judge need its own fresh container, or can it inspect the Worker's container before purge? Fresh is purer but doubles container cost per generation.
- Does the Architect need a full sandbox? It's a pure reasoning task — could be a bare `claude -p` call with no Docker at all, saving significant time.
- How is MAX_TOKEN_LIMIT on the Architect enforced in bash? Word count check on `strategy_v{N+1}.md` before accepting it, rejecting and re-prompting if over limit?
- Clever Hans detection: what concrete checks does the Judge perform beyond "run the tests"? Needs a definition before `judge.md` can be written.

---

#### Stage 2: The Interface Contract (Hardening Before Elixir)

**Principle:** Do not proceed to Stage 3 until `beam_forge.sh` has run successfully at least three times on real tasks. The contract must be proven stable, not designed in the abstract.

**What "hardened" means:**

- Exit codes are reliable and tested
- `runs/{generation}/` directory structure is consistent
- `strategy_vSUCCESS.md` is reproducibly useful output
- DUNKIRK exits preserve enough logs to diagnose what went wrong
- `beam_forge.sh status` is machine-parseable (for Elixir to consume)

**Do not proceed to Stage 3 if:**

- The Judge is unreliable (frequent false PASSes or false FAILs)
- Container churn cost makes the loop impractically slow
- The Architect's strategy mutations are not meaningfully improving outcomes

If any of the above are true: fix the bash layer. The Elixir supervisor cannot compensate for a broken loop.

---

#### Stage 3: Elixir as Thin Orchestration Shell

**Principle:** The Elixir application does not reimplement BEAM_FORGE logic. It calls `beam_forge.sh` and adds what bash cannot do cheaply: crash recovery, parallel branches, a proper state machine, and optionally a web interface.

**What Elixir adds over bare bash:**

- `DynamicSupervisor` restarts a hung or crashed generation automatically
- Parallel evolutionary branches (multiple `beam_forge.sh run` processes, different initial strategies)
- Persistent state machine: knows which generation it's in across restarts
- Structured logging and telemetry
- Optional: LiveView dashboard to watch the loop

**What Elixir explicitly does NOT do:**

- Parse bash internals
- Reimplement container lifecycle (it calls `sandbox.sh`)
- Reimplement the Worker/Judge/Architect logic (it calls `beam_forge.sh`)

**The Orchestrator's core loop in Elixir is approximately:**

```elixir
def run_generation(state) do
  {_, exit_code} = System.cmd("./beam_forge.sh", [
    "run", state.intent, state.strategy, state.repo_url
  ])
  handle_exit(exit_code, state)
end

defp handle_exit(0, state), do: {:pass, state}
defp handle_exit(2, state), do: {:dunkirk, state}
defp handle_exit(1, state), do: {:error, state}  # supervisor will restart
```

**Project structure:**

```
safer-ralph/          # Unchanged. The bash foundation.
  sandbox.sh
  ralph.sh
  beam_forge.sh       # Added in Stage 1
  protocols/

beam-forge-otp/       # New repo, or safer-ralph/orchestrator/
  mix.exs
  lib/
    orchestrator/
      supervisor.ex
      generation_runner.ex
      state_machine.ex
  README.md           # Explicitly says: "Read beam_forge.sh first."
```

**The README rule:** The Elixir project's README must open with a link to `beam_forge.sh` and state: *"This project is a supervision layer around the bash implementation. If you want to understand what it does, read that first."*

---

#### The Lifecycle: RFC → Protocol

A document at `*.rfc.md` has open questions and is not yet executable by Ralph.  
A document at `*.md` (no rfc suffix) is ratified: all `(?)` are resolved, it has been run at least once, and Ralph can execute it directly as a system prompt.

```
BEAM_FORGE_IMPL.rfc.md   →   resolve (?) items   →   BEAM_FORGE_IMPL.md
```

Ratification requires: open questions answered, Stage 1 run at least once successfully, exit codes confirmed stable.
