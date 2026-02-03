#!/bin/bash
set -e

# Default to hostname if SPRITE_NAME not set
SPRITE_NAME=${SPRITE_NAME:-$(hostname)}
EMAIL="nyx+${SPRITE_NAME}@blank-slate.io"

echo "👾 Initializing Sprite: $SPRITE_NAME"

# 1. Configure Git Identity (Authority: The Cave Name)
# Transform name (e.g., "hawk-alpha") into cool identity (e.g., "🦅 A")
ANIMAL="${SPRITE_NAME%%-*}"
PHONETIC="${SPRITE_NAME##*-}"
INITIAL="$(echo "${PHONETIC:0:1}" | tr '[:lower:]' '[:upper:]')"

case "$ANIMAL" in
    shark) EMOJI="🦈" ;; crocodile) EMOJI="🐊" ;; tiger) EMOJI="🐅" ;; eagle) EMOJI="🦅" ;;
    wolf) EMOJI="🐺" ;; bear) EMOJI="🐻" ;; dragon) EMOJI="🐉" ;; octopus) EMOJI="🐙" ;;
    viper|cobra) EMOJI="🐍" ;; raven) EMOJI="🐦" ;; panther) EMOJI="🐆" ;; hawk) EMOJI="🦅" ;;
    orca) EMOJI="🐋" ;; lynx) EMOJI="🐱" ;; scorpion) EMOJI="🦂" ;; falcon) EMOJI="🦅" ;;
    bull) EMOJI="🐂" ;; ram) EMOJI="🐏" ;; mantis) EMOJI="🦗" ;; *) EMOJI="🏴‍☠️" ;;
esac

GIT_NAME="$EMOJI $INITIAL"
echo "   -> Setting Git Identity: $GIT_NAME <$EMAIL>"
git config --global user.name "$GIT_NAME"
git config --global user.email "$EMAIL"

# 2. Grant Git access to the mounted volume
echo "   -> Granting Git access to /workspace"
git config --global --add safe.directory /workspace

# 3. Handle SSH setup
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Pre-populate known_hosts for GitHub to avoid interactive prompts
if ! grep -q "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null; then
    echo "   -> Scanning GitHub SSH fingerprint..."
    ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
fi

# 4. Generate SSH Key (if missing)
KEY_PATH="$HOME/.ssh/id_ed25519"
if [ ! -f "$KEY_PATH" ]; then
    echo "   -> Forging new SSH Key for $EMAIL..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""
    
    echo ""
    echo "--- [ PUBLIC KEY FOR GITHUB ] ---"
    cat "${KEY_PATH}.pub"
    echo "---------------------------------"
    echo ""
else
    echo "   -> SSH Key already exists."
fi

# 5. Hand over control to the main command
if [ $# -gt 0 ]; then
    exec "$@"
else
    echo "👾 Sprite initialized and ready for duty."
fi
