#!/bin/sh

# Shows whether the headphones are connected; clicking connects or disconnects them.

HEADPHONES="Bose QC Ultra Headphones"

source "$CONFIG_DIR/theme.sh"

# blueutil --paired lists lines like: address: e4-58-bc-2d-07-00, ..., name: "Bose QC Ultra Headphones", ...
ADDRESS="$(blueutil --paired | grep -F "name: \"$HEADPHONES\"" | head -1 | sed -E 's/^address: ([^,]+),.*/\1/')"

if [ -z "$ADDRESS" ]; then
  $BAR_NAME --set "$NAME" drawing=off --set "${NAME}_gap" drawing=off
  exit 0
fi

render() {
  $BAR_NAME --set "${NAME}_gap" drawing=on
  if [ "$(blueutil --is-connected "$ADDRESS")" = "1" ]; then
    $BAR_NAME --set "$NAME" drawing=on icon=󰋋 icon.color=$TEXT_COLOR label.drawing=off
  else
    $BAR_NAME --set "$NAME" drawing=on icon=󰟎 icon.color=$DIM_COLOR label.drawing=off
  fi
}

if [ "$SENDER" = "mouse.clicked" ]; then
  # Connecting takes a few seconds, so show what's happening until it settles
  if [ "$(blueutil --is-connected "$ADDRESS")" = "1" ]; then
    $BAR_NAME --set "$NAME" icon.color=$DIM_COLOR label="Disconnecting…" label.drawing=on
    blueutil --disconnect "$ADDRESS" --wait-disconnect "$ADDRESS" 10
  else
    $BAR_NAME --set "$NAME" icon.color=$DIM_COLOR label="Connecting…" label.drawing=on
    blueutil --connect "$ADDRESS" --wait-connect "$ADDRESS" 10
  fi
fi

render
