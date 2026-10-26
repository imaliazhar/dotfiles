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

$BAR_NAME --set "$NAME" label="$label"
