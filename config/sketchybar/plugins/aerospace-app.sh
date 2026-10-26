#!/usr/bin/env bash

# front_app_switched passes the app name in $INFO. On other events (startup,
# workspace changes) ask AeroSpace, which reports nothing for an empty workspace.
if [[ "$SENDER" == "front_app_switched" ]]; then
  app="$INFO"
else
  app=$(aerospace list-windows --focused --json 2>/dev/null | jq -r '.[0]["app-name"] // empty')
fi

label=""

if [[ -n "$app" ]]; then
  label="/   $app"
fi

$BAR_NAME --set "$NAME" label="$label"
