#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/Frank1o3/dotfiles.git}"
REPO_BRANCH="main"

# 1. Verify Hyprland environment
if [[ "${XDG_CURRENT_DESKTOP,,}" != *"hyprland"* && -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    echo "❌ Error: This setup requires Hyprland. Detected: ${XDG_CURRENT_DESKTOP:-Unknown}"
    exit 1
fi

# 2. Check required binaries
DEPS=("git" "dunst" "kitty" "waybar" "fuzzel" "wallust", "awww")
MISSING=()
for cmd in "${DEPS[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || MISSING+=("$cmd")
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "❌ Missing dependencies: ${MISSING[*]}"
    echo "Please install them with your package manager and rerun."
    exit 1
fi
echo "✅ Environment & dependency check passed."

# 3. Backup existing configs
echo "📦 Backing up existing configurations..."
for app in "${DEPS[@]:1}"; do # skip 'git' in backup loop
    CONFIG_DIR="$HOME/.config/$app"
    if [ -d "$CONFIG_DIR" ]; then
        BACKUP_DIR="$HOME/.config/${app}.bak.$(date +%Y%m%d_%H%M%S)"
        cp -a "$CONFIG_DIR" "$BACKUP_DIR"
        echo "   Backed up $CONFIG_DIR → $BACKUP_DIR"
    fi
done

# 4. Fetch & deploy configs
echo "🌐 Cloning repository..."
TEMP_REPO=$(mktemp -d)
git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$TEMP_REPO"

echo "📥 Deploying configurations..."
for app in "${DEPS[@]:1}"; do
    SRC_DIR="$TEMP_REPO/$app"
    DEST_DIR="$HOME/.config/$app"
    if [ -d "$SRC_DIR" ]; then
        mkdir -p "$DEST_DIR"
        # Copy contents including hidden files
        cp -a "$SRC_DIR"/. "$DEST_DIR"/
        echo "   Deployed $app"
    fi
done

# Cleanup
rm -rf "$TEMP_REPO"

echo "✨ Done! Run 'hyprctl reload' or restart affected apps to apply changes."
