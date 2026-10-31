#!/bin/sh

# Hidden on the home network; otherwise shows the network's name, or that Wi-Fi is down.
# The name is only readable after a one-time `sudo ipconfig setverbose 1`; without
# it macOS reports every network as <redacted>.

HOME_WIFI="FRITZ!Box 7490-5G"

source "$CONFIG_DIR/theme.sh"

INTERFACE="$(networksetup -listallhardwareports | awk '/Wi-Fi/ { getline; print $2 }')"
SSID="$(ipconfig getsummary "$INTERFACE" 2>/dev/null | awk -F ' SSID : ' '/ SSID : / { print $2 }')"

if [ "$SSID" = "$HOME_WIFI" ]; then
  $BAR_NAME --set "$NAME" drawing=off --set "${NAME}_gap" drawing=off
elif [ -z "$SSID" ]; then
  $BAR_NAME --set "$NAME" drawing=on icon=󰖪 label="No Wi-Fi" icon.color=0xFF970000 label.color=0xFF970000 \
            --set "${NAME}_gap" drawing=on
else
  $BAR_NAME --set "$NAME" drawing=on icon=󰖩 label="$SSID" icon.color=$DIM_COLOR label.color=$DIM_COLOR \
            --set "${NAME}_gap" drawing=on
fi
