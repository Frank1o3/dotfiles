#!/bin/sh

set -e

REPO_URL="https://github.com/Frank1o3/dotfiles.git"

CONFIG_ONLY=0
TARGET_USER=""

while [ $# -gt 0 ]; do
    case "$1" in
        --config-only)
            CONFIG_ONLY=1
            shift
            ;;
        --user)
            TARGET_USER="$2"
            shift 2
            ;;
        --user=*)
            TARGET_USER="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -n "$TARGET_USER" ]; then
    TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
    if [ -z "$TARGET_HOME" ] || [ ! -d "$TARGET_HOME" ]; then
        echo "Error: Cannot find home directory for user '$TARGET_USER'"
        exit 1
    fi
else
    TARGET_USER="${USER:-$(id -un)}"
    TARGET_HOME="${HOME:-$(getent passwd "$TARGET_USER" | cut -d: -f6)}"
fi

# Locate repo files (use local directory if run from clone, or clone to temp)
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ -f "$SCRIPT_DIR/sync-config.py" ]; then
    SRC_DIR="$SCRIPT_DIR"
else
    SRC_DIR="$(mktemp -d)"
    trap 'rm -rf "$SRC_DIR"' EXIT
    echo "Cloning dotfiles repository..."
    git clone --depth 1 "$REPO_URL" "$SRC_DIR"
fi

if [ "$CONFIG_ONLY" -eq 0 ]; then
    echo "Checking prerequisites..."
    for cmd in git paru python3 rsync; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: $cmd is not installed."
            exit 1
        fi
    done

    echo "Installing packages..."
    paru -Syu --needed --noconfirm --skipreview $(
        grep -v '^#' "$SRC_DIR/packages.txt" |
        grep -v '^$'
    )

    if systemctl is-system-running >/dev/null 2>&1; then
        echo "Enabling user services..."
        systemctl --user enable --now gnome-keyring-daemon.service || true
        systemctl --user enable --now hyprpolkitagent.service || true
    fi
else
    echo "Running in config-only mode..."
    for cmd in python3 rsync; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: $cmd is not installed."
            exit 1
        fi
    done
fi

echo
echo "==> Synchronizing configuration for $TARGET_USER ($TARGET_HOME)..."
echo

AUTO=1 HOME="$TARGET_HOME" XDG_CONFIG_HOME="$TARGET_HOME/.config" python3 -u "$SRC_DIR/sync-config.py"

echo
echo "==> Configuration synchronization complete."

echo "Setting up wallpapers..."
mkdir -p "$TARGET_HOME/wallpapers"
if [ -d "$SRC_DIR/wallpapers" ]; then
    cp -n "$SRC_DIR/wallpapers/"* "$TARGET_HOME/wallpapers/" 2>/dev/null || true
    if [ ! -f "$TARGET_HOME/wallpapers/wallpaper.jpg" ] && [ -f "$TARGET_HOME/wallpapers/night-sky.jpg" ]; then
        cp "$TARGET_HOME/wallpapers/night-sky.jpg" "$TARGET_HOME/wallpapers/wallpaper.jpg"
    fi
fi

echo "Setting up SDDM theme..."
chmod +x "$SRC_DIR/update-theme.sh"
"$SRC_DIR/update-theme.sh" "$TARGET_USER"

echo "Making utility scripts executable..."
chmod +x "$TARGET_HOME/.config/hypr/scripts/"*.sh 2>/dev/null || true
chmod +x "$TARGET_HOME/.config/hypr/scripts/emoticon.py" 2>/dev/null || true
chmod +x "$TARGET_HOME/.config/quickshell/scripts/"*.sh 2>/dev/null || true

# If running as root on behalf of a user, ensure correct ownership
if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/wallpapers"
fi

if [ "$CONFIG_ONLY" -eq 0 ] && [ -n "${DISPLAY:-${WAYLAND_DISPLAY:-}}" ]; then
    echo "Setting up default applications..."
    xdg-mime default thunar.desktop inode/directory 2>/dev/null || true
    xdg-mime default thunar.desktop application/x-directory 2>/dev/null || true

    xdg-mime default code.desktop text/plain 2>/dev/null || true
    xdg-mime default code.desktop text/x-shellscript 2>/dev/null || true
    xdg-mime default code.desktop text/x-python 2>/dev/null || true

    echo "Configuring Git..."
    git config --global core.editor "code --wait" 2>/dev/null || true
    git config --global merge.tool vscode 2>/dev/null || true
    git config --global mergetool.vscode.cmd 'code --wait "$MERGED"' 2>/dev/null || true
fi

echo "Done."
