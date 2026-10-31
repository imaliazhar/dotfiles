#!/bin/sh

# Shows a system_stats value (from stats_provider) and colors it yellow → orange
# → red as it crosses the item's warn/high/critical thresholds (in %).
# Clicking any stat toggles every stat's icon between a glyph and a short name.

# item:glyph:name for each stat
STATS="cpu_usage:󰻠:cpu ram_usage:󰍛:ram disk_usage:󰋊:sto"

# show_icons glyph|name sets every stat's icon to its glyph or its name.
show_icons() {
  for stat in $STATS; do
    item="${stat%%:*}"
    rest="${stat#*:}"
    if [ "$1" = name ]; then
      $BAR_NAME --set "$item" icon="${rest#*:}" icon.font="Roboto:Medium:13.0"
    else
      $BAR_NAME --set "$item" icon="${rest%%:*}" icon.font="Hack Nerd Font:Regular:14.0"
    fi
  done
}

case "$SENDER" in
forced)
  show_icons glyph
  exit 0
  ;;
mouse.clicked)
  if [ "$($BAR_NAME --query cpu_usage | jq -r .icon.value)" = cpu ]; then
    show_icons glyph
  else
    show_icons name
  fi
  exit 0
  ;;
esac

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
