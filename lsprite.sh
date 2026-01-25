#!/bin/bash

IMAGE_NAME="local-sprite-base"

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
    else
        echo "   -> No Gemini credentials found on host. Skipping injection."
    fi
}

# Auto-detect if sudo is needed for docker
if ! docker ps >/dev/null 2>&1; then
    DOCKER_CMD="sudo docker"
else
    DOCKER_CMD="docker"
fi

case "$1" in
  build)
    echo "Building $IMAGE_NAME..."
    $DOCKER_CMD build -t $IMAGE_NAME -f Dockerfile.sprite .
    ;;
  create)
    NAME=$2
    if [ -z "$NAME" ]; then
        NAME=$(generate_name)
        # Ensure name uniqueness
        while [ "$($DOCKER_CMD ps -a -q -f name=^/${NAME}$)" ]; do
            NAME=$(generate_name)
        done
        echo "Generated Sprite Name: $NAME"
    fi
    
    # 1. Bring up the container (low-level)
    $0 up "$NAME"
    
    # 2. Wait for identity generation (key in logs)
    echo "Waiting for Identity generation..."
    count=0
    while ! $DOCKER_CMD logs "$NAME" 2>&1 | grep -q "ssh-ed25519"; do
        sleep 1
        ((count++))
        if [ $count -ge 10 ]; then echo "Timed out waiting for SSH key."; exit 1; fi
    done
    
    # 3. Automate Key & Mothership Clone
    $0 gh-key "$NAME"
    ;;
  up)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 up <name>"; exit 1; fi
    if [ "$($DOCKER_CMD ps -a -q -f name=^/${NAME}$)" ]; then
        echo "Sprite '$NAME' already exists. Starting it..."
        $DOCKER_CMD start "$NAME"
        inject_gemini_auth "$NAME"
    else
        # Create a dedicated workspace for this sprite
        WORKSPACE_DIR="$(pwd)/workspace-$NAME"
        if [ ! -d "$WORKSPACE_DIR" ]; then
            echo "Creating workspace: $WORKSPACE_DIR"
            mkdir -p "$WORKSPACE_DIR"
        fi
        
        echo "Launching sprite: $NAME"
        # Mount the dedicated workspace to /workspace
        $DOCKER_CMD run -d --name "$NAME" -e SPRITE_NAME="$NAME" -v "$WORKSPACE_DIR:/workspace" $IMAGE_NAME
        inject_gemini_auth "$NAME"
    fi
    ;;
  in)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 in <name>"; exit 1; fi
    $DOCKER_CMD exec -it "$NAME" bash
    ;;
  rm)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 rm <name>"; exit 1; fi
    $DOCKER_CMD rm -f "$NAME"
    WORKSPACE_DIR="$(pwd)/workspace-$NAME"
    if [ -d "$WORKSPACE_DIR" ]; then
        echo "Removing workspace: $WORKSPACE_DIR"
        rm -rf "$WORKSPACE_DIR"
    fi
    ;;
  ls)
    $DOCKER_CMD ps --filter "ancestor=$IMAGE_NAME"
    ;;
  key)
    NAME=$2
    if [ -z "$NAME" ]; then echo "Usage: $0 key <name>"; exit 1; fi
    # Grep the key from the logs (grabbing the last occurrence if multiple exist)
    $DOCKER_CMD logs "$NAME" 2>&1 | grep "ssh-ed25519" | tail -n 1
    ;;
  gh-key)
    NAME=$2
    REPO=$3
    if [ -z "$NAME" ]; then echo "Usage: $0 gh-key <name> [repo]"; exit 1; fi
    # Extract key
    KEY=$($DOCKER_CMD logs "$NAME" 2>&1 | grep "ssh-ed25519" | tail -n 1)
    if [ -z "$KEY" ]; then echo "Error: No SSH key found in logs for $NAME"; exit 1; fi
    
    echo "Adding deploy key for '$NAME' to GitHub..."
    # Create a temp file for the key
    TMP_KEY_FILE="/tmp/${NAME}_key.pub"
    echo "$KEY" > "$TMP_KEY_FILE"
    
    # Construct gh command
    GH_CMD="gh repo deploy-key add \"$TMP_KEY_FILE\" --allow-write --title \"$NAME\""
    if [ -n "$REPO" ]; then
        GH_CMD="$GH_CMD --repo \"$REPO\""
    fi

    # Use gh cli to add the deploy key (requires gh to be authenticated)
    if eval "$GH_CMD"; then
       echo "✓ Deploy key added successfully!"
       
       # Trigger Mothership Clone now that we have access
       echo "Triggering Mothership clone inside Sprite..."
       $DOCKER_CMD exec "$NAME" bash -c "git clone git@github.com:ianchanning/sprites-swarm.git ~/mothership || echo '   -> Mothership already present.'"
    else
       echo "✗ Failed to add deploy key."
    fi
    rm "$TMP_KEY_FILE"
    ;;
  clone)
    NAME=$2
    REPO_URL=$3
    TARGET_DIR=$4
    
    if [ -z "$NAME" ] || [ -z "$REPO_URL" ]; then 
        echo "Usage: $0 clone <name> <repo_url> [target_dir]"
        exit 1 
    fi
    
    echo "👾 Sprite '$NAME' is cloning $REPO_URL..."
    
    # Construct the command
    GIT_CMD="git clone $REPO_URL"
    if [ -n "$TARGET_DIR" ]; then
        GIT_CMD="$GIT_CMD $TARGET_DIR"
    fi
    
    $DOCKER_CMD exec "$NAME" bash -c "$GIT_CMD"
    ;;
  *)
    echo "Usage: $0 {build|create|up|in|rm|ls|key|gh-key|clone}"
    exit 1
    ;;
esac
