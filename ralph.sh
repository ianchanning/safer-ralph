#!/bin/bash
set -e

# RALPH: The Heartbeat Loop (REFORGED + FIXED)
# This script runs INSIDE the Sandbox.

ITERATIONS=${1:-1}
AGENT=${2:-gemini}
PERSONA_NAME=${3:-killer}

# Locate the Persona
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERSONA_LOCAL="personas/${PERSONA_NAME}.md"
PERSONA_MOTHERSHIP="$SCRIPT_DIR/personas/${PERSONA_NAME}.md"

if [ -f "$PERSONA_LOCAL" ]; then
    PERSONA="$PERSONA_LOCAL"
elif [ -f "$PERSONA_MOTHERSHIP" ]; then
    PERSONA="$PERSONA_MOTHERSHIP"
else
    echo "Error: Persona file ${PERSONA_NAME}.md not found."
    exit 1
fi

# Agent configuration
if [ "$AGENT" == "claude" ]; then
    AGENT_BIN=$(which claude)
    AGENT_ARGS="--permission-mode acceptEdits -p" 
elif [ "$AGENT" == "gemini" ]; then
    AGENT_BIN=$(which gemini)
    MODEL=${GEMINI_MODEL:-gemini-2.5-flash}
    AGENT_ARGS="--yolo --model $MODEL -p"
else
    echo "Error: Unknown agent '$AGENT'."
    exit 1
fi

if [ -z "$AGENT_BIN" ]; then
    echo "Error: $AGENT not found!"
    exit 1
fi

echo "👾 Ralph initialized. Agent: $AGENT. Persona: $PERSONA_NAME."

PERSONA_CONTENT=$(cat "$PERSONA")

for ((i=1; i<=$ITERATIONS; i++)); do
    echo "--- Ralph Strike $i / $ITERATIONS ($AGENT) ---"
    
    # We use a temporary file to capture the status without choking the TTY
    STRIKE_LOG=$(mktemp)

    # THE REFORGED DIRECTIVE: High-pressure, mechanical, and unambiguous.
    # We use 'tee' to ensure you see the output, and 'set +e' to handle agent crashes gracefully.
    set +e
    $AGENT_BIN $AGENT_ARGS "SYSTEM_PROMPT:
$PERSONA_CONTENT

CONTEXT:
Directory: $(pwd)
Identity: ${IDENTITY_NAME}

CRITICAL PROTOCOL:
1. AUDIT: Read progress.txt and all files in specs/ to find the FIRST unchecked [ ] task.
2. EXECUTE: Perform ONLY that one task. Do not jump ahead.
3. RECORD: 
   - Update the spec file: Change [ ] to [x] for the completed task.
   - Append to progress.txt: '## Strike: ${IDENTITY_NAME} - [Short Task Summary]'
4. COMMIT: Use git to commit the changes.
5. SIGNAL: Your final output MUST end with one of these tags:
   - <status>STRIKE_COMPLETE: [The task you just finished]</status>
   - <status>ALL_TASKS_DONE</status>

FAILURE TO UPDATE THE SPECIFICATION FILE IS A PROTOCOL VIOLATION.
FAILURE TO COMMIT IS A PROTOCOL VIOLATION.
DO NOT OUTPUT CHAT OR EXPLANATIONS. OUTPUT CODE AND STATUS." 2>&1 | tee "$STRIKE_LOG"
    set -e

    if grep -q "<status>ALL_TASKS_DONE</status>" "$STRIKE_LOG"; then
        echo "🎉 Mission Accomplished. All tasks in specs/ are complete."
        rm -f "$STRIKE_LOG"
        break
    fi

    if ! grep -q "<status>STRIKE_COMPLETE" "$STRIKE_LOG"; then
        echo "⚠️  Warning: Agent did not signal strike completion properly."
    fi

    rm -f "$STRIKE_LOG"
    echo "--- Strike $i Complete ---"
    
    DELAY=${STRIKE_DELAY:-10}
    if [ $i -lt $ITERATIONS ]; then
        echo "   -> Cooling down for $DELAY seconds..."
        sleep $DELAY
    fi
done

echo "👾 Ralph retracted."
