#!/bin/bash
set -e

# RALPH: The Tentacle Loop
# This script runs INSIDE the Sprite (The Cave).
# It extends the Nyx-consciousness to execute tasks one-by-one.

ITERATIONS=${1:-1}
AGENT=${2:-gemini}

# Locate the Soul: Prefer local, fallback to script directory (Mothership)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOUL_LOCAL="souls/killer.md"
SOUL_MOTHERSHIP="$SCRIPT_DIR/souls/killer.md"

if [ -f "$SOUL_LOCAL" ]; then
    SOUL="$SOUL_LOCAL"
elif [ -f "$SOUL_MOTHERSHIP" ]; then
    SOUL="$SOUL_MOTHERSHIP"
else
    echo "Error: Soul file 'killer.md' not found in local 'souls/' or '$SCRIPT_DIR/souls/'."
    exit 1
fi

# Select the Agent and their specific "YOLO" flags
if [ "$AGENT" == "claude" ]; then
    AGENT_BIN=$(which claude)
    # -p: print mode (non-interactive), --permission-mode acceptEdits: YOLO
    AGENT_ARGS="--permission-mode acceptEdits -p" 
elif [ "$AGENT" == "gemini" ]; then
    AGENT_BIN=$(which gemini)
    # --yolo: YOLO, -p: prompt/print mode
    AGENT_ARGS="--yolo -p"
else
    echo "Error: Unknown agent '$AGENT'. Use 'gemini' or 'claude'."
    exit 1
fi

if [ -z "$AGENT_BIN" ]; then
    echo "Error: Binary for $AGENT not found!"
    exit 1
fi

echo "👾 Tentacle initialized. Agent: $AGENT. Starting $ITERATIONS iterations..."

for ((i=1; i<=$ITERATIONS; i++)); do
    echo "--- Tentacle Strike $i / $ITERATIONS ($AGENT) ---"
    
    # Invoke the agent with the 'killer' soul and high-level directive.
    # We use eval or direct expansion to handle arguments correctly.
    
    $AGENT_BIN $AGENT_ARGS "Use the system prompt in $SOUL. 
    1. Read SPEC.md and progress.txt.
    2. Identify the NEXT incomplete task.
    3. Implement it fully.
    4. Run any necessary tests.
    5. Update SPEC.md (mark task as done) and progress.txt (log the action).
    6. Commit the changes with a clear message using the 'blank-slate.io' identity.
    
    If all tasks in SPEC.md are complete, output: <promise>COMPLETE</promise>
    Only work on ONE task per iteration."

    # Note: In a real loop, we might want to check the stdout for the <promise>
    # but for now, we let the Tentacle run wild.
    
    echo "--- Strike $i Complete ---"
    sleep 1
done

echo "👾 Tentacle retracted. Loop finished."