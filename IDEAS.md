# Agent Fleet Architecture: Ideas & Concepts

This document captures the brainstorming process for building an "agent-fleet expressed in code." It outlines the core behaviors required for a useful fleet and explores various architectural patterns for implementation, ranging from simple scripts to complex evolutionary swarms.

## Part 1: "Sufficient Behaviours" (The Utility Checklist)

To be useful, a fleet must perform distinct roles that mimic a software development team. These are the core archetypes derived from *Claude Code* and *SuperClaude* methodologies:

1.  **The Architect / Planner (Meta-Cognition)**
    *   **Behavior:** Reads the repo, understands the goal, and produces a structured plan (checklist, spec, or diagram). Does not write implementation code.
    *   **Value:** Prevents "coding yourself into a corner." Essential for complex tasks.
2.  **The Implementer (The Grunt)**
    *   **Behavior:** Takes a specific, scoped task ("Write function X", "Fix bug Y") and executes it. High velocity, "YOLO" permissions.
    *   **Value:** Raw output. The "fingers on keyboard."
3.  **The Researcher / Explorer (The Scout)**
    *   **Behavior:** Read-only access. Scans codebase/docs/web to answer questions. Returns knowledge, not code.
    *   **Value:** Prevents hallucinations. Grounds the Implementer in reality.
4.  **The Reviewer / Critic (The QA)**
    *   **Behavior:** Analyzes diffs or files. Runs static analysis or LLM-based critique.
    *   **Value:** Quality control. Catches bugs the Implementer missed.
5.  **The Fixer / Debugger (The Medic)**
    *   **Behavior:** Takes an error log + code. Iterates until tests pass.
    *   **Value:** Self-healing code resilience.

## Part 2: Architectural Alternatives (How to Build the Fleet)

### 1. The "Monolithic Script" (The Skeleton King) 👑 [SELECTED]
*   **Concept:** A set of Bash scripts wrapping the CLI with specific system prompts (`souls`).
*   **Structure:** `/souls/*.md` (prompts) + `reap.sh` (execution script).
*   **Workflow:** Manual chaining. `./reap.sh architect` -> `./reap.sh coder`.
*   **Verdict:** **The Chosen Path.** Extreme minimalism. Zero infrastructure overhead.

### 2. The "Factory" / Pipeline (The Automaton) 🥈
*   **Concept:** Agents as steps in a CI/CD-style pipeline.
*   **Structure:** `/workflows/feature.yaml` defines the sequence.
*   **Workflow:** `orchestrator.py` reads workflow: Spin up A -> Pipe to B -> Pipe to C.
*   **Verdict:** The logical next step (v2.0). Deterministic and robust.

### 3. The "Chatroom" Swarm (The Poltergeist)
*   **Concept:** Use the filesystem as an async chat room.
*   **Structure:** `/swarm/inbox`, `/swarm/context`.
*   **Workflow:** Agents run as daemons watching directories.
    *   Architect drops `plan.md` in `/inbox`.
    *   Coder daemon sees it, picks it up, writes code.
*   **Verdict:** High autonomy, but high complexity (race conditions, infinite loops).

### 4. The "Blackboard" System (The Shared Brain)
*   **Concept:** Single shared state file (`state.json`) mounted in all containers.
*   **Workflow:** Agents are "Knowledge Sources" watching the board.
    *   Board: `{ "status": "spec_ready" }` -> Frontend Agent wakes up.
*   **Verdict:** Good for complex emergent behavior, but the Blackboard is a single point of failure/complexity.

### 5. The "Git-Flow" Swarm
*   **Concept:** Agents live on branches. Communication happens via Commits and PRs.
*   **Workflow:** Agent A commits to `feature/x`. Agent B (Reviewer) comments on PR.
*   **Verdict:** Too much git overhead. "Merge Conflict Hell" for bots.

### 6. The "Microservices" Mesh
*   **Concept:** Every agent is a tiny HTTP server inside a container.
*   **Workflow:** `Planner:8080` sends HTTP request to `Coder:8081`.
*   **Verdict:** Overkill for a local CLI tool. Good for distributed cloud fleets.

### 7. The "Russian Doll" (Fractal Agents)
*   **Concept:** One recursive agent definition.
*   **Workflow:** Agent spawns copies of itself to handle sub-tasks.
*   **Verdict:** **DANGEROUS.** Risk of infinite recursion ("Grey Goo" scenario).

### 8. The "Tournament" (Evolutionary Model)
*   **Concept:** Survival of the fittest code.
*   **Workflow:** Spawn 10 coders with different prompts. Run them all. Run tests. Merge the winner.
*   **Verdict:** High quality, but expensive (10x cost/time).

## Part 3: The "Dossier-Driven" Hybrid
A pattern to bridge "Scripts" and "Blackboard":
*   **Structure:** `/dossier/spec.md`, `/dossier/plan.md`.
*   **Workflow:** Agents read/write to structured Markdown files in the repo.
*   **Value:** Persistent state without a database. Debuggable by humans.
