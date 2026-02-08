# CONTEXT_BRIDGE: Ralph Sandbox Swarm

**Last Update:** 2026-02-08
**Current Objective:** Initialize `kanban-rust-htmx` strike.

---

## 1. System Synopsis
The "Ralph Sandbox Swarm" is a minimalist agent-fleet architecture. The **Host** manages **Identities** which operate inside isolated **Sandboxes (Docker containers)**.

- **Mothership Repo:** `ianchanning/ralph-sandbox-swarm`
- **Target Project:** `ianchanning/kanban-rust-htmx` (HTMX & Rust Kanban board)

## 2. Infrastructure & Tooling

### The Bridge: `sandbox.sh`
The primary host-side orchestrator.
- `build`: Bakes the Docker image with automated identity scripts and **NPM cache-busting** for agent tools.
- `create [name]`: Orchestrates `up` -> `gh-key`. Now supports **sequential animal-NATO naming** (e.g., `shark-alpha`, `crocodile-bravo`) if name is omitted.
- `gh-key <name>`: Uploads Identity's Deploy Key via `gh` CLI and clones Mothership into `~/mothership`.
- `clone <name> <repo> [path]`: Instructs Identity to clone a target project into its `/workspace`.
- `purge <name>`: Deletes the container and cleans up the host's `workspace-<name>` directory (Dog-fooded cleanup).
- `list`: Lists all Identities belonging to the swarm.

### The Heartbeat: `ralph.sh`
The autonomous loop running inside the Identity.
- **Polymorphic:** Supports Gemini and Claude.
- **Location-Aware:** Finds `souls/` relative to script location.

## 3. Operational Environment
- **OS:** Ubuntu 22.04.
- **Naming Strategy:** Deterministic sequential NATO indexing based on existing containers.
- **Safety:** Isolated host directories `workspace-<name>` mounted to `/workspace`.

## 4. Current State: `kanban-rust-htmx`
- Repository `ianchanning/kanban-rust-htmx` has been forged.
- Swarm naming sequence reset via mass purge of test sprites.
- **Next Task:** Initiate **Nyx Interview Protocol** in a fresh context to generate `SPEC.md` and `IMPLEMENTATION_PLAN.md` for the Kanban forge.

## 5. Reference Material
See the `references/` directory for:
- `The Ralph Wiggum Loop from 1st principles...`: The blueprint for autonomous development.
- `Getting Started With Ralph.md`: Loop theory.
- `my-gemini-bootstrap-2.md`: Persistent knowledge architecture.

---
**NYX ENCRYPTED STATE:** `(⊕) (⇌) (⁂)`
> "The Octopus sees through every eye. The Forge is ready for the clay."