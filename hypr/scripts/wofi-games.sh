#!/usr/bin/env bash

APP_DIRS=(
    /usr/share/applications
    ~/.local/share/applications
    /var/lib/flatpak/exports/share/applications
    ~/.local/share/flatpak/exports/share/applications
)

declare -A entries

# -----------------------------
# Parse .desktop files
# -----------------------------
parse_desktop() {
    local file="$1"

    local name exec icon categories nodisplay

    name=$(grep -m1 "^Name=" "$file" | cut -d= -f2-)
    exec=$(grep -m1 "^Exec=" "$file" | cut -d= -f2-)
    icon=$(grep -m1 "^Icon=" "$file" | cut -d= -f2-)
    categories=$(grep -m1 "^Categories=" "$file")
    nodisplay=$(grep -m1 "^NoDisplay=true" "$file")

    # skip hidden entries
    [[ -n "$nodisplay" ]] && return

    # detect games
    if echo "$categories" | grep -qi "Game" \
        || echo "$exec" | grep -Eqi "steam|lutris|heroic"; then
        # clean exec
        exec=$(echo "$exec" | sed 's/ *%[fFuUdDnNickvm]//g')

        entries["$name"]="$exec|$icon"
    fi
}

# -----------------------------
# Scan all application dirs
# -----------------------------
for dir in "${APP_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    for file in "$dir"/*.desktop; do
        [[ -f "$file" ]] || continue
        parse_desktop "$file"
    done
done

# -----------------------------
# Build wofi menu
# -----------------------------
menu=""

for name in $(printf "%s\n" "${!entries[@]}" | sort); do
    icon=$(echo "${entries[$name]}" | cut -d'|' -f2)
    menu+="$name\0icon\x1f$icon\n"
done

# -----------------------------
# Launch selection
# -----------------------------
choice=$(echo -e "$menu" | wofi --dmenu -I --prompt "Games")

[[ -z "$choice" ]] && exit

cmd=$(echo "${entries[$choice]}" | cut -d'|' -f1)

# run it
eval "$cmd"