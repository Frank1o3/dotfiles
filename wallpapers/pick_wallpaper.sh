#!/usr/bin/env bash
WALLPAPER_DIR="/home/frank/wallpapers"
PREVIEW_WIN="imv"
PREVIEW_ARGS="--no-mouse --windowed --title 'Wallpaper Preview'"

cd "$WALLPAPER_DIR" || { notify-send "Error" "Dir not found"; exit 1; }

# Get sorted list (excluding symlink)
mapfile -t WALLPAPERS < <(find . -maxdepth 1 -name "*.jpg" ! -name "wallpaper.jpg" -printf "%f\n" | sort)
[ ${#WALLPAPERS[@]} -eq 0 ] && { notify-send "Error" "No wallpapers!"; exit 1; }

# 1. Launch preview window in background (opens first image)
$PREVIEW_WIN $PREVIEW_ARGS "${WALLPAPERS[0]}" &
PREVIEW_PID=$!

# 2. Open fuzzel selector
SELECTED=$(printf '%s\n' "${WALLPAPERS[@]}" | fuzzel --dmenu --prompt='🖼️ Select Wallpaper: ' \
    --width=60 --lines=12)

# Kill preview window
kill $PREVIEW_PID 2>/dev/null

[ -z "$SELECTED" ] && exit 0

# 3. Apply theme & wallpaper
SELECTED_PATH="$WALLPAPER_DIR/$SELECTED"
ln -sf "$SELECTED" "$WALLPAPER_DIR/wallpaper.jpg"

notify-send "🎨 Applying" "$SELECTED"
wallust run "$SELECTED_PATH"
awww img "$SELECTED_PATH"
notify-send "✓ Complete" "Theme & wallpaper updated"
