#!/usr/bin/env bash
# Apply the Touch Bar layout: F1-F12 + Del, no date/time, no battery,
# and Del in the media layer next to volume up/down.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/system/etc/tiny-dfr/config.toml"
DEST=/etc/tiny-dfr/config.toml
STAMP=$(date +%Y%m%d-%H%M%S)

if [ ! -f "$SRC" ]; then
  echo "Missing $SRC" >&2
  exit 1
fi

if [ -f "$DEST" ]; then
  cp -a "$DEST" "$DEST.bak.$STAMP"
fi

install -Dm644 "$SRC" "$DEST"

echo "==> Installed Touch Bar config:"
grep -nE 'Text = "Del"|Time =|Battery =|volume_(down|up)' "$DEST"

echo "==> Restarting tiny-dfr"
systemctl restart tiny-dfr
systemctl --no-pager --lines=5 status tiny-dfr 2>/dev/null || true

echo
echo "Touch Bar updated."
