#!/bin/bash
set -e

# RALPH: Identity Bootstrap
# This script runs ONCE inside a new Sandbox to establish its Identity.

# Default to hostname if IDENTITY_NAME not set
IDENTITY_NAME=${IDENTITY_NAME:-$(hostname)}
EMAIL="ralph+${IDENTITY_NAME}@example.com"

echo "👾 Initializing Identity: $IDENTITY_NAME"

# 1. Configure Git Identity (Authority: The Sandbox Name)
# Transform name (e.g., "hawk-alpha") into cool identity (e.g., "🦅 A")
ANIMAL="${IDENTITY_NAME%%-*}"
PHONETIC="${IDENTITY_NAME##*-}"
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
    # Use || true to prevent set -e from killing the script if offline
    ssh-keyscan -H github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || echo "      ! Warning: Could not scan GitHub fingerprint (offline?)"
fi

# 4. Generate SSH Key (if missing)
KEY_PATH="$HOME/.ssh/id_ed25519"
if [ ! -f "$KEY_PATH" ]; then
    echo "   -> Forging new SSH Key for $EMAIL..."
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_PATH" -N ""
else
    echo "   -> SSH Key already exists."
fi

echo ""
echo "--- [ PUBLIC KEY FOR GITHUB ] ---"
cat "${KEY_PATH}.pub"
echo "---------------------------------"
echo ""

# 5. Inject API Keys into tool configurations
if [ -f "$HOME/.pi/agent/models.json" ]; then
    if [ -n "$MOONSHOT_API_KEY" ]; then
        echo "   -> Updating Moonshot API Key in Pi configuration..."
        # Robustly replace the value of the apiKey field
        sed -i 's/"apiKey": "[^"]*"/"apiKey": "'"$MOONSHOT_API_KEY"'"/g' "$HOME/.pi/agent/models.json"
    else
        echo "   -> Skipping Pi API Key injection (MOONSHOT_API_KEY not set)."
    fi
fi

# 6. Hand over control to the main command
if [ $# -gt 0 ]; then
    exec "$@"
else
    echo "👾 Identity initialized and ready for duty."
fi