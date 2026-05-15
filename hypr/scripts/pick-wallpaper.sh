#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/wallpapers"
PREVIEW_WIN="imv"
PREVIEW_ARGS="--no-mouse --windowed --title 'Wallpaper Preview'"

cd "$WALLPAPER_DIR" || { notify-send "Error" "Dir not found"; exit 1; }

# Get sorted list
mapfile -t WALLPAPERS < <(find . -maxdepth 1 -name "*.jpg" ! -name "wallpaper.jpg" -printf "%f\n" | sort)
[ ${#WALLPAPERS[@]} -eq 0 ] && { notify-send "Error" "No wallpapers!"; exit 1; }

# 1. Launch preview
$PREVIEW_WIN $PREVIEW_ARGS "${WALLPAPERS[0]}" &
PREVIEW_PID=$!

# 2. Select
SELECTED=$(printf '%s\n' "${WALLPAPERS[@]}" | fuzzel --dmenu --prompt='🖼️ Select Wallpaper: ' \
    --width=60 --lines=12)
kill $PREVIEW_PID 2>/dev/null || true
[ -z "$SELECTED" ] && exit 0

SELECTED_PATH="$WALLPAPER_DIR/$SELECTED"
ln -sf "$SELECTED" "$WALLPAPER_DIR/wallpaper.jpg"

notify-send "🎨 Applying" "$SELECTED"

# 🎨 Run wallust
wallust run "$WALLPAPER_DIR/wallpaper.jpg"

# 🖼️ Set wallpaper with hyprpaper
# Ensure hyprpaper is running
if ! pgrep -x hyprpaper > /dev/null; then
    notify-send "⚠️ Starting hyprpaper" "Daemon not running, launching..."
    hyprpaper &
    sleep 1.5
fi


# Load
hyprctl hyprpaper wallpaper ",$WALLPAPER_DIR/wallpaper.jpg,cover" 2>/dev/null || {
    notify-send "❌ Error" "Failed to load wallpaper"
    exit 1
}

notify-send "✓ Complete" "Theme & wallpaper updated"