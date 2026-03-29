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

detect_repo_name() {
    local NAME=$1
    local WORKSPACE_DIR="$(pwd)/workspace-$NAME"
    local REPO_URL=""

    if [ -d "$WORKSPACE_DIR/.git" ]; then
        # 1. Try standard git (fastest, but might fail due to "dubious ownership")
        REPO_URL=$(git -C "$WORKSPACE_DIR" remote get-url origin 2>/dev/null)
        
        # 2. If git failed, try reading the config file directly (bypass ownership check)
        if [ -z "$REPO_URL" ] && [ -f "$WORKSPACE_DIR/.git/config" ]; then
            REPO_URL=$(grep -A 1 '\[remote "origin"\]' "$WORKSPACE_DIR/.git/config" | grep "url =" | sed -E 's/.*url = (.*)/\1/')
        fi
    fi

    # 3. If we still don't have it, try asking the container itself if it's running
    if [ -z "$REPO_URL" ] && [ "$($DOCKER_CMD ps -q -f name=^/${NAME}$)" ]; then
        REPO_URL=$($DOCKER_CMD exec "$NAME" git -C /workspace remote get-url origin 2>/dev/null)
    fi

    if [ -n "$REPO_URL" ]; then
        basename "$REPO_URL" | sed 's/\.git$//'
    fi
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
    $DOCKER_CMD exec "$NAME" bash -c "if [ -d ~/mothership ]; then (cd ~/mothership && git pull); else git clone https://github.com/ianchanning/ralph-sandbox-swarm.git ~/mothership; fi" >&2

    # 3. Symlink the latest init script
    echo "   -> Linking latest init tools..." >&2
    $DOCKER_CMD exec "$NAME" ln -sf /root/mothership/init_identity.sh /usr/local/bin/init_identity.sh >&2

    # Emit name to stdout for command composition
    echo "$NAME"
    ;;
  go)
    REPO_URL=$2
    if [ -z "$REPO_URL" ]; then echo "Usage: $0 go <repo_url>"; exit 1; fi

    REPO_NAME=$(basename "$REPO_URL" | sed 's/\.git$//')
    echo "LFG: Initializing environment for $REPO_URL..." >&2

    # 1. Create a random sandbox and capture the name
    # Check if a template exists for this repo
    if $DOCKER_CMD image inspect "$REPO_NAME" >/dev/null 2>&1; then
        echo "   -> Found template '$REPO_NAME' for this repo. Using it..." >&2
        NAME=$($0 create "$REPO_NAME")
    else
        NAME=$($0 create)
    fi

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
    
    # If no template specified and we are creating a NEW container, try to find a matching template in workspace
    if [ -z "$TEMPLATE" ] && ! [ "$($DOCKER_CMD ps -a -q -f name=^/${NAME}$)" ]; then
        REPO_NAME=$(detect_repo_name "$NAME")
        if [ -n "$REPO_NAME" ] && $DOCKER_CMD image inspect "$REPO_NAME" >/dev/null 2>&1; then
            TEMPLATE="$REPO_NAME"
            echo "   -> Found matching template '$TEMPLATE' for workspace. Using it..." >&2
        fi
    fi

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
  clone)
    NAME=$2
    REPO_URL=$3
    TARGET_DIR=$4
    
    if [ -z "$NAME" ] || [ -z "$REPO_URL" ]; then 
        echo "Usage: $0 clone <name> <repo_url> [target_dir]"
        exit 1 
    fi
    
    # 1. Add deploy key to the target repo first
    REPO_PATH=$(echo $REPO_URL | sed -E 's/.*github.com[:\/]//; s/\.git$//')
    $0 gh-key "$NAME" "$REPO_PATH" || { echo "   ! Skipping deploy key injection." >&2; }
    
    echo "👾 Identity '$NAME' is cloning $REPO_URL..."
    
    # Construct the command
    GIT_CMD="git clone $REPO_URL"
    if [ -n "$TARGET_DIR" ]; then
        GIT_CMD="$GIT_CMD $TARGET_DIR"
    fi

    $DOCKER_CMD exec -w /workspace "$NAME" bash -c "$GIT_CMD"
    ;;
  gh-key)
    NAME=$2
    REPO_PATH=$3
    if [ -z "$NAME" ] || [ -z "$REPO_PATH" ]; then echo "Usage: $0 gh-key <name> <org/repo>"; exit 1; fi
    
    echo "Adding deploy key for '$NAME' to GitHub repo '$REPO_PATH'..."
    
    # Wait for the container to generate its key if it just started
    for i in {1..10}; do
        KEY=$($0 key "$NAME")
        if [ -n "$KEY" ]; then break; fi
        echo "   -> Waiting for Identity generation in '$NAME'..."
        sleep 2
    done

    if [ -z "$KEY" ]; then
        echo "Error: Could not find public key in container logs or via exec."
        exit 1
    fi

    # Use GH CLI to add the deploy key
    echo "$KEY" | gh repo deploy-key add - --title "safer-ralph-$NAME" --allow-write --repo "$REPO_PATH"
    echo "✓ Deploy key added successfully!"
    ;;
  save)
    NAME=$2
    TEMPLATE_NAME=$3
    if [ -z "$NAME" ]; then echo "Usage: $0 save <sandbox_name> [template_name]"; exit 1; fi
    
    if [ -z "$TEMPLATE_NAME" ]; then
        TEMPLATE_NAME=$(detect_repo_name "$NAME")
        
        if [ -z "$TEMPLATE_NAME" ]; then
            echo "Error: Template name not provided and could not detect repo name from workspace or container." >&2
            exit 1
        fi
        
        echo "   -> Auto-detected template name for '$NAME': $TEMPLATE_NAME" >&2
    fi

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
    
    # 1. Try to find it in the logs (for fresh identities)
    KEY=$($DOCKER_CMD logs "$NAME" 2>&1 | grep "ssh-ed25519" | tail -n 1)
    
    # 2. If not in logs, try to exec and read it directly (for identities baked into templates)
    if [ -z "$KEY" ]; then
        KEY=$($DOCKER_CMD exec "$NAME" cat /root/.ssh/id_ed25519.pub 2>/dev/null || true)
    fi
    
    if [ -n "$KEY" ]; then
        echo "$KEY"
    fi
    ;;
esac
