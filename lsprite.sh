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
    # Detection logic: If $2 is an image, it's the LAIR. Otherwise, it's the NAME.
    ARG=$2
    if [ -n "$ARG" ] && $DOCKER_CMD image inspect "$ARG" >/dev/null 2>&1; then
        LAIR="$ARG"
        NAME=$3
    else
        LAIR="$IMAGE_NAME"
        NAME="$ARG"
    fi

    if [ -z "$NAME" ]; then
        NAME=$(generate_name)
        # Ensure name uniqueness
        while [ "$($DOCKER_CMD ps -a -q -f name=^/${NAME}$)" ]; do
            NAME=$(generate_name)
        done
        echo "Generated Sprite Name: $NAME"
    fi
    
    # 1. Bring up the container (low-level)
    $0 up "$NAME" "$LAIR"

    # 2. Unconditionally install the Mothership tools via HTTPS (Read-Only)
    # This avoids using the Sprite's SSH key for the Mothership, reserving it for the project repo.
    echo "Installing Mothership tools via HTTPS..."
    $DOCKER_CMD exec "$NAME" bash -c "git clone https://github.com/ianchanning/sprites-swarm.git ~/mothership || (cd ~/mothership && git pull)"
    
    # 3. Symlink the latest init script over the baked-in one
    echo "   -> Linking latest init tools..."
    $DOCKER_CMD exec "$NAME" ln -sf /root/mothership/init_sprite.sh /usr/local/bin/init_sprite.sh
    ;;
  up)
    NAME=$2
    LAIR=$3
    if [ -z "$NAME" ]; then echo "Usage: $0 up <name> [lair]"; exit 1; fi
    if [ -z "$LAIR" ]; then LAIR="$IMAGE_NAME"; fi

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
        
        echo "Launching sprite: $NAME (from lair: $LAIR)"
        # Mount the dedicated workspace to /workspace and expose port 3000
        $DOCKER_CMD run -d --name "$NAME" --label org.nyx.sprite=true -p 3000:3000 -e SPRITE_NAME="$NAME" -v "$WORKSPACE_DIR:/workspace" "$LAIR"
        inject_gemini_auth "$NAME"
    fi
    ;;
  season)
    NAME=$2
    LAIR_NAME=$3
    if [ -z "$NAME" ] || [ -z "$LAIR_NAME" ]; then echo "Usage: $0 season <sprite_name> <lair_name>"; exit 1; fi
    echo "Seasoning '$NAME' into a new lair: '$LAIR_NAME'..."
    # Preserve the label so it shows up in 'ls'
    $DOCKER_CMD commit --change 'LABEL org.nyx.sprite="true"' "$NAME" "$LAIR_NAME"
    echo "✓ Lair '$LAIR_NAME' is ready for summoning."
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
        echo "Removing workspace (via Docker to handle root-owned files): $WORKSPACE_DIR"
        # We use a tiny alpine container to rm the host directory since it might contain root-owned .git files
        $DOCKER_CMD run --rm -v "$(pwd):/host" alpine rm -rf "/host/workspace-$NAME"
    fi
    ;;
  ls)
    # List containers, then filter for those matching our image, label, or naming convention
    # This ensures that even "legacy" sprites with untagged image IDs show up.
    HEADER=$($DOCKER_CMD ps | head -n 1)
    SPRITES=$($DOCKER_CMD ps | grep -E "local-sprite-base|org.nyx.sprite=true|$(echo ${ANIMALS[*]} | tr ' ' '|')" | grep -v "grep" || true)
    
    echo "$HEADER"
    if [ -n "$SPRITES" ]; then
        echo "$SPRITES"
    fi
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
    if [ -z "$NAME" ] || [ -z "$REPO" ]; then echo "Usage: $0 gh-key <name> <repo>"; exit 1; fi
    
    # 1. Wait for identity generation (key in logs) if not already there
    echo "Waiting for Identity generation in '$NAME'..."
    count=0
    while ! $DOCKER_CMD logs "$NAME" 2>&1 | grep -q "ssh-ed25519"; do
        sleep 1
        ((count++))
        if [ $count -ge 10 ]; then echo "Timed out waiting for SSH key in $NAME."; exit 1; fi
    done

    # 2. Extract key
    KEY=$($DOCKER_CMD logs "$NAME" 2>&1 | grep "ssh-ed25519" | tail -n 1)
    if [ -z "$KEY" ]; then echo "Error: No SSH key found in logs for $NAME"; exit 1; fi
    
    echo "Adding deploy key for '$NAME' to GitHub repo '$REPO'..."
    # Create a temp file for the key
    TMP_KEY_FILE="/tmp/${NAME}_key.pub"
    echo "$KEY" > "$TMP_KEY_FILE"
    
    # Use gh cli to add the deploy key (requires gh to be authenticated)
    if gh repo deploy-key add "$TMP_KEY_FILE" --allow-write --title "$NAME" --repo "$REPO"; then
       echo "✓ Deploy key added successfully!"
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
    
    # 1. Add deploy key to the target repo first
    REPO_PATH=$(echo $REPO_URL | sed -E 's/.*github.com[:\/]//; s/\.git$//')
    $0 gh-key "$NAME" "$REPO_PATH"
    
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
