#!/usr/bin/env bash
# T2 Mac keyboard: Ctrl, Fn, Win, Alt on the left; Alt/Win on the right.
# Requires root. Reboot after running.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

CONF=/etc/modprobe.d/hid_apple.conf
STAMP=$(date +%Y%m%d-%H%M%S)

if [ -f "$CONF" ]; then
  cp -a "$CONF" "$CONF.bak.$STAMP"
fi

cat > "$CONF" <<'EOF'
options hid_apple swap_fn_leftctrl=1 swap_opt_cmd=1
EOF

echo "==> Wrote $CONF"
cat "$CONF"

echo "==> Rebuilding initramfs"
mkinitcpio -P

echo
echo "Reboot to apply the new hid_apple mapping."
