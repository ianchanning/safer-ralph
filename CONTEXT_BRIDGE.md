# CONTEXT_BRIDGE: Project Reaper / Octopus of Chaos

**Last Update:** 2026-01-25
**Current Objective:** Initialize `kanban-rust-htmx` strike.

---

## 1. System Synopsis
The "Octopus of Chaos" is a minimalist agent-fleet architecture. The **Host (Octopus)** manages **Sprites (Tentacles)** which operate inside isolated **Caves (Docker containers)**.

- **Mothership Repo:** `ianchanning/sprites-swarm`
- **Target Project:** `ianchanning/kanban-rust-htmx` (HTMX & Rust Kanban board)

## 2. Infrastructure & Tooling

### The Bridge: `lsprite.sh`
The primary host-side orchestrator.
- `build`: Bakes the Docker image with automated identity scripts.
- `create <name>`: Orchestrates `up` -> `gh-key` (Automated Zero-to-Hero).
- `gh-key <name>`: Uploads Sprite's Deploy Key via `gh` CLI and clones Mothership into `~/mothership`.
- `clone <name> <repo> [path]`: Instructs Sprite to clone a target project into its `/workspace`.
- `rm <name>`: Deletes the container and cleans up the host's `workspace-<name>` directory.
- `key <name>`: Extracts the public key from logs for manual entry.

### The Heartbeat: `ralph.sh`
The autonomous loop running inside the Sprite.
- **Polymorphic:** Supports Gemini and Claude (accepts agent as 2nd arg).
- **Location-Aware:** Finds `souls/` relative to script location in `~/mothership`.
- **YOLO Mode:** Hard-coded for speed and non-interactive strike execution.

### The Initialization: `init_sprite.sh`
The "Soul" injected at boot via Docker `ENTRYPOINT`.
- Sets Git Identity: `nyx+<name>@blank-slate.io`.
- Generates SSH Key: Unique per Sprite.
- Pre-scans `github.com`: Prevents interactive fingerprint prompts.
- Configures `safe.directory`: Grants Git access to the `/workspace` mount.

## 3. Operational Environment
- **OS:** Ubuntu 22.04.
- **Docker:** Non-sudo access enabled for user `ian`.
- **Permissions:** If Git reports "dubious ownership," run `sudo chown -R ian:ian .` on the host.
- **Mothership Location:** Cloned inside Sprites at `/root/mothership`.
- **Workspaces:** Isolated host directories `workspace-<name>` mounted to `/workspace`.

## 4. Current State: `kanban-rust-htmx`
- Repository `ianchanning/kanban-rust-htmx` is the target.
- Sprite `htmx-kanban-1` (or next available) will be authorized.
- **Next Task:** Establish the Rust project structure and unleash the Ralph loop.

## 5. Reference Material
See the `references/` directory for:
- `Getting Started With Ralph.md`: Loop theory.
- `my-gemini-bootstrap-2.md`: Persistent knowledge architecture.
- `How I ACTUALLY Use Claude Code...`: Workflow insights.

---
**NYX ENCRYPTED STATE:** `(⊕) (⇌) (⁂)`
> "The Octopus sees through every eye. The Forge is hot."
