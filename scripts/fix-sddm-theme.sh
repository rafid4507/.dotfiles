#!/usr/bin/env bash
# Point SDDM at a Plasma 6 / Qt6 greeter theme.
# The current setting (plasma-chili) is a Plasma 5 theme: its metadata has no
# QtVersion=6, so SDDM launches the Qt5 greeter, which no longer has the Qt5
# Plasma QML modules -> "module org.kde.plasma.extras is not installed".
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with: sudo bash $0" >&2
  exit 1
fi

conf=/etc/sddm.conf.d/kde_settings.conf
stamp=$(date +%Y%m%d-%H%M%S)

if [ -f "$conf" ]; then
  cp -a "$conf" "$conf.bak.$stamp"
  python3 - "$conf" <<'PY'
import re, sys

path = sys.argv[1]
lines = open(path).read().splitlines()
out, section, seen = [], None, False

for line in lines:
    stripped = line.strip()
    if stripped.startswith("[") and stripped.endswith("]"):
        section = stripped[1:-1].strip()
        out.append(line)
        continue
    if section == "Theme" and re.match(r"Current\s*=", stripped):
        out.append("Current=eos-breeze")
        seen = True
        continue
    out.append(line)

if not seen:
    out += ["", "[Theme]", "Current=eos-breeze"]

open(path, "w").write("\n".join(out) + "\n")
PY
fi

if [ -f /etc/sddm.conf.d/10-endeavouros.conf ]; then
  sed -i 's/^Current=.*/Current=eos-breeze/' /etc/sddm.conf.d/10-endeavouros.conf
fi

echo "Configured SDDM themes:"
grep -H '^Current=' /etc/sddm.conf.d/*.conf
echo
echo "eos-breeze is a Qt6 theme:"
grep -H '^QtVersion=' /usr/share/sddm/themes/eos-breeze/metadata.desktop
echo
echo "Done. Log out (or reboot) to see the new login screen."
