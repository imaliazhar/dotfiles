#!/bin/sh
# Toggles a popup showing ghpr, which runs in a background session so it keeps its state between toggles
# Usage: tmux-ghpr-float.sh <client> <session> <pane path>

client=$1
current_session=$2
path=$3
session=_ghpr

if [ "$current_session" = "$session" ]; then
    tmux detach-client -t "$client"
    exit 0
fi

if ! tmux has-session -t "=$session" 2>/dev/null; then
    tmux new-session -d -s "$session" -c "$path" -e GHPR_POPUP=1 "ghpr; tmux detach-client -s '=$session'"
    tmux set-option -t "$session" status off
fi

tmux display-popup -c "$client" -E -w 80% -h 80% "TMUX= tmux attach-session -t '=$session'"
