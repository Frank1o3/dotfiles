#!/bin/sh

set -eu

echo "This script will update your dotfiles configuration from the repository."

for cmd in git python3; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Error: $cmd is not installed."
        exit 1
    }
done

REPO_URL="https://github.com/Frank1o3/dotfiles.git"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Cloning dotfiles repository..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR"

echo "Synchronizing configuration..."
python3 "$TMP_DIR/sync-config.py"

echo "Making utility scripts executable..."
chmod +x ~/.config/hypr/scripts/set-wallpaper.sh 2>/dev/null || true
chmod +x ~/.config/hypr/scripts/emoticon.py 2>/dev/null || true
chmod +x ~/.config/quickshell/scripts/sysmon.sh 2>/dev/null || true

echo "Refreshing SDDM theme..."
chmod +x "$TMP_DIR/update-theme.sh"
"$TMP_DIR/update-theme.sh"

echo "Done. Configuration updated."