#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

sync_gtk() {
    local version="$1"

    local SRC="$DOTFILES_DIR/wallust/.config/gtk-$version.0"
    local DEST="$HOME/.config/gtk-$version.0"

    echo "Syncing GTK$version overrides..."

    mkdir -p "$DEST"

    # Clean old files
    rm -f "$DEST/gtk.css"

    # Copy fresh files
    cp "$SRC/gtk.css" "$DEST/"

    echo "✓ GTK$version synced"
}

sync_gtk 3
sync_gtk 4

# Clear GTK caches
rm -rf "$HOME/.cache/gtk-"* 2>/dev/null || true

echo "✓ GTK cache cleared"
echo "Done."