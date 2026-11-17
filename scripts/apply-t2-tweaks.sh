#!/usr/bin/env bash
# One-shot root fixes for the T2 MacBook:
#   - enable Bluetooth
#   - install a valid tiny-dfr config (media/activity layer default, double-Fn toggle)
#   - swap the Fn and left Ctrl keys (PC-style bottom row)
#   - hide GRUB and the kernel log
#   - reduce SDDM theme blur so the wallpaper paints immediately
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo: sudo bash $0" >&2
    exit 1
fi

STAMP=$(date +%Y%m%d-%H%M%S)

echo "==> Enabling Bluetooth"
systemctl enable --now bluetooth

echo "==> Installing tiny-dfr config"
if [ -f /etc/tiny-dfr/config.toml ] && [ ! -f /etc/tiny-dfr/config.toml.bak ]; then
    cp -a /etc/tiny-dfr/config.toml /etc/tiny-dfr/config.toml.bak
fi
install -m 0644 /home/rafid/tiny-dfr-config-fixed.toml /etc/tiny-dfr/config.toml
systemctl restart tiny-dfr

echo "==> Swapping Fn and left Ctrl (hid_apple, applies on reboot)"
if [ -f /etc/modprobe.d/hid_apple.conf ]; then
    cp -a /etc/modprobe.d/hid_apple.conf "/etc/modprobe.d/hid_apple.conf.bak-$STAMP"
fi
printf 'options hid_apple swap_fn_leftctrl=1\n' > /etc/modprobe.d/hid_apple.conf

echo "==> Configuring GRUB (no menu, no kernel text)"
cp -a /etc/default/grub "/etc/default/grub.bak-$STAMP"
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT='0'/" /etc/default/grub
sed -i "s/^GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=hidden/" /etc/default/grub
grep -q "^GRUB_CMDLINE_LINUX_DEFAULT='quiet " /etc/default/grub \
    || sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT='/GRUB_CMDLINE_LINUX_DEFAULT='quiet /" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "==> Reducing SDDM theme blur"
THEME=/usr/share/sddm/themes/plasma-chili/theme.conf
cp -a "$THEME" "$THEME.bak-$STAMP"
sed -i 's/^Blur=.*/Blur=false/; s/^RecursiveBlurLoops=.*/RecursiveBlurLoops=1/; s/^RecursiveBlurRadius=.*/RecursiveBlurRadius=8/' "$THEME"

echo
echo "==> Result"
grep -E '^GRUB_(TIMEOUT|TIMEOUT_STYLE|CMDLINE_LINUX_DEFAULT)' /etc/default/grub
printf 'bluetooth: '; systemctl is-enabled bluetooth
grep -E '^(Blur|RecursiveBlurLoops|RecursiveBlurRadius)=' "$THEME"
printf 'tiny-dfr: '; systemctl is-active tiny-dfr
printf 'Fn/left-Ctrl swap: '; cat /etc/modprobe.d/hid_apple.conf
echo
echo "Backups: /etc/default/grub.bak-$STAMP and $THEME.bak-$STAMP"
echo "Reboot to apply the boot changes."
