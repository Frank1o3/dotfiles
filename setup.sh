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

echo "Cloning dotfiles repository..."

REPO_URL="https://github.com/Frank1o3/dotfiles.git"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

git clone --depth 1 "$REPO_URL" "$TMP_DIR"

echo "Synchronizing configuration..."
python3 "$TMP_DIR/sync-config.py"

echo "Setting up SDDM theme..."
chmod +x "$TMP_DIR/update-theme.sh"
"$TMP_DIR/update-theme.sh"

echo "Making utility script executable"
chmod +x ~/.config/hypr/scripts/set-wallpaper.sh
chmod +x ~/.config/hypr/scripts/emoticon.py
chmod +x ~/.config/quickshell/scripts/sysmon.sh

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
