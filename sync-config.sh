#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Dotfiles Sync Script
# Syncs local repo configs -> ~/.config
# =========================================================

# Repo root (script location)
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WALLPAPER_HOME="$HOME/wallpapers"

VERBOSE="${VERBOSE:-0}"
DRY_RUN="${DRY_RUN:-0}"

# =========================================================
# Logging
# =========================================================

log() {
    echo "ℹ️  $*"
}

warn() {
    echo "⚠️  $*" >&2
}

success() {
    echo "✅ $*"
}

# =========================================================
# Run helper
# =========================================================

run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

# =========================================================
# Config directories to sync
# =========================================================

CONFIGS=(
    "hypr"
    "waybar"
    "kitty"
    "dunst"
    "fuzzel"
    "wallust"
)

# =========================================================
# Sync function
# =========================================================

sync_config() {
    local name="$1"

    local SRC="$REPO_DIR/$name"
    local DEST="$CONFIG_HOME/$name"

    if [[ ! -d "$SRC" ]]; then
        warn "Missing repo config: $name"
        return
    fi

    mkdir -p "$DEST"

    # Check if different
    if diff -qr "$SRC" "$DEST" >/dev/null 2>&1; then
        [[ "$VERBOSE" == "1" ]] && \
            log "No changes: $name"
        return
    fi

    log "Syncing: $name"

    run rsync -a --delete \
        --exclude='.git' \
        "$SRC"/ "$DEST"/

    success "Updated: $name"
}

# =========================================================
# Main sync
# =========================================================

log "Starting config sync..."

for config in "${CONFIGS[@]}"; do
    sync_config "$config"
done

# =========================================================
# Wallpapers
# =========================================================

if [[ -d "$REPO_DIR/wallpapers" ]]; then
    mkdir -p "$WALLPAPER_HOME"

    log "Syncing wallpapers..."

    run rsync -a --delete \
        --exclude='.git' \
        "$REPO_DIR/wallpapers"/ \
        "$WALLPAPER_HOME"/

    success "Updated wallpapers"
fi

# =========================================================
# Reload services
# =========================================================

if command -v hyprctl >/dev/null 2>&1; then
    log "Reloading Hyprland..."

    run hyprctl reload >/dev/null 2>&1 || true
fi

# Restart waybar if running
if pgrep -x waybar >/dev/null 2>&1; then
    log "Restarting Waybar..."

    run pkill waybar || true
    run nohup waybar >/dev/null 2>&1 &
fi

# Restart dunst if running
if pgrep -x dunst >/dev/null 2>&1; then
    log "Restarting Dunst..."

    run pkill dunst || true
    run nohup dunst >/dev/null 2>&1 &
fi

success "Config sync complete"