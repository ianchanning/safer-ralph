---
layout: default
---

<header>
    <h1>Safer Ralph</h1>
    <p class="tagline"><a href="https://ghuntley.com/loop/">Ralph</a>... but safer.</p>
</header>

A bash-based orchestration system for running AI coding agents in Docker containers. 

- **Host:** Your machine.
- **Sandbox:** Docker (node, claude, gemini, python, SSH key, git config, port 3000, persistent  storage).
- **Identity:** Persona + Sandbox + Keys.
- **Ralph:** The heartbeat loop.

<p class="loop">
    <strong>go → (ralph)</strong>
</p>

```bash
./sandbox.sh build          # Forge Golden Image
./sandbox.sh go URL         # Combines create + clone + in
~/mothership/ralph.sh 1     # Unleash Ralph (inside)
```

You can split out `go` into its component parts. 

<p class="loop">
    <strong>create → clone → (ralph) → purge</strong>
</p>

```bash
./sandbox.sh build          # Forge Golden Image
./sandbox.sh create         # Summon Identity
./sandbox.sh clone ID URL . # Claim Target
./sandbox.sh in ID          # Jack In
~/mothership/ralph.sh 5     # Unleash Ralph (inside)
./sandbox.sh purge ID       # Scuttle
```

## Docs

- **Container lifecycle**: `sandbox.sh` handles build/create/up/in/purge/list/save with Docker
- **Identity management**: Animal-NATO naming (hawk-alpha, shark-bravo), unique Ed25519 SSH keys per container, emoji Git identities
- **Agent execution loop**: `ralph.sh` runs inside containers as a heartbeat loop supporting Gemini CLI, Claude Code, and Pi agent (Moonshot)
- **Personas**: Markdown files injected as system prompts ("killer" for YOLO velocity, "step-wise" for single-task precision)
- **Workspace isolation**: Dedicated host directories per container, deploy key injection for GitHub
- **Credential management**: API keys hydrated from env vars on init, never leaked to host

**Architecture choice**: "Monolithic Script" — bash wrapping CLIs with system prompts. Deliberately minimal: zero infrastructure overhead.

**What it doesn't do**: No programmatic SDK integration, no agent-to-agent coordination, no feedback loops beyond ralph.sh iterations, no structured output capture, no state management beyond git commits and progress.txt.

- [Templates](docs/TEMPLATES.md)
- [Deploy Keys](docs/DEPLOY_KEYS.md)
- [Internals](docs/INTERNALS.md)
