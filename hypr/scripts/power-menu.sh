#!/usr/bin/env bash
set -euo pipefail

# Options (use exact strings for case matching)
OPTIONS="Sign Out
Sleep
Hibernate
Reboot
Shutdown
Lock"

# Open fuzzel dmenu
CHOICE=$(echo "$OPTIONS" | fuzzel --dmenu --prompt='Power Menu')

# Exit if user cancels (ESC or clicks away)
[ -z "$CHOICE" ] && exit 0

# Execute selection
case "$CHOICE" in
  "Sign Out")
    notify-send "Signing out" "Ending Hyprland session"
    hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit
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
    # Tries hyprlock (official), falls back to swaylock, then loginctl
    command -v hyprlock &>/dev/null && hyprlock || \
    command -v swaylock &>/dev/null && swaylock || \
    loginctl lock-session
    ;;
esac