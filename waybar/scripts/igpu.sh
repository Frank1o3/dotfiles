#!/bin/bash
CARD="card1"
CURRENT=$(cat /sys/class/drm/${CARD}/gt_act_freq_mhz 2>/dev/null || cat /sys/class/drm/${CARD}/gt_cur_freq_mhz 2>/dev/null)
MAX=$(cat /sys/class/drm/${CARD}/gt_max_freq_mhz 2>/dev/null)

if [ -n "$CURRENT" ] && [ -n "$MAX" ] && [ "$MAX" -gt 0 ] 2>/dev/null; then
  PERCENT=$((CURRENT * 100 / MAX))
  echo "${PERCENT}%"
else
  echo "--"
fi