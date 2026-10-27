#!/bin/sh

# Shows download/upload speed from stats_provider's NETWORK_RX_<iface> and
# NETWORK_TX_<iface> (KiB/s), whichever interface the rc asked for.

case "$NAME" in
net_down) PREFIX=NETWORK_RX_ ;;
net_up) PREFIX=NETWORK_TX_ ;;
*) exit 0 ;;
esac

VALUE="$(env | sed -n "s/^${PREFIX}[^=]*=//p" | head -n 1 | tr -cd '0-9.')"

# Nothing to show until stats_provider sends its first event.
[ -z "$VALUE" ] && exit 0

# At most 3 digits so the fixed-width label never overflows: 999K, 9.8M, 97M, 1.2G
LABEL="$(echo "$VALUE" | awk '{
  m = $1 / 1024; g = m / 1024
  if ($1 < 1000) printf "%dK", $1
  else if (m < 10) printf "%.1fM", m
  else if (m < 1000) printf "%dM", m
  else printf "%.1fG", g
}')"

$BAR_NAME --set "$NAME" label="$LABEL"
