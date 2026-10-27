#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# The date sits in the icon slot so it can be dimmed next to the time.
$BAR_NAME --set "$NAME" icon="$(date "+%a %-d %b")" label="$(date "+%-I:%M")"
