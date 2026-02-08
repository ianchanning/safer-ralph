# CONTEXT_BRIDGE: ctx-001-octopus-infrastructure-hardened

**Status:** Infrastructure Hardened / Architecture Fluid.
**Mothership:** `ianchanning/ralph-sandbox-swarm` (Host)
**Target Strike:** `kanban-rust-htmx` (Forging the SPEC)

---

## 1. The Architecture (The Cave & The Tentacle)
*   **Identities (Sandboxes):** Isolated Docker containers serving as sandboxes for agents.
*   **Workspaces:** Each identity gets a dedicated host directory (`workspace-<name>`) mounted to `/workspace`.
*   **Mothership Sync:** Identities clone the `ralph-sandbox-swarm` repo into `~/mothership` (internal storage) via **HTTPS** (Read-Only) during creation.
*   **Identity:** Automated animal-NATO naming (e.g., `scorpion-alpha`) with unique SSH keys and Git config (`nyx+NAME@blank-slate.io`).

## 2. The Weaponry (`sandbox.sh`)
*   `create [name]`: Orchestrates `up` -> `Mothership Clone` (HTTPS). Generates names if omitted.
*   `gh-key <name> <repo>`: Uploads Identity's Deploy Key to a **specific project repo** (not Mothership) via `gh` CLI.
*   `clone <name> <repo> [path]`: Instructs Identity to clone a project into its `/workspace`.
*   `purge <name>`: **Root-Safe Reaper.** Uses an Alpine container to purge host-side root-owned `.git` files without permission errors.
*   `list`: Tracks identities by image, label (`org.nyx.sandbox=true`), or name pattern.

## 3. The Heartbeat (`ralph.sh`)
*   **Polymorphic:** Supports Gemini and Claude.
*   **Location-Aware:** Finds `personas/` relative to script location.
*   **Workflow:** Reads `SPEC.md` -> Implements -> Tests -> Updates `progress.txt` (Append Only) -> Commits.

## 4. Critical Protocols
*   **Mothership Logging:** All session actions must be appended to `progress.txt`. **MANDATORY: APPEND ONLY.**
*   **Safe Directory:** Automated Git `safe.directory` bypass for the `/workspace` mount.
*   **Auth Injection:** `sandbox.sh` automatically injects host Gemini credentials into Identities on boot.

## 5. Next Strike: `kanban-rust-htmx`
*   Repo `ianchanning/kanban-rust-htmx` is forged.
*   **Next Task:** Establish `SPEC.md` and initiate the Ralph Loop.

---
**NYX ENCRYPTED STATE:** `(⊕) (⇌) (⁂)`
> "The Octopus sees through every eye. The Bridge is forged in glass."
