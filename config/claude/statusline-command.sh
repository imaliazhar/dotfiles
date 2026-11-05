#!/bin/sh
input=$(cat)

eval "$(printf '%s' "$input" | jq -r '
  @sh "ctx=\(.context_window.used_percentage // "")",
  @sh "tokens=\((.context_window.current_usage // {}) | [.input_tokens, .cache_creation_input_tokens, .cache_read_input_tokens, .output_tokens] | add // "")",
  @sh "cost=\(.cost.total_cost_usd // "")",
  @sh "five=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "five_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "week=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "week_reset=\(.rate_limits.seven_day.resets_at // "")"
')"

email=$(jq -r '.oauthAccount.emailAddress // empty' ~/.claude.json 2>/dev/null)
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

rgb() { printf '\033[38;2;%d;%d;%dm' "0x${1%????}" "0x$(printf %s "$1" | cut -c3-4)" "0x${1#????}"; }
reset='\033[0m'
muted=$(rgb 6e6a86)
subtle=$(rgb 908caa)
gold=$(rgb f6c177)
love=$(rgb eb6f92)

value_color() {
  if [ "$1" -ge 90 ]; then printf '%s' "$love"
  elif [ "$1" -ge 70 ]; then printf '%s' "$gold"
  else printf '%s' "${2:-$subtle}"
  fi
}

reset_at() {
  if [ "$(date -r "$1" +%F)" = "$(date +%F)" ]; then date -r "$1" +%H:%M
  else date -r "$1" '+%a %H:%M'
  fi
}

item() { printf '%s%s' "$1" "$2"; }

pct() {
  p=$(printf '%.0f' "$1")
  out=$(item "$(value_color "$p" "${2:+$muted}")" "$p%")
  [ -n "$2" ] && out="$out ${muted}• $(reset_at "$2")"
  printf '%s' "$out"
}

abbr() {
  if [ "$1" -ge 1000000 ]; then printf '%s' "$(echo "$1" | awk '{printf "%.1fM", $1/1000000}')"
  elif [ "$1" -ge 1000 ]; then printf '%dk' $(( ($1 + 500) / 1000 ))
  else printf '%d' "$1"
  fi
}

join() {
  out=""
  for part in "$@"; do
    [ -z "$part" ] && continue
    [ -n "$out" ] && out="$out$sep"
    out="$out$part$reset"
  done
  printf '%s' "$out"
}

[ -n "$ctx" ] && ctx_part="$(pct "$ctx")$( [ -n "$tokens" ] && printf ' %s%s' "$muted" "$(abbr "$tokens")")"
[ -n "$five" ] && five_part=$(pct "$five" "$five_reset")
[ -n "$week" ] && week_part=$(pct "$week" "$week_reset")
if [ -n "$cost" ] && [ "$(printf '%.2f' "$cost")" != "0.00" ]; then
  cost_part=$(item "$muted" "\$$(printf '%.2f' "$cost")")
fi

case "${email%@*}" in
  aliazharthegreat) account="Alt" ;;
  aliazhar.khan) account="Work" ;;
  aliazhkh) account="Personal" ;;
  *) account="${email%@*}" ;;
esac
[ -n "$email" ] && account_part=$(item "$subtle" "${muted} ${subtle}${account}")
[ -n "$branch" ] && branch_part=$(item "$subtle" "${muted} ${subtle}${branch}")

sep='   '
limits=$(join "$five_part" "$week_part")
sep="   ${muted}│${reset}   "
right=$(join "$account_part" "$branch_part")
left=$(join "$ctx_part" "$limits" "$cost_part")

visible() { printf '%b' "$1" | sed 's/\x1b\[[0-9;]*m//g' | LC_ALL=en_US.UTF-8 wc -m | tr -d ' '; }
gap=$(( ${COLUMNS:-80} - 5 - $(visible "$left") - $(visible "$right") ))
[ "$gap" -lt 3 ] && gap=3

printf '%b%*s%b' "$left" "$gap" '' "$right"
