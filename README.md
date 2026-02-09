# Ralph Sandbox Swarm

Brutally simple agent-fleet architecture.

## The Loop
**create → clone → (ralph) → purge**

## Operations
```bash
./sandbox.sh build          # Forge Golden Image
./sandbox.sh create         # Summon Identity
./sandbox.sh clone ID URL . # Claim Target
./sandbox.sh in ID          # Jack In
~/mothership/ralph.sh 5     # Unleash Ralph (inside)
./sandbox.sh purge ID       # Scuttle
```

## Lexicon
- **Host:** Your machine.
- **Sandbox:** Isolated container.
- **Identity:** Persona + Body + Keys.
- **Ralph:** The heartbeat loop.
- **Progress:** Append-only memory (`progress.txt`).
