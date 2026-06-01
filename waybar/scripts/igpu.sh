#!/bin/bash
# Intel iGPU frequency monitor - works with card1
CARD="card1"  # Your Intel HD 530 is on card1

FREQ=$(cat /sys/class/drm/${CARD}/gt_cur_freq_mhz 2>/dev/null)
MAX=$(cat /sys/class/drm/${CARD}/gt_max_freq_mhz 2>/dev/null)
MIN=$(cat /sys/class/drm/${CARD}/gt_min_freq_mhz 2>/dev/null)
ACTUAL=$(cat /sys/class/drm/${CARD}/gt_act_freq_mhz 2>/dev/null)

if [ -n "$FREQ" ]; then
  echo "󰢮  ${ACTUAL:-$FREQ}/${MAX} MHz"
else
  echo "󰢮  N/A"
fi