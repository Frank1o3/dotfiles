#!/usr/bin/env bash

set -uo pipefail

ACTION="${1:-get}"

case "$ACTION" in
    get)
        ddcutil --brief getvcp 10 2>/dev/null \
          | awk '{print $4}'
        ;;
    up)
        ddcutil --sleep-multiplier=.1 setvcp 10 + 5 >/dev/null
        ;;
    down)
        ddcutil --sleep-multiplier=.1 setvcp 10 - 5 >/dev/null
        ;;
esac