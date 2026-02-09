# Safer Ralph

[Ralph](https://ghuntley.com/loop/)... but safer. 

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
- **Sandbox:** Docker (node LTS, claude, gemini, python, SSH key, unique git config, forward port 3000, persistent workspace storage).
- **Identity:** Persona + Sandbox + Keys.
- **Ralph:** The heartbeat loop.
