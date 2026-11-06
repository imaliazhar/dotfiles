#!/bin/sh

# Shows whether the Omio VPN is connected; clicking connects or disconnects it.

VPN="$HOME/.local/bin/omio-vpn"

source "$CONFIG_DIR/theme.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$("$VPN" status)" = "disconnected" ]; then
    $BAR_NAME --set "$NAME" icon.color=$DIM_COLOR icon.padding_right=6 label="Connecting…" label.color=$DIM_COLOR label.drawing=on
    if ! "$VPN" up >/dev/null 2>&1; then
      $BAR_NAME --set "$NAME" icon=󰌿 icon.color=0xFF970000 icon.padding_right=6 label="VPN failed" label.color=0xFF970000 label.drawing=on
      exit 0
    fi
  else
    $BAR_NAME --set "$NAME" icon.color=$DIM_COLOR icon.padding_right=6 label="Disconnecting…" label.color=$DIM_COLOR label.drawing=on
    "$VPN" down >/dev/null 2>&1
  fi
fi

case "$("$VPN" status)" in
  connected) $BAR_NAME --set "$NAME" icon=󰌾 icon.color=$TEXT_COLOR icon.padding_right=12 label.drawing=off ;;
  connecting) $BAR_NAME --set "$NAME" icon=󰌿 icon.color=$DIM_COLOR icon.padding_right=6 label="Connecting…" label.color=$DIM_COLOR label.drawing=on ;;
  *) $BAR_NAME --set "$NAME" icon=󰌿 icon.color=$DIM_COLOR icon.padding_right=12 label.drawing=off ;;
esac
