#!/bin/bash
# Switch aerospace workspace-to-monitor assignment between the @monitor-mode blocks in aerospace.toml.
# Usage: aerospace-monitor-toggle.sh [built-in|external|gaming]
# Without an argument, toggles built-in -> external, anything else -> built-in.

CONFIG="$HOME/.config/aerospace/aerospace.toml"

current=$(awk '
    /^# @monitor-mode:/ { block = substr($0, 17); next }
    /^$/ { block = "" }
    block != "" && !/^#/ { print block; exit }
' "$CONFIG")

mode="$1"
if [ -z "$mode" ]; then
    if [ "$current" = "built-in" ]; then mode="external"; else mode="built-in"; fi
fi

if ! grep -q "^# @monitor-mode:$mode$" "$CONFIG"; then
    echo "Unknown mode: $mode" >&2
    exit 1
fi

updated=$(awk -v mode="$mode" '
    /^# @monitor-mode:/ { block = substr($0, 17); print; next }
    /^$/ { block = "" }
    block != "" { sub(/^# /, ""); if (block != mode) $0 = "# " $0 }
    { print }
' "$CONFIG")
printf '%s\n' "$updated" > "$CONFIG"

echo "Switched to $mode monitor mode"

aerospace reload-config
