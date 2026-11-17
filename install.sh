#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
SYS_BACKUP="/etc/dotfiles-backup/$STAMP"
USER_BACKUP="$HOME/.dotfiles-backup/$STAMP"

usage() {
  echo "Usage: $0 [--system]"
  echo "  (no args)  link user dotfiles from home/ into \$HOME"
  echo "  --system   copy system/ files into /etc (needs sudo)"
}

link_user() {
  if [ ! -d "$REPO/home" ]; then
    echo "No home/ directory in $REPO" >&2
    exit 1
  fi

  echo "==> Linking user dotfiles (backup: $USER_BACKUP)"
  while IFS= read -r -d '' src; do
    rel="${src#"$REPO/home/"}"
    dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"

    if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
      continue
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
      mkdir -p "$USER_BACKUP/$(dirname "$rel")"
      mv "$dest" "$USER_BACKUP/$rel"
    fi

    ln -s "$src" "$dest"
    echo "  linked ~/$rel"
  done < <(find "$REPO/home" -type f -print0)
}

install_system() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo: sudo $0 --system" >&2
    exit 1
  fi

  echo "==> Installing system files (backup: $SYS_BACKUP)"
  while IFS= read -r -d '' src; do
    rel="${src#"$REPO/system/"}"
    dest="/$rel"
    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ]; then
      mkdir -p "$SYS_BACKUP/$(dirname "$rel")"
      cp -a "$dest" "$SYS_BACKUP/$rel"
    fi

    install -Dm644 "$src" "$dest"
    echo "  installed $dest"
  done < <(find "$REPO/system" -type f -print0)

  echo "==> Regenerating GRUB config"
  if command -v grub-mkconfig >/dev/null 2>&1; then
    grub-mkconfig -o /boot/grub/grub.cfg
  fi

  echo "==> Rebuilding initramfs (hid_apple options)"
  if command -v mkinitcpio >/dev/null 2>&1; then
    mkinitcpio -P
  fi

  if [ -x "$REPO/scripts/setup-login-theme.sh" ]; then
    echo "==> Setting up SDDM Breeze theme + blurred wallpaper"
    "$REPO/scripts/setup-login-theme.sh"
  fi
}

case "${1:-}" in
  --system)
    install_system
    ;;
  ""|--user)
    link_user
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
