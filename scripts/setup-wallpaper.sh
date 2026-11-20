#!/usr/bin/env bash
# Install the wallpapers bundled in this repo and select one for Plasma.
# Runs as a normal user; no root needed.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="$REPO/wallpapers"
DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/wallpapers/rafid-dotfiles"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DEFAULT_WALLPAPER="vadim.jpg"

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  -w, --wallpaper NAME|PATH  use a bundled wallpaper by name, or any image path
  -r, --random               pick a random bundled wallpaper
      --no-apply             only update config files, not the live session
  -h, --help                 show this help

Default: $DEFAULT_WALLPAPER
EOF
}

requested=""
random=0
apply=1

while [ "$#" -gt 0 ]; do
  case "$1" in
    -w|--wallpaper)
      [ "$#" -ge 2 ] || { echo "Missing wallpaper name" >&2; exit 1; }
      requested="$2"; shift 2
      ;;
    -r|--random)
      random=1; shift
      ;;
    --no-apply)
      apply=0; shift
      ;;
    -h|--help)
      usage; exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ ! -d "$SRC_DIR" ]; then
  echo "Missing wallpaper directory: $SRC_DIR" >&2
  exit 1
fi

echo "==> Installing wallpapers into $DEST_DIR"
mkdir -p "$DEST_DIR"
installed=0
for src in "$SRC_DIR"/*; do
  [ -f "$src" ] || continue
  case "${src##*/}" in
    *.jpg|*.jpeg|*.png|*.webp|*.avif) ;;
    *) continue ;;
  esac
  name="${src##*/}"
  if [ ! -f "$DEST_DIR/$name" ] || ! cmp -s "$src" "$DEST_DIR/$name"; then
    install -m 0644 "$src" "$DEST_DIR/$name"
    echo "  installed $name"
    installed=$((installed + 1))
  fi
done
[ "$installed" -eq 0 ] && echo "  already up to date"

# ---------- pick the wallpaper ----------
if [ -n "$requested" ]; then
  if [ -f "$requested" ]; then
    chosen="$requested"
  elif [ -f "$SRC_DIR/$requested" ]; then
    chosen="$SRC_DIR/$requested"
  else
    echo "No such wallpaper: $requested" >&2
    echo "Available: $(cd "$SRC_DIR" && printf '%s ' * 2>/dev/null)" >&2
    exit 1
  fi
elif [ "$random" -eq 1 ]; then
  mapfile -t choices < <(find "$DEST_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
       -o -iname '*.webp' -o -iname '*.avif' \) | sort)
  if [ "${#choices[@]}" -eq 0 ]; then
    echo "No wallpapers found in $DEST_DIR" >&2
    exit 1
  fi
  chosen="${choices[RANDOM % ${#choices[@]}]}"
else
  chosen="$DEST_DIR/$DEFAULT_WALLPAPER"
fi

# Keep every config pointing at the stable, repo-managed location.
if [ "$(dirname "$chosen")" != "$DEST_DIR" ]; then
  target="$DEST_DIR/$(basename "$chosen")"
  if [ ! -f "$target" ] || ! cmp -s "$chosen" "$target"; then
    install -m 0644 "$chosen" "$target"
  fi
  chosen="$target"
fi

if [ ! -f "$chosen" ]; then
  echo "Wallpaper not found: $chosen" >&2
  exit 1
fi

url="file://$chosen"
echo "==> Selected wallpaper: $chosen"

# ---------- Plasma desktop (image + slideshow containments) ----------
cfg="$CONFIG_DIR/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$cfg" ]; then
  python3 - "$cfg" "$url" "$DEST_DIR" <<'PY'
import re
import sys

path, url, wall_dir = sys.argv[1:4]
lines = open(path, encoding="utf-8").read().splitlines()
out = []
header, body, is_wallpaper = None, [], False


def flush(h, b, wallpaper):
    if h is None:
        return
    if wallpaper:
        slideshow = "org.kde.slideshow" in h
        out.append(h)
        has_image = has_paths = False
        for line in b:
            stripped = line.strip()
            if stripped.startswith("Image="):
                out.append("Image=" + url)
                has_image = True
            elif slideshow and stripped.startswith("SlidePaths="):
                out.append("SlidePaths=" + wall_dir)
                has_paths = True
            else:
                out.append(line)
        if not has_image:
            out.append("Image=" + url)
        if slideshow and not has_paths:
            out.append("SlidePaths=" + wall_dir)
    else:
        out.append(h)
        out.extend(b)


for line in lines:
    if re.match(r"^\[.+\]$", line):
        flush(header, body, is_wallpaper)
        header, body = line, []
        is_wallpaper = bool(re.match(
            r"^\[Containments\]\[\d+\]\[Wallpaper\]\[org\.kde\.(image|slideshow)\]\[General\]$",
            line,
        ))
    else:
        body.append(line)

flush(header, body, is_wallpaper)
open(path, "w", encoding="utf-8").write("\n".join(out) + "\n")
PY
  echo "==> Desktop config updated"
else
  echo "==> No Plasma desktop config yet; the repo default will be used at login"
fi

# ---------- lock screen (Meta+L) ----------
lock="$CONFIG_DIR/kscreenlockerrc"
if [ -d "$(dirname "$lock")" ]; then
  cat > "$lock" <<EOF
[Greeter]
WallpaperPlugin=org.kde.image

[Greeter][Wallpaper][org.kde.image][General]
Image=$url
FillMode=2
EOF
  echo "==> Lock screen wallpaper updated"
fi

# ---------- live session (optional) ----------
if [ "$apply" -eq 1 ] && [ -n "${XDG_CURRENT_DESKTOP:-}" ] \
  && command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
  if [ -f "$cfg" ] && grep -q '^wallpaperplugin=org.kde.slideshow' "$cfg"; then
    echo "==> Slideshow is active; config changes take effect on next Plasma restart"
  else
    plasma-apply-wallpaperimage "$chosen" >/dev/null \
      && echo "==> Applied wallpaper to the live Plasma session"
  fi
fi

echo
echo "To refresh the blurred SDDM login background with this wallpaper:"
echo "  sudo bash $REPO/scripts/setup-login-theme.sh"
