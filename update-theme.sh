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

echo "Updating SDDM theme: $SDDM_THEME_NAME"

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

sudo mkdir -p "$SDDM_THEME_DEST/backgrounds"

sudo cp -r "$THEME_SRC/." "$SDDM_THEME_DEST/"

# Keep the currently configured wallpaper as SDDM's default background
# when available. This avoids destroying a working background on update.
if [ -f "$HOME/wallpapers/wallpaper.jpg" ]; then
    echo "Updating default SDDM background..."
    sudo cp "$HOME/wallpapers/wallpaper.jpg" \
        "$SDDM_THEME_DEST/backgrounds/default.jpg"
fi

# ---------------------------------------------------------------------------
# Configure SDDM
# ---------------------------------------------------------------------------

echo "Setting SDDM theme as active theme..."

sudo mkdir -p /etc/sddm.conf.d

sudo tee /etc/sddm.conf.d/theme.conf >/dev/null <<EOF
[Theme]

Current=$SDDM_THEME_NAME
EOF

# ---------------------------------------------------------------------------
# Install theme sync script
# ---------------------------------------------------------------------------

echo "Installing theme synchronization script..."

sudo install -Dm755 \
    "$SYNC_SCRIPT_SRC" \
    "$SYNC_SCRIPT_DEST"

# ---------------------------------------------------------------------------
# Install systemd units
# ---------------------------------------------------------------------------

echo "Installing systemd synchronization units..."

sed \
    -e "s|{USERNAME}|$USER|g" \
    "$SYNC_SERVICE_SRC" |
    sudo tee "$SYNC_SERVICE_DEST" >/dev/null

sed \
    -e "s|{HOME}|$HOME|g" \
    "$SYNC_PATH_SRC" |
    sudo tee "$SYNC_PATH_DEST" >/dev/null

# ---------------------------------------------------------------------------
# Reload and enable synchronization
# ---------------------------------------------------------------------------

echo "Reloading systemd..."

sudo systemctl daemon-reload

echo "Enabling SDDM theme synchronization..."

sudo systemctl enable --now sddm-theme-sync.path

# ---------------------------------------------------------------------------
# Apply theme immediately
# ---------------------------------------------------------------------------

echo "Applying current theme..."

if sudo /usr/local/bin/sddm-theme-sync.py "$USER"; then
    echo "Theme synchronization completed."
else
    echo "Warning: theme synchronization failed."
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