#!/bin/bash
# Toggle the aerospace monitor profile between built-in and external

current=$(sed -n 's/^# monitor-mode: //p' "$HOME/.config/aerospace/aerospace.toml" 2>/dev/null)

if [ "$current" = "built-in" ]; then
  exec "$HOME/.config/aerospace/monitor" external
else
  exec "$HOME/.config/aerospace/monitor" built-in
fi
