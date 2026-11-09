#!/bin/zsh
# Pick a session with fzf: open Rex sessions first (marked •), then the fixed
# folders and ~/Projects/*. Picking a folder that has no session creates one there.
# Run by the "Open Project" Rex action.
# zsh rather than sh so fzf picks up FZF_DEFAULT_OPTS from .zshenv.
set -eu

rex="${REX_BIN_DIR:+$REX_BIN_DIR/}rex"
green=$'\e[32m'
nc=$'\e[0m'

typeset -A dirs open_ids
names=()

add() {
    (( ${+dirs[$1]} )) && return
    names+=("$1")
    dirs[$1]="$2"
}

"$rex" ls --json | jq -r '.sessions[] | select(.label | startswith("_") | not) | [.label, .session_id] | @tsv' |
    while IFS=$'\t' read -r label id; do
        open_ids[$label]="$id"
        add "$label" ""
    done

add home "$HOME"
add dotfiles "$HOME/Dotfiles"
add homelab "$HOME/Homelab"
add obsidian "$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Gringotts"

for dir in "$HOME"/Projects/*(N/); do
    add "${${dir:t}//./_}" "$dir"
done

for name in "${(@k)open_ids}"; do
    [ -z "${dirs[$name]}" ] || continue
    for dir in "$HOME"/Projects/*(N/); do
        [ "${${dir:t}//./_}" = "$name" ] && dirs[$name]="$dir"
    done
done

# The hidden second field (tab-delimited) holds the folder so ctrl-y can copy it.
selected=$(
    for name in "${names[@]}"; do
        if (( ${+open_ids[$name]} )); then
            display="$green• $name$nc"
        else
            display="  $name"
        fi
        printf '%s\t%s\n' "$display" "${dirs[$name]/#$HOME/~}"
    done | fzf --ansi --no-info --no-scrollbar \
        --delimiter $'\t' --with-nth 1 \
        --bind 'ctrl-y:execute-silent(printf %s {2} | pbcopy)+abort'
) || exit 0

name="${selected%%$'\t'*}"
name="${${name#• }#  }"
session="${open_ids[$name]:-}"

if [ -z "$session" ]; then
    session=$("$rex" new "$name" -c "${dirs[$name]}" --json | jq -r '.session_id')
fi

if [ -n "${REX_SESSION:-}" ] && [ "$session" != "$REX_SESSION" ]; then
    "$rex" do session_remember session_id="$REX_SESSION"
fi
"$rex" do session.select session_id="$session"
