#!/bin/sh
if ! command -v cava >/dev/null 2>&1; then
    exit 0
fi

exec cava
