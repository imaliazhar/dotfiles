#!/usr/bin/env bash

# front_app_switched passes the app name in $INFO. On other events (startup,
# workspace changes) ask AeroSpace, which reports nothing for an empty workspace.
if [[ "$SENDER" == "front_app_switched" ]]; then
  app="$INFO"
else
  app=$(aerospace list-windows --focused --json 2>/dev/null | jq -r '.[0]["app-name"] // empty')
fi

# With no app, hide the item, and with it the app pill.
if [[ -z "$app" ]]; then
  $BAR_NAME --set "$NAME" drawing=off
else
  $BAR_NAME --set "$NAME" drawing=on label="$app"
fi
