# rafid's .dotfiles

Portable KDE Plasma (Wayland) + EndeavourOS/T2-Mac setup.

## What is tracked

- `home/` – user configs (Plasma panels, themes, **keyboard shortcuts**, KWin, KDE apps, shell, GTK)
- `system/` – system files that need root (SDDM, keyboard/hid_apple, GRUB, tiny-dfr)
- `packages/` – explicit pacman packages + AUR foreign packages
- `scripts/` – helper scripts kept with the setup

Keyboard shortcuts are in:
- `home/.config/kglobalshortcutsrc`
- `home/.config/kwinrc`

Plasma panel/wallpaper layout is in:
- `home/.config/plasma-org.kde.plasma.desktop-appletsrc`

The **lock screen** (Meta+L) wallpaper is separate from SDDM and is in:
- `home/.config/kscreenlockerrc`

Keyboard layout is German (DE) only:
- `home/.config/kxkbrc`
- `system/etc/X11/xorg.conf.d/00-keyboard.conf`
- `system/etc/vconsole.conf`

## Install user configs on a new machine

```bash
git clone https://github.com/rafid4507/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

`install.sh` backs up any existing files under `~/.dotfiles-backup/<timestamp>/` and symlinks the tracked files into `$HOME`.

## Install system configs (root)

```bash
cd ~/.dotfiles
sudo ./install.sh --system
```

It backs up the old files to `/etc/dotfiles-backup/<timestamp>/`, copies `system/etc/*` into place, rebuilds the initramfs (for `hid_apple`), and sets up the SDDM Breeze theme with a blurred login wallpaper.

`/etc/default/grub` is skipped by default because it contains a machine-specific `resume=UUID`. Apply it explicitly on the same machine with:

```bash
sudo ./install.sh --system --grub
```

You can also run just the system fixes:

```bash
sudo bash ~/.dotfiles/scripts/apply-system.sh
sudo bash ~/.dotfiles/scripts/fix-keyboard.sh     # keyboard only
sudo bash ~/.dotfiles/scripts/setup-login-theme.sh # login theme only
```

## Keyboard shortcuts

The full Plasma/KWin shortcut map is stored in:

- `home/.config/kglobalshortcutsrc`
- `home/.config/kwinrc`

Notable bindings from that map:

| Shortcut | Action |
| --- | --- |
| `Meta+W` | Overview |
| `Meta+G` | Grid view |
| `Meta+C` | Cube |
| `Meta+Tab` / `Alt+Tab` | Window switcher |
| `Meta+1..5` | Switch desktop 1–5 |
| `Meta+Ctrl+Left/Right` | Previous/next desktop |
| `Meta+Alt+Arrow` | Move focus between windows |
| `Meta+Left/Right/Up/Down` | Quick tile |
| `Meta+PgUp` / `Meta+PgDown` | Maximize / minimize |
| `Meta+L` | Lock session |
| `Ctrl+Alt+Del` | Logout screen |
| `Meta+Ctrl+Esc` | Kill window |
| `Meta+Alt+K` / `Meta+Alt+L` | Next / last keyboard layout |

## Save current changes

If you change Plasma/KDE settings on the machine, pull the current files back
into the repo:

```bash
cd ~/.dotfiles
./sync.sh
git diff
git add -A
git commit -m "Update dotfiles"
git push
```

`sync.sh` copies the live files into `home/` and `system/`, and refreshes the
package lists. It skips files that are already symlinked into the repo.

## Push updates

```bash
cd ~/.dotfiles
git add -A
git commit -m "Update dotfiles"
git push
```

The remote is `https://github.com/rafid4507/.dotfiles.git`. If you need to replace the old history completely:

```bash
git push --force -u origin main
```

## Packages

```bash
cd ~/.dotfiles
./bootstrap.sh          # install packages only
./bootstrap.sh --all    # packages + user dotfiles
```

Or manually:

```bash
sudo pacman -S --needed - < packages/pacman-explicit.txt
```

## Fixes kept here

- `scripts/fix-keyboard.sh` – Fn/left-Ctrl swap + Alt/Win (Option/Command) swap for T2 Mac, rebuild initramfs.
- `scripts/setup-login-theme.sh` – stable Qt6 Breeze SDDM theme + blurred login wallpaper. It uses the current Plasma wallpaper by default; pass an image path to override:
  `sudo bash scripts/setup-login-theme.sh /path/to/wallpaper.jpg`

## Notes

- This repo replaces the previous Ansible setup for dotfiles/config. Ansible is no longer required for these files.
- `system/etc/default/grub` is machine/kernel specific (`linux-t2`); review it before applying on different hardware.
- Package list is a snapshot of the current machine. On another Arch/EndeavourOS install, some names may have moved between repos.
