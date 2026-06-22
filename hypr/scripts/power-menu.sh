#!/usr/bin/env sh
set -eu

OPTIONS=$(cat <<EOF
Lock
Sleep
Hibernate
Reboot
Shutdown
Sign Out
EOF
)

CHOICE=$(printf "%s\n" "$OPTIONS" | \
  fzf \
    --prompt="⏻ Power Menu: " \
    --layout=reverse \
    --border \
    --height=100% \
    --cycle
)

[ -z "${CHOICE:-}" ] && exit 0

notify() {
  notify-send "$1" "$2"
}

case "$CHOICE" in
  "Lock")
    notify "Locking" "Screen locked"
    if command -v hyprlock >/dev/null 2>&1; then
      hyprlock
    elif command -v swaylock >/dev/null 2>&1; then
      swaylock
    else
      loginctl lock-session
    fi
    ;;

  "Sleep")
    notify "Sleeping" "System suspending"
    systemctl suspend
    ;;

  "Hibernate")
    notify "Hibernating" "System hibernating"
    systemctl hibernate
    ;;

  "Reboot")
    notify "Rebooting" "System restarting"
    systemctl reboot
    ;;

  "Shutdown")
    notify "Shutting down" "System powering off"
    systemctl poweroff
    ;;

  "Sign Out")
    notify "Signing out" "Ending Hyprland session..."
    hyprctl dispatch exit
    ;;
esac