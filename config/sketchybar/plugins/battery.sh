#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

# Nerd Font battery icons for 0%, 10%, ... 90%, 100%
set -- 󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹
shift $((PERCENTAGE / 10))
ICON="$1"

if [ "$CHARGING" != "" ]; then
  ICON="󰂄"
fi

source "$CONFIG_DIR/theme.sh"

COLOR=$DIM_COLOR

if [ "$PERCENTAGE" -le 5 ]; then
  COLOR=0xFF970000
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
$BAR_NAME --set "$NAME" icon="$ICON" label="$PERCENTAGE%" icon.color=$COLOR label.color=$COLOR
