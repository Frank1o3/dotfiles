#!/bin/sh

set -e

echo "This script will install the packages needed to use my config."
echo "It will also run the config installation script."

for cmd in curl paru python3; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Error: $cmd is not installed."
        exit 1
    }
done

URL="https://raw.githubusercontent.com/Frank1o3/dotfiles/main/packages.txt"
SCRIPT_URL="https://raw.githubusercontent.com/Frank1o3/dotfiles/main/update-config.py"

echo "Installing packages..."

paru -Syu --needed --noconfirm --skipreview $(
    curl -fsSL "$URL" |
    grep -v '^#' |
    grep -v '^$'
)

echo "Enable services..."
systemctl --user enable gnome-keyring-daemon.service || true
systemctl --user start gnome-keyring-daemon.service || true

systemctl --user enable hyprpolkitagent.service || true
systemctl --user start hyprpolkitagent.service || true

echo "Running config update/install script..."

tmpfile=$(mktemp)
curl -fsSL "$SCRIPT_URL" -o "$tmpfile"
python3 "$tmpfile"
rm -f "$tmpfile"

echo "Making utility script executable"
chmod +x ~/.config/hypr/scripts/pick-wallpaper.sh
chmod +x ~/.config/hypr/scripts/power-menu.sh
chmod +x ~/.config/waybar/scripts/igpu.sh
chmod +x ~/.config/waybar/scripts/emoticon.py

echo "Setting up default apps"

xdg-mime default thunar.desktop inode/directory
xdg-mime default thunar.desktop application/x-directory
xdg-mime default code.desktop text/plain
xdg-mime default code.desktop text/x-shellscript
xdg-mime default code.desktop text/x-python

git config --global core.editor "code --wait"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "code --wait $MERGED"

echo "Done."
