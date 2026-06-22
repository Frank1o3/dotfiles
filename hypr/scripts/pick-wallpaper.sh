#!/usr/bin/env sh

set -eu

WALLPAPER_DIR="$HOME/wallpapers"

cd "$WALLPAPER_DIR" || {
    notify-send "Error" "Dir not found"
    exit 1
}

# 🔥 fzf picker with LIVE preview (no arrays, pure POSIX)
SELECTED=$(
    find "$WALLPAPER_DIR" -maxdepth 1 -type f -name "*.jpg" ! -name "wallpaper.jpg" | sort | \
    fzf \
        --prompt="🖼️  Select Wallpaper: " \
        --layout=reverse \
        --border=rounded \
        --margin=0 \
        --padding=0 \
        --preview 'bash -c '\''kitty +kitten icat --clear --transfer-mode=stream --stdin=no --place ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 --scale-up "$1"'\'' _ {}' \
        --preview-window=right,60%,border-left \
        --delimiter='/' \
        --with-nth=-1
)

[ -z "${SELECTED:-}" ] && exit 0

SELECTED_PATH="$SELECTED"
SELECTED_NAME=$(basename "$SELECTED")

# Update symlink
ln -sf "$SELECTED_PATH" "$WALLPAPER_DIR/wallpaper.jpg"

notify-send "🎨 Applying" "$SELECTED_NAME"

# 🎨 Run wallust
wallust run "$WALLPAPER_DIR/wallpaper.jpg"

# 🖼️ Ensure hyprpaper is running
if ! pgrep -x hyprpaper >/dev/null 2>&1; then
    notify-send "Starting hyprpaper" "Daemon not running, launching..."
    systemctl --user start hyprpaper
    sleep 1
fi

# Restart to apply new theme cleanly
systemctl --user restart hyprpaper
sleep 0.5

# Apply wallpaper
hyprctl hyprpaper preload "$SELECTED_PATH"
hyprctl hyprpaper wallpaper ",$SELECTED_PATH"

# Verify
if ! hyprctl hyprpaper listactive | grep -q "$SELECTED_PATH"; then
    notify-send "Fallback" "Reloading hyprpaper..."
    pkill hyprpaper
    systemctl --user start hyprpaper
    sleep 1
    hyprctl hyprpaper preload "$SELECTED_PATH"
    hyprctl hyprpaper wallpaper ",$SELECTED_PATH"
fi

notify-send "✓ Complete" "Theme & wallpaper updated"