#!/usr/bin/env bash
# ============================================================================
#  install.sh — deploy these dotfiles with GNU Stow
#
#  What it does:
#    * ensures `stow` is present
#    * symlinks each package into $HOME
#
#  Usage:
#    cd ~/.dotfiles && ./install.sh
#
#  Undo (remove all symlinks) for one package:
#    cd ~/.dotfiles && stow -D niri
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v stow >/dev/null; then
    echo "GNU Stow is not installed. On Arch:  sudo pacman -S stow" >&2
    exit 1
fi

# Every top-level directory is a "stow package".
packages=(niri fish tmux kitty waybar fuzzel mako swaylock starship yazi btop gtk wallpapers applications mimeapps git)

echo "Stowing into: $HOME"
for pkg in "${packages[@]}"; do
    if [ -d "$pkg" ]; then
        echo "  -> $pkg"
        # --no-folding: create real directories and symlink individual files.
        # This stops tools (fish_variables, btop.conf, ...) from writing their
        # runtime state into the repo through a folded directory symlink.
        stow --no-folding --verbose=1 --target "$HOME" --restow "$pkg"
    fi
done

echo
echo "Done. Log out and back in (or start a new shell) to pick up changes."
echo "Start niri from a TTY with:  niri-session"
