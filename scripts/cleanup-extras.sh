#!/usr/bin/env bash
# Clean up duplicate/unused apps. PDF work stays on what is already installed:
#   Okular            -> read, annotate, fill forms, sign
#   LibreOffice Draw  -> edit the actual PDF content (text/images/pages)
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your user, without sudo:  bash $0" >&2
  exit 1
fi

# Keep Okular as the default viewer; no new PDF app is installed.
xdg-mime default org.kde.okular.desktop application/pdf || true

# Kate is going away, so point plain text at VS Code (Code - OSS).
if [ -f /usr/share/applications/code-oss.desktop ]; then
  xdg-mime default code-oss.desktop text/plain || true
fi

echo "==> Removing the duplicate/unused packages you selected"
sudo pacman -Rns --noconfirm \
  kate \
  evolution \
  niri \
  ntp \
  netctl \
  xl2tpd \
  haveged \
  dmg2img \
  b43-fwcutter \
  xorg-xinit \
  xorg-xinput \
  xorg-xkill

echo
echo "==> Done."
echo "PDF app  : $(xdg-mime query default application/pdf)"
echo "text app : $(xdg-mime query default text/plain)"
