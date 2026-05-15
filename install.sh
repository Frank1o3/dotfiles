#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${1:-https://github.com/Frank1o3/dotfiles.git}"
REPO_BRANCH="${2:-main}"
VERBOSE="${VERBOSE:-0}"
SKIP_DEPS="${SKIP_DEPS:-0}"

log() { echo "ℹ️  $*"; }
warn() { echo "⚠️  $*" >&2; }
err() { echo "❌ $*" >&2; }

# 1. Hyprland environment check
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
[[ "$VERBOSE" == "1" ]] && log "✅ Hyprland environment detected"

# 2. Dependency check
# Format: "binary_name:package_hint"
# Note: 'awww' below — replace with actual binary if different (e.g., 'swww')
DEPS=(
    "git:git"
    "dunst:dunst"
    "kitty:kitty"
    "waybar:waybar"
    "fuzzel:fuzzel"
    "wallust:wallust"
    "hyprctl:hyprland"
    "hyprctl:hyprpaper"
)

if [[ "$SKIP_DEPS" != "1" ]]; then
    MISSING=()
    for entry in "${DEPS[@]}"; do
        binary="${entry%%:*}"
        pkg="${entry##*:}"
        if command -v "$binary" &>/dev/null; then
            [[ "$VERBOSE" == "1" ]] && log "✅ Found: $binary"
        else
            warn "❌ Missing: $binary (package: $pkg)"
            MISSING+=("$pkg")
        fi
    done

    if [ ${#MISSING[@]} -gt 0 ]; then
        echo ""
        err "Missing dependencies: ${MISSING[*]}"
        if command -v pacman &>/dev/null; then
            echo "💡 Install with: sudo pacman -S ${MISSING[*]}"
        elif command -v apt &>/dev/null; then
            echo "💡 Install with: sudo apt install ${MISSING[*]}"
        fi
        echo "🔁 Or run with SKIP_DEPS=1 to bypass checks"
        exit 1
    fi
    log "✅ All dependencies satisfied"
else
    warn "⚠️ Skipping dependency checks (SKIP_DEPS=1)"
fi

# 3. Backup existing configs
log "📦 Backing up existing configurations..."
BACKUP_STAMP="$(date +%Y%m%d_%H%M%S)"
for entry in "${DEPS[@]}"; do
    binary="${entry%%:*}"
    [[ "$binary" =~ ^(git|hyprctl|awww)$ ]] && continue  # skip non-config deps
    CONFIG_DIR="$HOME/.config/$binary"
    if [ -d "$CONFIG_DIR" ]; then
        BACKUP_DIR="$HOME/.config/${binary}.bak.$BACKUP_STAMP"
        cp -a "$CONFIG_DIR" "$BACKUP_DIR"
        [[ "$VERBOSE" == "1" ]] && log "   Backed up $CONFIG_DIR"
    fi
done

# 4. Fetch repo
log "🌐 Cloning repository..."
TEMP_REPO=$(mktemp -d)
trap 'rm -rf "$TEMP_REPO"' EXIT
git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$TEMP_REPO"

# 5. Deploy configs to ~/.config/
log "📥 Deploying configurations..."
for entry in "${DEPS[@]}"; do
    binary="${entry%%:*}"
    [[ "$binary" =~ ^(git|hyprctl|awww)$ ]] && continue
    SRC_DIR="$TEMP_REPO/$binary"
    DEST_DIR="$HOME/.config/$binary"
    if [ -d "$SRC_DIR" ]; then
        mkdir -p "$DEST_DIR"
        cp -a "$SRC_DIR"/. "$DEST_DIR"/
        [[ "$VERBOSE" == "1" ]] && log "   Deployed $binary"
    fi
done

# 6. Special handling: wallpapers → ~/wallpapers
WALLPAPERS_SRC="$TEMP_REPO/wallpapers"
WALLPAPERS_DEST="$HOME/wallpapers"
if [ -d "$WALLPAPERS_SRC" ]; then
    mkdir -p "$WALLPAPERS_DEST"
    cp -a "$WALLPAPERS_SRC"/. "$WALLPAPERS_DEST"/
    log "   Deployed wallpapers to ~/wallpapers"
fi

# 7. Post-deploy hint for awww/swww
if command -v awww &>/dev/null 2>&1; then
    log "🎨 Wallpaper tool detected. You may need to start it:"
    log "   • Add to hyprland.conf: exec-once = awww --daemon"
    log "   • Or run manually: awww --init"
fi

log "✨ Done! Apply changes with:"
log "   • hyprctl reload"
log "   • Restart: kitty, waybar, dunst, fuzzel"
