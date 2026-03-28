#!/bin/bash

# Resolve the directory where this script lives, resolving symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

IMAGE_NAME="local-sandbox-base"

# Naming Strategy Lists
ANIMALS=("shark" "crocodile" "tiger" "eagle" "wolf" "bear" "dragon" "octopus" "viper" "raven" "panther" "cobra" "hawk" "orca" "lynx" "scorpion" "falcon" "bull" "ram" "mantis")
NATO=("alpha" "bravo" "charlie" "delta" "echo" "foxtrot" "golf" "hotel" "india" "juliet" "kilo" "lima" "mike" "november" "oscar" "papa" "quebec" "romeo" "sierra" "tango" "uniform" "victor" "whiskey" "xray" "yankee" "zulu")

generate_name() {
    local ANIMAL=${ANIMALS[$RANDOM % ${#ANIMALS[@]}]}
    
    # Find the next NATO index by checking existing containers
    local EXISTING_NAMES=$($DOCKER_CMD ps -a --format '{{.Names}}')
    local MAX_INDEX=-1
    
    for NAME in $EXISTING_NAMES; do
        # Extract the phonetic part (everything after the last dash)
        local PHONETIC=${NAME##*-}
        for i in "${!NATO[@]}"; do
            if [[ "${NATO[$i]}" == "${PHONETIC}" ]]; then
                if (( i > MAX_INDEX )); then
                    MAX_INDEX=$i
                fi
            fi
        done
    done
    
    local NEXT_INDEX=$((MAX_INDEX + 1))
    if (( NEXT_INDEX >= ${#NATO[@]} )); then
        NEXT_INDEX=0 # Wrap around if we exceed Zulu
    fi
    
    echo "${ANIMAL}-${NATO[$NEXT_INDEX]}"
}

inject_gemini_auth() {
    local NAME=$1
    local GEMINI_DIR="$HOME/.gemini"
    
    # If GEMINI_API_KEY is present, configure the sandbox to use it instead of OAuth
    if [ -n "$GEMINI_API_KEY" ]; then
        echo "   -> Configuring Gemini for API_KEY mode..."
        $DOCKER_CMD exec "$NAME" bash -c "mkdir -p /root/.gemini && echo '{\"general\": {\"previewFeatures\": true}, \"security\": {\"auth\": {\"selectedType\": \"api-key\"}}}' > /root/.gemini/settings.json"
    fi

    if [ -d "$GEMINI_DIR" ]; then
        echo "   -> Injecting Gemini credentials for '$NAME'..."
        # Copy oauth_creds.json if it exists
        if [ -f "$GEMINI_DIR/oauth_creds.json" ]; then
            $DOCKER_CMD cp "$GEMINI_DIR/oauth_creds.json" "$NAME:/root/.gemini/oauth_creds.json"
        fi
        # Copy google_accounts.json if it exists
        if [ -f "$GEMINI_DIR/google_accounts.json" ]; then
            $DOCKER_CMD cp "$GEMINI_DIR/google_accounts.json" "$NAME:/root/.gemini/google_accounts.json"
        fi
    fi
}

find_free_port() {
    local PORT=3000
    while [ -n "$($DOCKER_CMD ps --format '{{.Ports}}' | grep ":$PORT->")" ]; do
        ((PORT++))
    done
    echo $PORT
}

# Auto-detect if sudo is needed for docker
if command -v docker >/dev/null 2>&1; then
    if docker ps >/dev/null 2>&1; then
        DOCKER_CMD="docker"
    elif sudo docker ps >/dev/null 2>&1; then
        DOCKER_CMD="sudo docker"
    else
        echo "Error: Docker found but 'docker ps' failed. Check your service." >&2
        exit 1
    fi
else
    echo "Error: 'docker' command not found. Please install Docker." >&2
    exit 1
fi

case "$1" in
  build)
    echo "Building $IMAGE_NAME..."
    $DOCKER_CMD build -t $IMAGE_NAME -f "$SCRIPT_DIR/Dockerfile.sandbox" "$SCRIPT_DIR"
    ;;
  create)
    # Detection logic: If $2 is an image, it's the TEMPLATE. Otherwise, it's the NAME.
    ARG=$2
    if [ -n "$ARG" ] && $DOCKER_CMD image inspect "$ARG" >/dev/null 2>&1; then
        TEMPLATE="$ARG"
        NAME=$3
    else
        TEMPLATE="$IMAGE_NAME"
        NAME="$ARG"
    fi

    # Verify template exists before proceeding
    if ! $DOCKER_CMD image inspect "$TEMPLATE" >/dev/null 2>&1; then
        echo "Error: Template image '$TEMPLATE' not found. Run '$0 build' first." >&2
        exit 1
    fi

    if [ -z "$NAME" ]; then
        NAME=$(generate_name)
        # Ensure name uniqueness
        while [ "$($DOCKER_CMD ps -a -q -f name=^/${NAME}$)" ]; do
            NAME=$(generate_name)
        done
        echo "Generated Sandbox Name: $NAME" >&2
    fi

    # 1. Bring up the container (low-level)
    $0 up "$NAME" "$TEMPLATE" >&2

    # 2. Unconditionally install the Mothership tools via HTTPS
    echo "Installing Mothership tools via HTTPS..." >&2
    $DOCKER_CMD exec "$NAME" bash -c "git clone https://github.com/ianchanning/ralph-sandbox-swarm.git ~/mothership || (cd ~/mothership && git pull)" >&2

    # 3. Symlink the latest init script
    echo "   -> Linking latest init tools..." >&2
    $DOCKER_CMD exec "$NAME" ln -sf /root/mothership/init_identity.sh /usr/local/bin/init_identity.sh >&2

    # Emit name to stdout for command composition
    echo "$NAME"
    ;;
  go)
    REPO_URL=$2
    if [ -z "$REPO_URL" ]; then echo "Usage: $0 go <repo_url>"; exit 1; fi

    echo "LFG: Initializing environment for $REPO_URL..." >&2

    # 1. Create a random sandbox and capture the name
    # We call create with no args to trigger the auto-generation logic
    NAME=$($0 create)

    # 2. Add deploy key and clone the repository
    $0 clone "$NAME" "$REPO_URL" .

    # 3. Jump in
    echo "Entering Sandbox: $NAME" >&2
    $0 in "$NAME"
    ;;
  up)
    NAME=$2
    TEMPLATE=$3
    if [ -z "$NAME" ]; then echo "Usage: $0 up <name> [template]"; exit 1; fi
    if [ -z "$TEMPLATE" ]; then TEMPLATE="$IMAGE_NAME"; fi

    if [ "$($DOCKER_CMD ps -a -q -f name=^/${NAME}$)" ]; then
        echo "Sandbox '$NAME' already exists. Starting it..."
        $DOCKER_CMD start "$NAME"
        inject_gemini_auth "$NAME"
    else
        # Create a dedicated workspace for this sandbox
        WORKSPACE_DIR="$(pwd)/workspace-$NAME"
        if [ ! -d "$WORKSPACE_DIR" ]; then
            echo "Creating workspace: $WORKSPACE_DIR"
            mkdir -p "$WORKSPACE_DIR"
        fi
        
        PORT=$(find_free_port)
        echo "Launching Sandbox: $NAME (from template: $TEMPLATE) on port $PORT"
        # Mount the dedicated workspace to /workspace and expose the allocated port
        $DOCKER_CMD run -d --name "$NAME" --hostname "$NAME" --label org.nyx.sandbox=true -p $PORT:3000 \
            -e IDENTITY_NAME="$NAME" \
            -e MOONSHOT_API_KEY="$MOONSHOT_API_KEY" \
            -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
            -e GEMINI_API_KEY="$GEMINI_API_KEY" \
            -v "$WORKSPACE_DIR:/workspace" "$TEMPLATE"
        inject_gemini_auth "$NAME"
    fi
    ;;
  save)
    NAME=$2
    TEMPLATE_NAME=$3
    if [ -z "$NAME" ] || [ -z "$TEMPLATE_NAME" ]; then echo "Usage: $0 save <sandbox_name> <template_name>"; exit 1; fi
    echo "Saving Sandbox '$NAME' into a new template: '$TEMPLATE_NAME'..."
    # Preserve the label so it shows up in 'list'
    $DOCKER_CMD commit --change 'LABEL org.nyx.sandbox="true"' "$NAME" "$TEMPLATE_NAME"
    echo "✓ Template '$TEMPLATE_NAME' is ready for use."
    ;;
  in)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 in <name>"; exit 1; fi
    $DOCKER_CMD exec -it "$NAME" bash
    ;;
  purge)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 purge <name>"; exit 1; fi
    echo "Removing Sandbox container: $NAME"
    $DOCKER_CMD rm -f "$NAME"
    WORKSPACE_DIR="$(pwd)/workspace-$NAME"
    if [ -d "$WORKSPACE_DIR" ]; then
        echo "Purging workspace (via Docker to handle root-owned files): $WORKSPACE_DIR"
        # We use a tiny alpine container to rm the host directory since it might contain root-owned .git files
        $DOCKER_CMD run --rm -v "$(pwd):/host" alpine rm -rf "/host/workspace-$NAME"
    fi
    ;;
  list)
    # List containers, then filter for those matching our image, label, or naming convention
    # This ensures that even "legacy" identities with untagged image IDs show up.
    HEADER=$($DOCKER_CMD ps | head -n 1)
    IDENTITIES=$($DOCKER_CMD ps | grep -E "local-sandbox-base|org.nyx.sandbox=true|$(echo ${ANIMALS[*]} | tr ' ' '|')" | grep -v "grep" || true)
    
    echo "$HEADER"
    if [ -n "$IDENTITIES" ]; then
        echo "$IDENTITIES"
    fi
    ;;
  key)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 key <name>"; exit 1; fi
    # Grep the key from the logs (grabbing the last occurrence if
    ;;
esac
