#!/bin/sh

set -e

REPO_URL="https://github.com/Frank1o3/dotfiles.git"
TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

echo "Checking prerequisites..."

for cmd in git paru; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

echo "Cloning dotfiles repository..."

git clone --depth 1 "$REPO_URL" "$TMP_DIR"

echo "Installing packages..."

paru -Syu --needed --noconfirm --skipreview $(
    grep -v '^#' "$TMP_DIR/packages.txt" |
    grep -v '^$'
)

echo "Enabling services..."

systemctl --user enable --now gnome-keyring-daemon.service || true
systemctl --user enable --now hyprpolkitagent.service || true

echo
echo "==> Synchronizing configuration..."
echo

AUTO=1 python3 -u "$TMP_DIR/sync-config.py"

echo
echo "==> Configuration synchronization complete."
echo "Setting up SDDM theme..."

chmod +x "$TMP_DIR/update-theme.sh"
"$TMP_DIR/update-theme.sh"

echo "Making utility scripts executable..."

chmod +x ~/.config/hypr/scripts/set-wallpaper.sh
chmod +x ~/.config/hypr/scripts/emoticon.py
chmod +x ~/.config/quickshell/scripts/sysmon.sh

echo "Setting up default applications..."

xdg-mime default thunar.desktop inode/directory
xdg-mime default thunar.desktop application/x-directory

xdg-mime default code.desktop text/plain
xdg-mime default code.desktop text/x-shellscript
xdg-mime default code.desktop text/x-python

echo "Configuring Git..."

git config --global core.editor "code --wait"
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait "$MERGED"'

echo "Done."