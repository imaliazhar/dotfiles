#!/bin/sh

# Shows a system_stats value (from stats_provider) and colors it yellow → orange
# → red as it crosses the item's warn/high/critical thresholds (in %).

case "$NAME" in
cpu_usage) VALUE="$CPU_USAGE" && set -- 50 75 90 ;;
ram_usage) VALUE="$RAM_USAGE" && set -- 70 85 95 ;;
disk_usage) VALUE="$DISK_USAGE" && set -- 50 75 90 ;;
*) exit 0 ;;
esac

# Nothing to show until stats_provider sends its first event.
[ -z "$VALUE" ] && exit 0

PERCENT="${VALUE%\%}"

source "$CONFIG_DIR/theme.sh"

COLOR=$DIM_COLOR # normal
if [ "$PERCENT" -ge "$3" ] 2>/dev/null; then
  COLOR=0xFFF38BA8 # red
elif [ "$PERCENT" -ge "$2" ] 2>/dev/null; then
  COLOR=0xFFFAB387 # orange
elif [ "$PERCENT" -ge "$1" ] 2>/dev/null; then
  COLOR=0xFFF9E2AF # yellow
fi

$BAR_NAME --set "$NAME" label="$VALUE" label.color=$COLOR icon.color=$COLOR
