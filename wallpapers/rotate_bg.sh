#!/usr/bin/env bash

# Configuration
DIR="/home/frank/wallpapers"
TARGET="$DIR/wallpaper.jpg"

# Navigate to directory safely
cd "$DIR" || { echo "Error: Directory '$DIR' not found."; exit 1; }

# 1. Resolve what the symlink currently points to
CURRENT_BG=""
if [ -L "$TARGET" ] && [ -e "$TARGET" ]; then
    CURRENT_BG=$(basename "$(readlink -f "$TARGET")")
fi

# 2. Pick a random image, excluding the symlink itself AND the current target
if [ -n "$CURRENT_BG" ]; then
    NEW_BG=$(find . -maxdepth 1 -name "*.jpg" ! -name "$TARGET" ! -name "$CURRENT_BG" -printf "%f\n" | shuf -n 1)
else
    # First run or broken/missing symlink: only exclude the symlink name
    NEW_BG=$(find . -maxdepth 1 -name "*.jpg" ! -name "$TARGET" -printf "%f\n" | shuf -n 1)
fi

# 3. Handle case where no other wallpapers exist
if [ -z "$NEW_BG" ]; then
    echo "No other wallpapers found in '$DIR' to rotate to."
    exit 0
fi

# 4. Update symlink (overwrites existing)
ln -sf "$NEW_BG" "$TARGET"

# 5. Apply wallpaper
wallust run "$TARGET"
awww img "$TARGET"

echo "Wallpaper rotated to: $NEW_BG"
