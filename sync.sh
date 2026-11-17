#!/usr/bin/env bash
# Copy the current machine's configs into this repo.
# Review, commit and push afterwards.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

HOME_FILES=(
  .bashrc .bash_profile .gitconfig .gtkrc-2.0
  .config/kxkbrc .config/kcminputrc .config/kdeglobals
  .config/kglobalshortcutsrc .config/kwinrc .config/kwinoutputconfig.json
  .config/ksplashrc .config/ksmserverrc .config/konsolerc
  .config/kscreenlockerrc
  .config/dolphinrc .config/katerc .config/mimeapps.list
  .config/plasma-localerc .config/plasmanotifyrc .config/plasmarc
  .config/plasmashellrc .config/plasma-org.kde.plasma.desktop-appletsrc
  .config/powermanagementprofilesrc .config/systemmonitorrc
  .config/ktimezonedrc .config/kaccessrc .config/kactivitymanagerdrc
  .config/bluedevilglobalrc .config/kded5rc .config/kded6rc
  .config/EOS-greeter.conf .config/welcome.conf
  .config/user-dirs.dirs .config/user-dirs.locale
  .config/gtk-3.0/settings.ini .config/gtk-4.0/settings.ini
  .config/fontconfig/fonts.conf
)

SYS_FILES=(
  /etc/modprobe.d/hid_apple.conf
  /etc/X11/xorg.conf.d/00-keyboard.conf
  /etc/vconsole.conf
  /etc/sddm.conf.d/kde_settings.conf
  /etc/sddm.conf.d/10-endeavouros.conf
  /etc/default/grub
  /etc/tiny-dfr/config.toml
)

same_file() {
  [ -e "$1" ] && [ -e "$2" ] && [ "$(readlink -f "$1")" = "$(readlink -f "$2")" ]
}

for rel in "${HOME_FILES[@]}"; do
  src="$HOME/$rel"
  dst="$REPO/home/$rel"
  [ -e "$src" ] || continue
  if same_file "$src" "$dst"; then
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  echo "updated home/$rel"
done

for src in "${SYS_FILES[@]}"; do
  [ -e "$src" ] || continue
  rel="${src#/}"
  dst="$REPO/system/$rel"
  if same_file "$src" "$dst"; then
    continue
  fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
  echo "updated system/$rel"
done

pacman -Qqe > "$REPO/packages/pacman-explicit.txt"
pacman -Qqm > "$REPO/packages/aur-foreign.txt" || true

echo
echo "Done. Review the diff, then:"
echo "  cd $REPO && git add -A && git commit -m 'Update dotfiles' && git push"
