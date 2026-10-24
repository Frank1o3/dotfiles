#!/bin/sh
if ! command -v cava >/dev/null 2>&1; then
    exit 0
fi

CONFIG="/tmp/quickshell-cava-${USER:-default}.conf"
cat > "$CONFIG" << 'EOF'
[general]
bars = 8
framerate = 30

[input]
method = pulse
source = auto

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
bar_delimiter = 59
frame_delimiter = 10
EOF

exec cava -p "$CONFIG"
