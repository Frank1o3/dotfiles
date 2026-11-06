#!/bin/bash
CARD="card1"
PREV_IDLE=0
PREV_TOTAL=0

while true; do
    read -r _ u n s i io irq sirq st _ < /proc/stat
    idle=$((i + io))
    total=$((u + n + s + i + io + irq + sirq + st))
    d_idle=$((idle - PREV_IDLE))
    d_total=$((total - PREV_TOTAL))

    if [ "$PREV_TOTAL" -gt 0 ] && [ "$d_total" -gt 0 ]; then
        cpu=$(( (100 * (d_total - d_idle)) / d_total ))
    else
        cpu=0
    fi
    PREV_IDLE=$idle
    PREV_TOTAL=$total

    cur=$(cat /sys/class/drm/${CARD}/gt_act_freq_mhz 2>/dev/null || cat /sys/class/drm/${CARD}/gt_cur_freq_mhz 2>/dev/null)
    max=$(cat /sys/class/drm/${CARD}/gt_max_freq_mhz 2>/dev/null)
    if [ -n "$cur" ] && [ -n "$max" ] && [ "$max" -gt 0 ] 2>/dev/null; then
        igpu=$((cur * 100 / max))
    else
        igpu=-1
    fi

    memory=$(awk '/MemTotal:/ { total=$2 } /MemAvailable:/ { available=$2 } END { if (total > 0) printf "%d", (total-available)*100/total; else print 0 }' /proc/meminfo)
    disk=$(df -P / | awk 'NR==2 { gsub(/%/, "", $5); print $5+0 }')

    printf '{"cpu":%d,"igpu":%d,"memory":%d,"disk":%d}\n' "$cpu" "$igpu" "$memory" "$disk"
    sleep 2
done
