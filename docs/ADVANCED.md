# Advanced

This document covers power-user configurations and features for Safer Ralph.

## Global Installation
Make `sandbox.sh` available for other projects by linking it to your local bin:

```bash
# Link to your local bin
mkdir -p ~/.local/bin
ln -s "$(pwd)/sandbox.sh" ~/.local/bin/sandbox.sh

# Ensure ~/.local/bin is in your PATH
export PATH="$HOME/.local/bin:$PATH"
```

## Templates

Snapshot a sandbox to reuse its state later.

### Save a Template
```bash
./sandbox.sh save ID [MY-TEMPLATE]
```
If `MY-TEMPLATE` is omitted, it auto-detects the repository name from the workspace.

### Use a Template
```bash
./sandbox.sh create [MY-TEMPLATE] [NEW-ID]
./sandbox.sh up NEW-ID [MY-TEMPLATE]
```
If `MY-TEMPLATE` is omitted, the script defaults to the base image or auto-detects a matching repository template.

## Persistence & Handoffs

Safer Ralph uses ephemeral containers. This means that if an agent installs a tool (like Rust) or changes a system setting, those changes are **lost** when the container stops, unless they are in the `/workspace` folder.

### The Hotel Room Problem
Think of the container as a hotel room. When an agent leaves, the room is reset. Only the contents of the **Safe** (`/workspace`) are preserved for the next guest.

### 1. Environment Re-hydration (`.env.agent`)
To make tools persist across sessions, agents should save their environment changes (like adding a folder to `$PATH`) to `/workspace/.env.agent`.
- **How it works**: `ralph.sh` automatically "sources" this file at the start of every loop.
- **Example**: `echo 'export PATH=$PATH:/root/.cargo/bin' >> /workspace/.env.agent`

### 2. Session Manifest (`SESSION.md`)
Every time an agent "jacks in," Ralph generates a fresh `/workspace/.system/SESSION.md`.
- **Purpose**: It tells the agent exactly who they are, what tools are currently active, and what the previous agent was doing. This prevents "Hidden State" anxiety and gaslighting.

### 3. The "Forge" Signal (`!!NEEDS_SNAPSHOT!!`)
If an agent does heavy lifting (like a 2GB dependency install) that belongs in the image rather than the workspace:
- They mark `!!NEEDS_SNAPSHOT!!` in `progress.txt`.
- This is a signal to the Human to run `sandbox.sh save` to "freeze" the room state into a new template.

### 4. Structured Handoffs
Agents are instructed to leave a "Handoff" block at the end of their `progress.txt` entries:
```markdown
### HANDOFF
- **TOOLCHAIN**: Rust 1.94 installed.
- **BLOCKERS**: None.
- **NEXT STEP**: Run cargo build.
```
