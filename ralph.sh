#!/bin/bash
set -e

# RALPH: The Heartbeat Loop
# This script runs INSIDE the Sandbox.
# It extends the consciousness to execute tasks one-by-one.

ITERATIONS=${1:-1}
AGENT=${2:-gemini}

# Locate the Persona: Prefer local, fallback to script directory (Mothership)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERSONA_LOCAL="personas/killer.md"
PERSONA_MOTHERSHIP="$SCRIPT_DIR/personas/killer.md"

if [ -f "$PERSONA_LOCAL" ]; then
    PERSONA="$PERSONA_LOCAL"
elif [ -f "$PERSONA_MOTHERSHIP" ]; then
    PERSONA="$PERSONA_MOTHERSHIP"
else
    echo "Error: Persona file 'killer.md' not found in local 'personas/' or '$SCRIPT_DIR/personas/'."
    exit 1
fi

# Select the Agent and their specific "YOLO" flags
if [ "$AGENT" == "claude" ]; then
    AGENT_BIN=$(which claude)
    # --permission-mode acceptEdits: YOLO, -p: print mode (non-interactive)
    # Ensure -p is at the end so the prompt string follows it
    AGENT_ARGS="--permission-mode acceptEdits -p" 
elif [ "$AGENT" == "gemini" ]; then
    AGENT_BIN=$(which gemini)
    # Use a stable model by default to avoid 'MODEL_CAPACITY_EXHAUSTED' on preview models.
    # Gemini 2.5 Flash is the recommended baseline for high-frequency tool loops in 2026.
    MODEL=${GEMINI_MODEL:-gemini-2.5-flash}
    # --yolo: YOLO, --model: specify model, -p: prompt/print mode
    # -p MUST be last so the prompt string follows it immediately
    AGENT_ARGS="--yolo --model $MODEL -p"
else
    echo "Error: Unknown agent '$AGENT'. Use 'gemini' or 'claude'."
    exit 1
fi

if [ -z "$AGENT_BIN" ]; then
    echo "Error: Binary for $AGENT not found!"
    exit 1
fi

echo "👾 Ralph initialized. Agent: $AGENT. Starting $ITERATIONS iterations..."

# Read the Persona content once to pass it in the prompt
PERSONA_CONTENT=$(cat "$PERSONA")

for ((i=1; i<=$ITERATIONS; i++)); do
    echo "--- Ralph Strike $i / $ITERATIONS ($AGENT) ---"
    
    # Invoke the agent with the 'killer' persona content and high-level directive.
    # We pass the persona content directly to avoid 'read_file' path restrictions.
    
    $AGENT_BIN $AGENT_ARGS "SYSTEM_PROMPT:
$PERSONA_CONTENT

CONTEXT:
You are working in the current directory: $(pwd)
Your unique Identity name is: ${IDENTITY_NAME}

DIRECTIVE:
1. Read the specifications (e.g., SPEC.md or files in the specs/ directory) and progress.txt.
2. Identify the NEXT incomplete task from the implementation plan.
3. Implement it fully.
4. Run any necessary tests.
5. Update the relevant specification/plan file (mark task as done) and progress.txt (log the action).
6. Commit the changes with a clear message using your Identity (${IDENTITY_NAME}). 
   DO NOT override the git author/email; use the system's configured identity.
    
If all tasks in the specifications are complete, output: <promise>COMPLETE</promise>
Only work on ONE task per iteration."

    # Note: In a real loop, we might want to check the stdout for the <promise>
    # but for now, we let the Identity run wild.
    
    echo "--- Strike $i Complete ---"
    # Wait for the server-side capacity to replenish.
    # Defaults to 10 seconds, but can be overridden.
    DELAY=${STRIKE_DELAY:-10}
    if [ $i -lt $ITERATIONS ]; then
        echo "   -> Cooling down for $DELAY seconds..."
        sleep $DELAY
    fi
done

echo "👾 Ralph retracted. Loop finished."