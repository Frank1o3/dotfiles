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

echo "Setting up SDDM theme..."

SDDM_THEME_NAME="quickshell-glass"
SDDM_THEME_DEST="/usr/share/sddm/themes/$SDDM_THEME_NAME"
SDDM_TMP=$(mktemp -d)

if [ -d "./sddm" ]; then
    SDDM_SRC="./sddm"
else
    echo "Fetching sddm theme files..."
    mkdir -p "$SDDM_TMP/sddm/theme"
    for f in theme.conf Main.qml metadata.desktop; do
        curl -fsSL "$REPO_RAW/sddm/theme/$f" -o "$SDDM_TMP/sddm/theme/$f"
    done
    curl -fsSL "$REPO_RAW/sddm/sddm-theme-sync.py" -o "$SDDM_TMP/sddm/sddm-theme-sync.py"
    curl -fsSL "$REPO_RAW/sddm/sddm-theme-sync.service" -o "$SDDM_TMP/sddm/sddm-theme-sync.service"
    curl -fsSL "$REPO_RAW/sddm/sddm-theme-sync.path" -o "$SDDM_TMP/sddm/sddm-theme-sync.path"
    SDDM_SRC="$SDDM_TMP/sddm"
fi

# Install theme files
sudo mkdir -p "$SDDM_THEME_DEST/backgrounds"
sudo cp -r "$SDDM_SRC/theme/." "$SDDM_THEME_DEST/"

# Seed a starting background so SDDM has something before the first sync
if [ -f "$HOME/wallpapers/wallpaper.jpg" ]; then
    sudo cp "$HOME/wallpapers/wallpaper.jpg" "$SDDM_THEME_DEST/backgrounds/default.jpg"
fi

# Set this theme as SDDM's active theme
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/theme.conf >/dev/null <<EOF
[Theme]
Current=$SDDM_THEME_NAME
EOF

# Install the color-sync script
sudo install -Dm755 "$SDDM_SRC/sddm-theme-sync.py" /usr/local/bin/sddm-theme-sync.py

# Install systemd units, substituting the real user + home into placeholders
sed "s|{USERNAME}|$USER|g" "$SDDM_SRC/sddm-theme-sync.service" \
    | sudo tee /etc/systemd/system/sddm-theme-sync.service >/dev/null

sed "s|{HOME}|$HOME|g" "$SDDM_SRC/sddm-theme-sync.path" \
    | sudo tee /etc/systemd/system/sddm-theme-sync.path >/dev/null

sudo systemctl daemon-reload
sudo systemctl enable --now sddm-theme-sync.path

# Seed the theme immediately so the very first login screen already matches
sudo /usr/local/bin/sddm-theme-sync.py "$USER" || true

rm -rf "$SDDM_TMP"

echo "SDDM theme installed and set as current."

echo "Done."
