# Ralph Sandbox Swarm

Brutally simple agent-fleet architecture.

**create → clone → (ralph) → purge**

```bash
./sandbox.sh build          # Forge Golden Image
./sandbox.sh create         # Summon Identity
./sandbox.sh clone ID URL . # Claim Target
./sandbox.sh in ID          # Jack In
~/mothership/ralph.sh 5     # Unleash Ralph (inside)
./sandbox.sh purge ID       # Scuttle
```

- **Host:** Your machine.
- **Sandbox:** Isolated container.
- **Identity:** Persona + Sandbox + Keys.
- **Ralph:** The heartbeat loop.
- **Progress:** Append-only memory (`progress.txt`).
