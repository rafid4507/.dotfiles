# rafid's .dotfiles

Portable KDE Plasma (Wayland) + EndeavourOS/T2-Mac setup.

## What is tracked

- `home/` – user configs (Plasma panels, themes, **keyboard shortcuts**, KWin, KDE apps, shell, GTK, **zsh**)
- `system/` – system files that need root (SDDM, keyboard/hid_apple, GRUB, tiny-dfr)
- `packages/` – explicit pacman packages + AUR foreign packages
- `scripts/` – helper scripts kept with the setup
- `wallpapers/` – bundled wallpapers so you don't have to carry them between machines

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

## Zsh

The interactive zsh config lives in `home/.config/zsh/` and is linked into
`~/.config/zsh/`. `home/.zshenv` is a tiny entry point that sets `ZDOTDIR`.

Modular files:

| File | Purpose |
| --- | --- |
| `.zshrc` | history, completion, zoxide/fzf setup, loads the modules below |
| `aliases.zsh` | eza/bat/ripgrep/nvim/git aliases |
| `bindings.zsh` | vi-mode, autosuggestion and fzf keybindings |
| `fzf.zsh` | fzf options and the Ctrl+F file picker |
| `plugins.zsh` | loads plugins and installs any that are missing |
| `prompt.zsh` | Starship init |
| `starship.toml` | prompt theme |

`bootstrap.sh` explicitly installs the shell toolchain (`zsh`, `fzf`, `fd`,
`ripgrep`, `bat`, `eza`, `starship`, `zoxide`, `neovim`, `lf`) so it does not
depend on those packages happening to be pulled in as dependencies elsewhere.

Plugins are cloned into `~/.config/zsh/plugins/` by `scripts/setup-zsh-plugins.sh`
(run automatically by `install.sh`), or on the first shell start by `plugins.zsh`.
Update them all later with `zplugin-update`.

Machine-only overrides go in `~/.config/zsh/local.zsh` (see
`local.zsh.example`); it is sourced by `.zshrc` and is intentionally not tracked.

## Wallpapers

Bundled images are in `wallpapers/`. On install they are copied to
`~/.local/share/wallpapers/rafid-dotfiles/` and `scripts/setup-wallpaper.sh`
picks one (default: `vadim.jpg`) for the desktop, Plasma slideshow paths and
the lock screen.

```bash
~/.dotfiles/scripts/setup-wallpaper.sh                    # default wallpaper
~/.dotfiles/scripts/setup-wallpaper.sh --wallpaper john.jpg
~/.dotfiles/scripts/setup-wallpaper.sh --random
~/.dotfiles/scripts/setup-wallpaper.sh --no-apply          # config only
```

Add a wallpaper by dropping an image into `wallpapers/` and committing it.
The SDDM login background is refreshed separately (needs root):

```bash
sudo bash ~/.dotfiles/scripts/setup-login-theme.sh
```

## Install user configs on a new machine

```bash
git clone git@github.com:rafid4507/.dotfiles.git ~/.dotfiles
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
package lists. It now includes the zsh config files too. It skips files that
are already symlinked into the repo, and does not copy the `~/.zshenv` shim or
machine-local `local.zsh`. Wallpapers live only in `wallpapers/`; copy any new
ones there manually.

## Push updates

```bash
cd ~/.dotfiles
git add -A
git commit -m "Update dotfiles"
git push
```

The remote is `git@github.com:rafid4507/.dotfiles.git` (SSH). For HTTPS, generate a Personal Access Token and use it as the password. If you need to replace the old history completely:

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
