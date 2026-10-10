#!/usr/bin/env bash
# Create the symlinks listed in links.conf, replacing whatever is at each destination.
# Launch agents are reloaded when their link changes.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while IFS= read -r line; do
  [[ -z "$line" || "$line" == \#* ]] && continue

  source="$DOTFILES/${line%% -> *}"
  dest="${line#* -> }"
  dest="${dest/#\~/$HOME}"

  [[ "$(readlink "$dest")" == "$source" ]] && continue

  rm -rf "$dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$source" "$dest"
  echo "Linked $dest"

  if [[ "$dest" == *.plist ]]; then
    launchctl unload "$dest" 2>/dev/null || true
    launchctl load "$dest"
  fi
done <"$DOTFILES/links.conf"
