#!/usr/bin/env bash

# aerospace_workspace_change passes FOCUSED_WORKSPACE; other events (startup,
# front_app_switched) don't, so ask AeroSpace instead.
workspace="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

case $workspace in
0) label="Code" ;;
1) label="Web" ;;
2) label="App" ;;
3) label="Slack" ;;
9) label="Chat" ;;
10) label="AI" ;;
*) label="Desktop $workspace" ;;
esac

source "$CONFIG_DIR/theme.sh"

# Fills the workspaces pill (the ws.* items in sketchybarrc): the focused
# workspace bright and by name, the other occupied ones as dim numbers.
occupied=" $(aerospace list-workspaces --monitor all --empty no 2>/dev/null | tr '\n' ' ') "
args=()
for ws in {0..10}; do
  if [[ "$ws" == "$workspace" ]]; then
    args+=(--set ws.$ws drawing=on icon="$label" icon.color=$TEXT_COLOR)
  elif [[ "$occupied" == *" $ws "* ]]; then
    args+=(--set ws.$ws drawing=on icon=$ws icon.color=$DIM_COLOR)
  else
    args+=(--set ws.$ws drawing=off)
  fi
done

$BAR_NAME "${args[@]}"
