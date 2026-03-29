# Plan: Safer Ralph Harness Improvements

Goal: Eliminate "Agent Gaslighting" and state-loss by hardening the handoff and persistence mechanisms within the safer-ralph environment.

## 1. Environment Re-hydration (`.env.agent`)
- **Problem**: `$PATH` and environment variables set by one agent (e.g., installing Rust) are lost in the next `ralph.sh` session because they aren't persisted in `/root/.bashrc` across ephemeral containers.
- **Solution**: 
    - Modify `ralph.sh` to automatically source `/workspace/.env.agent` (if it exists) before launching the agent CLI.
    - Instruct agents to append persistent environment changes to this file.
- **Task**: Update `ralph.sh` with the sourcing logic.

## 2. Manifest of Intent (`SESSION.md`)
- **Problem**: Agents have "hidden state" anxiety. They don't know who they are, who was here before, or what the system quirks are.
- **Solution**: 
    - Create a script/function in `ralph.sh` that generates `/workspace/.system/SESSION.md` at the start of every loop.
    - Content: Current Identity (Animal-NATO), Previous Identity (from `progress.txt`), Toolchain paths (Cargo, Go, etc.), and "The Rules" (e.g., /root is ephemeral).
- **Task**: Implement session generation in `ralph.sh`.

## 3. Structured Handoff Protocol
- **Problem**: `progress.txt` is too free-form, leading to missing info about toolchain status or blockers.
- **Solution**: 
    - Update the system instructions (Personas) to mandate a "HANDOFF" block at the end of entries.
    - Include: `TOOLCHAIN STATUS`, `BLOCKERS`, `NEXT STEP`.
- **Task**: Update `personas/killer.md` and `personas/step-wise.md`.

## 4. The Forge Signal (`NEEDS_SNAPSHOT`)
- **Problem**: Agents install heavy dependencies in `/root` that disappear. They need a way to tell the human "FREEZE THIS NOW."
- **Solution**: 
    - Define a standard marker in `progress.txt`: `!!NEEDS_SNAPSHOT!!`.
    - Modify `sandbox.sh` (host-side) to have a `check` or `status` command that alerts the human if this marker is present.
- **Task**: Add marker recognition and a "freeze" workflow hint.

## 5. Local Reference Library
- **Problem**: Wasting tokens on looking up basic system constants (syscall numbers, common errors).
- **Solution**: 
    - Populate `references/syscalls_x86_64.md` and `references/common_errors.md`.
- **Task**: Add these reference files to the mothership.

## Implementation Order
1. **Source `.env.agent`** in `ralph.sh` (Highest impact for persistence).
2. **Generate `SESSION.md`** (Clarity for the agent).
3. **Structured Handoff** in Personas (Consistency).
4. **Reference Docs** (Efficiency).
