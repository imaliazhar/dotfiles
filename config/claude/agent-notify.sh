#!/bin/sh
# Claude Code hook (Stop / Notification): shows a Hammerspoon alert
# "Agent <session name> is <status>" and plays a sound for Notification events.
# Falls back to the cwd's basename when the session has no custom title.

input=$(cat)

event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty')
type=$(printf '%s' "$input" | jq -r '.notification_type // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

case "$event:$type" in
Stop:*) status="done" ;;
Notification:permission_prompt) status="waiting for permission" ;;
Notification:idle_prompt) exit 0 ;;
Notification:*) status="waiting for input" ;;
*) status="$event" ;;
esac

name=""
if [ -f "$transcript" ]; then
	name=$(grep '"type":"custom-title"' "$transcript" | tail -n 1 | jq -r '.customTitle // empty')
fi
[ -n "$name" ] || name=$(basename "${cwd:-$PWD}")

[ "$event" = "Stop" ] || afplay /System/Library/Sounds/Glass.aiff &

/opt/homebrew/bin/hs -q -c 'agent_alert(_cli.args[2], _cli.args[3])' -- "$name" "$status" >/dev/null 2>&1 &
exit 0
