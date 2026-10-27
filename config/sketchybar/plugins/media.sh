#!/usr/bin/env bash

# Streams now playing changes from media-control into the media item. Started
# once per bar by sketchybarrc: media.sh BAR_NAME
export LC_ALL=en_US.UTF-8

BAR_NAME="$1"
MAX_CHARS=30

# Only one stream per bar: stop the one a previous (re)load started.
PIDFILE="${TMPDIR:-/tmp}/sketchybar-media-$BAR_NAME.pid"
[[ -f "$PIDFILE" ]] && kill "$(cat "$PIDFILE")" 2>/dev/null
echo $$ >"$PIDFILE"

media-control stream --no-diff --no-artwork --debounce=200 | while read -r line; do
  IFS=$'\t' read -r title playing < <(jq -r '[.payload.title // "", .payload.playing // false] | @tsv' <<<"$line")

  # Nothing playing (or the player quit): hide the item, and with it the pill and its gap.
  if [[ -z "$title" ]]; then
    $BAR_NAME --set media drawing=off --set media_gap drawing=off
    continue
  fi

  ((${#title} > MAX_CHARS)) && title="${title:0:MAX_CHARS-1}…"
  icon=󰏤 # paused
  [[ "$playing" == true ]] && icon=󰎆

  $BAR_NAME --set media drawing=on icon="$icon" label="$title" --set media_gap drawing=on
done &

# When this script is stopped (by the next one), take the stream down with it. The
# pipeline runs in the background because bash only handles traps between commands.
trap 'pkill -P $$' EXIT
wait
