#!/usr/bin/env bash
set -euo pipefail

# Options
OPTIONS="Sign Out
Sleep
Hibernate
Reboot
Shutdown
Lock"

# Open fuzzel dmenu
CHOICE=$(echo "$OPTIONS" | fuzzel --dmenu --prompt='Power Menu')

# Exit if user cancels
[ -z "$CHOICE" ] && exit 0

# Execute selection
case "$CHOICE" in
  "Sign Out")
    notify-send "Signing out" "Ending Hyprland session..."
    hyprshutdown
    ;;
  "Sleep")
    notify-send "Sleeping" "System suspending"
    systemctl suspend
    ;;
  "Hibernate")
    notify-send "Hibernating" "System hibernating"
    systemctl hibernate
    ;;
  "Reboot")
    notify-send "Rebooting" "System restarting"
    systemctl reboot
    ;;
  "Shutdown")
    notify-send "Shutting down" "System powering off"
    systemctl poweroff
    ;;
  "Lock")
    notify-send "Locking" "Screen locked"
    # Tries hyprlock, falls back to swaylock, then loginctl
    if command -v hyprlock &>/dev/null; then
      hyprlock
    elif command -v swaylock &>/dev/null; then
      swaylock
    else
      loginctl lock-session
    fi
    ;;
esac