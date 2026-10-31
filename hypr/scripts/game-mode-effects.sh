#!/usr/bin/env bash
# Apply or restore the lightweight Hyprland profile while gamemoded is active.
set -u

state=${1:-}
case "$state" in
    on)
        hyprctl keyword decoration:blur:enabled 0 >/dev/null
        hyprctl keyword decoration:shadow:enabled 0 >/dev/null
        hyprctl keyword decoration:screen_shader "" >/dev/null
        hyprctl keyword decoration:active_opacity 1 >/dev/null
        hyprctl keyword decoration:inactive_opacity 1 >/dev/null
        hyprctl keyword decoration:rounding 0 >/dev/null
        hyprctl keyword animations:enabled 0 >/dev/null
        hyprctl keyword general:allow_tearing 1 >/dev/null
        pkill -x awww >/dev/null 2>&1 || true
        pkill -x awww-daemon >/dev/null 2>&1 || true
        ;;
    off)
        hyprctl keyword decoration:blur:enabled 1 >/dev/null
        hyprctl keyword decoration:shadow:enabled 1 >/dev/null
        hyprctl keyword decoration:screen_shader "$HOME/.config/hypr/shaders/glass-tint.frag" >/dev/null
        hyprctl keyword decoration:active_opacity 0.88 >/dev/null
        hyprctl keyword decoration:inactive_opacity 0.78 >/dev/null
        hyprctl keyword decoration:rounding 14 >/dev/null
        hyprctl keyword animations:enabled 1 >/dev/null
        pgrep -x awww-daemon >/dev/null || (awww-daemon >/dev/null 2>&1 &)
        (sleep 0.7; awww img "$HOME/wallpapers/wallpaper.jpg" >/dev/null 2>&1) &
        ;;
    *) echo "Usage: $0 on|off" >&2; exit 2 ;;
esac
