#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES="$REPO/packages/pacman-explicit.txt"

usage() {
  echo "Usage: $0 [--all]"
  echo "  (no args)  install packages from packages/pacman-explicit.txt"
  echo "  --all      install packages and link user dotfiles"
}

if [ ! -f "$PACKAGES" ]; then
  echo "Missing $PACKAGES" >&2
  exit 1
fi

echo "==> Installing packages (pacman)"
sudo pacman -S --needed - < "$PACKAGES"

# Some zsh tools are only dependencies on this machine, so pacman -Qqe does
# not always list them. Keep the shell setup explicit for new installs.
ZSH_TOOLS=(zsh fzf fd ripgrep bat eza starship zoxide neovim lf)
echo "==> Ensuring zsh tooling: ${ZSH_TOOLS[*]}"
sudo pacman -S --needed "${ZSH_TOOLS[@]}"

if [ -s "$REPO/packages/aur-foreign.txt" ]; then
  echo "==> Installing AUR packages"
  if command -v yay >/dev/null 2>&1; then
    yay -S --needed - < "$REPO/packages/aur-foreign.txt"
  else
    echo "yay not found; install yay then run:" >&2
    echo "  yay -S --needed - < $REPO/packages/aur-foreign.txt" >&2
  fi
fi

if [ "${1:-}" = "--all" ]; then
  "$REPO/install.sh"
  echo
  echo "System files still need: sudo $REPO/install.sh --system"
fi
