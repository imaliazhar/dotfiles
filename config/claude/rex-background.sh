#!/bin/sh
# PreToolUse hook for Bash: inside Rex, background commands must run in a Rex tab.

[ -n "$REX_SESSION" ] || exit 0
command -v rex >/dev/null 2>&1 || exit 0

input=$(cat)
[ "$(printf '%s' "$input" | jq -r '.tool_input.run_in_background // false')" = "true" ] || exit 0

reason='Background tasks run in a Rex tab here, not with run_in_background. Rerun it as:
  rex window new -s "$REX_SESSION" <short-name> -c "$PWD" --keep-open --focus=false --json -- sh -c '"'"'<command>'"'"'
Save .block_ids[0], then check on it with `rex wait -s "$REX_SESSION" <block> --for 30s --json`, `rex block call -s "$REX_SESSION" -b <block> process` (last_exit) and `rex capture -s "$REX_SESSION" -b <block> --trim | tail -n 50`.'

jq -n --arg reason "$reason" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $reason
  }
}'
