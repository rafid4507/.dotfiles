#!/usr/bin/env bash
# Stable Qt6 SDDM theme + blurred login wallpaper.
# Requires root. Reboot (or restart SDDM) after running.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

STAMP=$(date +%Y%m%d-%H%M%S)
SRC=/usr/share/wallpapers/EndeavourOS/contents/vadim.jpg
[ -f "$SRC" ] || SRC=/usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png
[ -f "$SRC" ] || SRC=/usr/share/wallpapers/Next/contents/images/5120x2880.png

# Prefer the wallpaper from the invoking user's Plasma config, if available.
if [ -z "${1:-}" ] && [ -n "${SUDO_USER:-}" ]; then
  cfg="/home/$SUDO_USER/.config/plasma-org.kde.plasma.desktop-appletsrc"
  if [ -f "$cfg" ]; then
    candidate=$(sed -n 's|^Image=file://||p' "$cfg" | tail -n1)
    if [ -n "$candidate" ] && [ -f "$candidate" ]; then
      SRC="$candidate"
    fi
  fi
fi

# Optional first argument overrides the wallpaper.
if [ -n "${1:-}" ]; then
  SRC="$1"
fi

DESTDIR=/usr/local/share/sddm/wallpapers
DEST=$DESTDIR/rafid-blur.jpg
mkdir -p "$DESTDIR"

echo "==> Building blurred login wallpaper from $SRC"
if command -v ffmpeg >/dev/null 2>&1; then
  ffmpeg -y -loglevel error -i "$SRC" -vf "gblur=sigma=40" -q:v 2 "$DEST"
elif command -v magick >/dev/null 2>&1; then
  magick "$SRC" -blur 0x40 "$DEST"
elif command -v convert >/dev/null 2>&1; then
  convert "$SRC" -blur 0x40 "$DEST"
else
  echo "No ffmpeg/ImageMagick; copying wallpaper without blur." >&2
  cp "$SRC" "$DEST"
fi
chmod 0644 "$DEST"

THEME=/usr/share/sddm/themes/breeze/theme.conf
if [ ! -f "$THEME" ]; then
  echo "Missing $THEME (install the breeze SDDM theme first)" >&2
  exit 1
fi
cp -a "$THEME" "$THEME.bak.$STAMP"

python3 - "$THEME" "$DEST" <<'PY'
import sys

path, background = sys.argv[1], sys.argv[2]
lines = open(path).read().splitlines()
out, section, seen = [], None, set()

for line in lines:
    stripped = line.strip()
    if stripped.startswith("[") and stripped.endswith("]"):
        section = stripped[1:-1].strip()
        out.append(line)
        continue
    if section == "General":
        key = stripped.split("=", 1)[0].strip() if "=" in stripped else ""
        if key in {"background", "type", "color"}:
            if key == "background":
                out.append(f"background={background}")
            elif key == "type":
                out.append("type=image")
            else:
                out.append(line)
            seen.add(key)
            continue
    out.append(line)

if "background" not in seen:
    out.append(f"background={background}")
if "type" not in seen:
    out.append("type=image")

open(path, "w").write("\n".join(out) + "\n")
PY

# Use the stock Qt6 Breeze theme to avoid missing Plasma QML modules.
for conf in /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/10-endeavouros.conf; do
  if [ -f "$conf" ]; then
    cp -a "$conf" "$conf.bak.$STAMP"
    sed -i 's/^Current=.*/Current=breeze/' "$conf"
  fi
done

# Keep the KDE lock screen (Meta+L) on the same wallpaper as the desktop.
if [ -n "${SUDO_USER:-}" ]; then
  user_home=$(getent passwd "$SUDO_USER" | cut -d: -f6)
  if [ -n "$user_home" ] && [ -d "$user_home/.config" ]; then
    lockconf="$user_home/.config/kscreenlockerrc"
    if [ -f "$lockconf" ]; then
      cp -a "$lockconf" "$lockconf.bak.$STAMP"
    fi
    cat > "$lockconf" <<EOF
[Greeter]
WallpaperPlugin=org.kde.image

[Greeter][Wallpaper][org.kde.image][General]
Image=file://$SRC
FillMode=2
EOF
    chown "$SUDO_USER:$SUDO_USER" "$lockconf"
    echo "==> Lock screen wallpaper: $SRC"
  fi
fi

echo
echo "==> Active SDDM themes:"
grep -H '^Current=' /etc/sddm.conf.d/*.conf || true
echo "==> Breeze background:"
grep -E '^(background|type)=' "$THEME"
echo
echo "Reboot (or restart SDDM) to see the new login screen."
