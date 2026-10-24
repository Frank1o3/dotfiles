#!/bin/sh

set -eu

# Resolve the repository root from this script's location.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SDDM_SRC="$SCRIPT_DIR/sddm"
THEME_SRC="$SDDM_SRC/theme"

SDDM_THEME_NAME="quickshell-glass"
SDDM_THEME_DEST="/usr/share/sddm/themes/$SDDM_THEME_NAME"

SYNC_SCRIPT_SRC="$SDDM_SRC/sddm-theme-sync.py"
SYNC_SERVICE_SRC="$SDDM_SRC/sddm-theme-sync.service"
SYNC_PATH_SRC="$SDDM_SRC/sddm-theme-sync.path"

SYNC_SCRIPT_DEST="/usr/local/bin/sddm-theme-sync.py"
SYNC_SERVICE_DEST="/etc/systemd/system/sddm-theme-sync.service"
SYNC_PATH_DEST="/etc/systemd/system/sddm-theme-sync.path"

THEME_USER="${1:-${USER:-$(id -un)}}"
THEME_HOME=$(getent passwd "$THEME_USER" | cut -d: -f6)
if [ -z "$THEME_HOME" ]; then
    THEME_HOME="$HOME"
fi

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
fi

echo "Updating SDDM theme: $SDDM_THEME_NAME for user $THEME_USER"

# ---------------------------------------------------------------------------
# Validate repository
# ---------------------------------------------------------------------------

for file in \
    "$THEME_SRC/Main.qml" \
    "$THEME_SRC/metadata.desktop" \
    "$THEME_SRC/theme.conf" \
    "$SYNC_SCRIPT_SRC" \
    "$SYNC_SERVICE_SRC" \
    "$SYNC_PATH_SRC"
do
    if [ ! -f "$file" ]; then
        echo "Error: missing required file:"
        echo "  $file"
        exit 1
    fi
done

# ---------------------------------------------------------------------------
# Install theme
# ---------------------------------------------------------------------------

echo "Installing theme files..."
$SUDO rm -rf "$SDDM_THEME_DEST"

$SUDO mkdir -p "$SDDM_THEME_DEST/backgrounds"

$SUDO cp -r "$THEME_SRC/." "$SDDM_THEME_DEST/"

# Keep the currently configured wallpaper as SDDM's default background
# when available. This avoids destroying a working background on update.
if [ -f "$THEME_HOME/wallpapers/wallpaper.jpg" ]; then
    echo "Updating default SDDM background..."
    $SUDO cp "$THEME_HOME/wallpapers/wallpaper.jpg" \
        "$SDDM_THEME_DEST/backgrounds/default.jpg"
fi

# ---------------------------------------------------------------------------
# Configure SDDM
# ---------------------------------------------------------------------------

echo "Setting SDDM theme as active theme..."

$SUDO mkdir -p /etc/sddm.conf.d

$SUDO tee /etc/sddm.conf.d/theme.conf >/dev/null <<EOF
[Theme]

Current=$SDDM_THEME_NAME
EOF

# ---------------------------------------------------------------------------
# Install theme sync script
# ---------------------------------------------------------------------------

echo "Installing theme synchronization script..."

$SUDO install -Dm755 \
    "$SYNC_SCRIPT_SRC" \
    "$SYNC_SCRIPT_DEST"

# ---------------------------------------------------------------------------
# Install systemd units
# ---------------------------------------------------------------------------

echo "Installing systemd synchronization units..."

sed \
    -e "s|{USERNAME}|$THEME_USER|g" \
    "$SYNC_SERVICE_SRC" |
    $SUDO tee "$SYNC_SERVICE_DEST" >/dev/null

sed \
    -e "s|{HOME}|$THEME_HOME|g" \
    "$SYNC_PATH_SRC" |
    $SUDO tee "$SYNC_PATH_DEST" >/dev/null

# ---------------------------------------------------------------------------
# Reload and enable synchronization
# ---------------------------------------------------------------------------

if systemctl is-system-running >/dev/null 2>&1; then
    echo "Reloading systemd..."
    $SUDO systemctl daemon-reload

    echo "Enabling SDDM theme synchronization..."
    $SUDO systemctl enable --now sddm-theme-sync.path

    echo "Applying current theme..."
    if $SUDO /usr/local/bin/sddm-theme-sync.py "$THEME_USER"; then
        echo "Theme synchronization completed."
    else
        echo "Warning: theme synchronization failed."
    fi
else
    echo "Enabling SDDM theme synchronization (offline)..."
    $SUDO systemctl enable sddm-theme-sync.path 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# Cleanup / status
# ---------------------------------------------------------------------------

echo
echo "SDDM theme update complete."
echo "Theme:   $SDDM_THEME_NAME"
echo "Path:    $SDDM_THEME_DEST"
echo

if systemctl is-enabled --quiet sddm-theme-sync.path 2>/dev/null; then
    echo "Sync path: enabled"
else
    echo "Sync path: not enabled"
fi

if systemctl is-active --quiet sddm-theme-sync.path 2>/dev/null; then
    echo "Sync path: active"
else
    echo "Sync path: inactive"
fi
