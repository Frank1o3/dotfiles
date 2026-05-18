#!/bin/bash
# Copy TokyoNightWallust theme to system themes directory
# This allows GTK applications to use the theme with wallpaper-derived colors

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
THEME_SRC="$DOTFILES_DIR/wallust/themes/TokyoNightWallust"
THEME_DEST="$HOME/.themes/"

# Create destination directory if it doesn't exist
echo "Syncing TokyoNightWallust theme to $THEME_DEST..."
mkdir -p "$HOME/.local/share/themes"

# Copy/sync theme directory
cp -r "$THEME_SRC" "$THEME_DEST"

echo "✓ TokyoNightWallust theme synced to $THEME_DEST"
