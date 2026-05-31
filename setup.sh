#!/usr/bin/env fish

echo "This script will install the packages needed to use my config."
echo "It will also run the config installation script."

for cmd in curl paru python3
    if not command -q $cmd
        echo "Error: $cmd is not installed."
        exit 1
    end
end

set URL "https://raw.githubusercontent.com/Frank1o3/dotfiles/main/packages.txt"

echo "Fetching package list..."

set packages (
    curl -fsSL $URL |
    grep -v '^#' |
    grep -v '^$'
)

if test $status -ne 0
    echo "Failed to download package list."
    exit 1
end

echo "Installing packages..."
paru -S --needed (string split \n $packages)

or begin
    echo "Package installation failed."
    exit 1
end

echo "Running config install script..."

curl -fsSL \
    "https://raw.githubusercontent.com/Frank1o3/dotfiles/main/install.py" |
    python3 -

or begin
    echo "Config installation failed."
    exit 1
end

echo "Done."