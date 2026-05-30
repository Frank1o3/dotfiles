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
if ! pgrep -x hyprpaper > /dev/null; then
    notify-send "⚠️ Starting hyprpaper" "Daemon not running, launching..."
    hyprpaper &
    sleep 1
fi

systemctl --user restart hyprpaper
sleep 0.5

# Clear old state & apply new wallpaper
# Use $SELECTED_PATH directly to avoid symlink cache issues
hyprctl hyprpaper preload "$SELECTED_PATH"
hyprctl hyprpaper wallpaper ",$SELECTED_PATH"

# Verify it applied
if ! hyprctl hyprpaper listactive | grep -q "$SELECTED_PATH"; then
    notify-send "❌ Fallback" "Reloading hyprpaper..."
    pkill hyprpaper
    hyprpaper &
    sleep 1
    hyprctl hyprpaper preload "$SELECTED_PATH"
    hyprctl hyprpaper wallpaper ",$SELECTED_PATH"
fi

pkill -x waybar; waybar & disown
pkill -x swaync; swaync & disown


notify-send "✓ Complete" "Theme & wallpaper updated"