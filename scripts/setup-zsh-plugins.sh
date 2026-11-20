#!/usr/bin/env bash
# Pre-install the zsh plugins listed in plugins.zsh (idempotent).
# The shell config also installs any missing plugin on first use.
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PLUGINS_FILE="${ZDOTDIR:-$CONFIG_DIR/zsh}/plugins.zsh"
ZPLUGINDIR="${ZPLUGINDIR:-${ZDOTDIR:-$CONFIG_DIR/zsh}/plugins}"

if [ ! -f "$PLUGINS_FILE" ]; then
  echo "Missing $PLUGINS_FILE" >&2
  exit 1
fi

mkdir -p "$ZPLUGINDIR"

while read -r owner repo _; do
  [ -n "${owner:-}" ] && [ -n "${repo:-}" ] || continue
  dir="$ZPLUGINDIR/$repo"
  if [ -d "$dir/.git" ]; then
    echo "==> $repo already installed"
  elif [ -e "$dir" ]; then
    echo "==> Skipping $repo: $dir exists but is not a git repo" >&2
  else
    echo "==> Installing $repo"
    git clone --depth 1 "https://github.com/$owner/$repo.git" "$dir"
  fi
done < <(awk '/^_zplugin_load/ {print $2, $3}' "$PLUGINS_FILE")

echo "==> Update all plugins later with: zplugin-update"
