#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Configuration
# --------------------------------------------------

REPO_URL="${1:-https://github.com/Frank1o3/dotfiles.git}"
REPO_BRANCH="${2:-main}"

VERBOSE="${VERBOSE:-0}"
SKIP_DEPS="${SKIP_DEPS:-0}"
DRY_RUN="${DRY_RUN:-0}"

# --------------------------------------------------
# Helpers
# --------------------------------------------------

log() {
    echo "ℹ️  $*"
}

warn() {
    echo "⚠️  $*" >&2
}

err() {
    echo "❌ $*" >&2
}

run() {
    if [[ "$DRY_RUN" == "1" ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

# --------------------------------------------------
# Ensure config directory exists
# --------------------------------------------------

mkdir -p "$HOME/.config"

# --------------------------------------------------
# Hyprland Environment Check
# --------------------------------------------------

is_hyprland() {
    [[ "${XDG_CURRENT_DESKTOP,,}" == *"hyprland"* ]] && return 0
    [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && return 0
    command -v hyprctl &>/dev/null && hyprctl version &>/dev/null && return 0
    return 1
}

if ! is_hyprland && [[ "$SKIP_DEPS" != "1" ]]; then
    err "This setup requires Hyprland."
    err "Detected: XDG_CURRENT_DESKTOP='${XDG_CURRENT_DESKTOP:-unset}'"
    exit 1
fi

[[ "$VERBOSE" == "1" ]] && \
    log "✅ Hyprland environment detected"

# --------------------------------------------------
# Dependencies
# --------------------------------------------------

DEPS=(
    "git:git"
    "dunst:dunst"
    "kitty:kitty"
    "waybar:waybar"
    "fuzzel:fuzzel"
    "wallust:wallust"
    "hyprctl:hyprland"
    "hyprpaper:hyprpaper"
)

# --------------------------------------------------
# Dependency Check
# --------------------------------------------------

if [[ "$SKIP_DEPS" != "1" ]]; then
    MISSING=()

    for entry in "${DEPS[@]}"; do
        binary="${entry%%:*}"
        pkg="${entry##*:}"

        if command -v "$binary" &>/dev/null; then
            [[ "$VERBOSE" == "1" ]] && \
                log "✅ Found: $binary"
        else
            warn "Missing: $binary (package: $pkg)"
            MISSING+=("$pkg")
        fi
    done

    if [[ ${#MISSING[@]} -gt 0 ]]; then
        echo ""

        err "Missing dependencies:"
        printf ' - %s\n' "${MISSING[@]}"

        echo ""

        if command -v pacman &>/dev/null; then
            echo "💡 Install with:"
            echo "paru/yay -S ${MISSING[*]}"
        elif command -v apt &>/dev/null; then
            echo "💡 Install with:"
            echo "sudo apt install ${MISSING[*]}"
        fi

        echo ""
        echo "🔁 Or bypass checks with:"
        echo "SKIP_DEPS=1 ./install.sh"

        exit 1
    fi

    log "✅ All dependencies satisfied"
else
    warn "Skipping dependency checks (SKIP_DEPS=1)"
fi

# --------------------------------------------------
# Config Directories
# --------------------------------------------------

CONFIG_DIRS=(
    dunst
    fuzzel
    hypr
    kitty
    wallust
    waybar
)

# --------------------------------------------------
# Backup Existing Configs
# --------------------------------------------------

log "📦 Backing up existing configurations..."

BACKUP_STAMP="$(date +%Y%m%d_%H%M%S)"

for dir in "${CONFIG_DIRS[@]}"; do
    CONFIG_DIR="$HOME/.config/$dir"

    if [[ -d "$CONFIG_DIR" ]]; then
        BACKUP_DIR="$HOME/.config/${dir}.bak.${BACKUP_STAMP}"

        run mv "$CONFIG_DIR" "$BACKUP_DIR"

        [[ "$VERBOSE" == "1" ]] && \
            log "Backed up: $dir"
    fi
done

# --------------------------------------------------
# Clone Repository
# --------------------------------------------------

log "🌐 Cloning repository..."

TEMP_REPO="$(mktemp -d)"

cleanup() {
    rm -rf "$TEMP_REPO"
}

trap cleanup EXIT

run git clone \
    --depth 1 \
    --branch "$REPO_BRANCH" \
    "$REPO_URL" \
    "$TEMP_REPO"

# --------------------------------------------------
# Deploy Configurations
# --------------------------------------------------

log "📥 Deploying configurations..."

for dir in "${CONFIG_DIRS[@]}"; do
    SRC_DIR="$TEMP_REPO/$dir"
    DEST_DIR="$HOME/.config/$dir"

    if [[ -d "$SRC_DIR" ]]; then
        run mkdir -p "$DEST_DIR"

        run cp -a \
            "$SRC_DIR"/. \
            "$DEST_DIR"/

        [[ "$VERBOSE" == "1" ]] && \
            log "Deployed: $dir"
    fi
done

# --------------------------------------------------
# Wallpapers
# --------------------------------------------------

WALLPAPERS_SRC="$TEMP_REPO/wallpapers"
WALLPAPERS_DEST="$HOME/wallpapers"

if [[ -d "$WALLPAPERS_SRC" ]]; then
    run mkdir -p "$WALLPAPERS_DEST"

    run cp -a \
        "$WALLPAPERS_SRC"/. \
        "$WALLPAPERS_DEST"/

    log "🖼️  Wallpapers deployed"
fi

# --------------------------------------------------
# User Services
# --------------------------------------------------

SERVICES=(
    hyprpaper.service
)

if command -v systemctl &>/dev/null; then
    log "⚙️  Configuring user services..."

    for service in "${SERVICES[@]}"; do
        if systemctl --user list-unit-files | grep -q "^$service"; then

            run systemctl --user enable "$service"

            if systemctl --user is-active --quiet "$service"; then
                run systemctl --user restart "$service"
            else
                run systemctl --user start "$service"
            fi

            [[ "$VERBOSE" == "1" ]] && \
                log "Enabled: $service"
        else
            warn "Service not found: $service"
        fi
    done
fi

# --------------------------------------------------
# Finished
# --------------------------------------------------

echo ""

log "✨ Installation complete"

echo ""
echo "Apply changes with:"
echo "  hyprctl reload"

echo ""
echo "You may also want to restart:"
echo "  • kitty"
echo "  • waybar"
echo "  • dunst"
echo "  • fuzzel"