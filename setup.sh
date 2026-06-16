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

echo "Installing packages..."

paru -S --needed $(
    curl -fsSL "$URL" |
    grep -v '^#' |
    grep -v '^$'
)

echo "Running config install script..."

curl -fsSL \
    "https://raw.githubusercontent.com/Frank1o3/dotfiles/main/install.py" |
    python3 -

echo "Done."
