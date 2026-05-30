#!/usr/bin/env bash

set -uo pipefail

ACTION="${1:-get}"

case "$ACTION" in
    get)
        brightnessctl get 10 2>/dev/null \
            | awk '{print $4}'
        ;;
    up)
        brightnessctl -e4 -n2 set 5%+ >/dev/null
        ;;
    down)
        brightnessctl -e4 -n2 set 5%- >/dev/null
        ;;
esac