# .dotfiles

My personal Arch Linux + [niri](https://github.com/YaLTeR/niri) setup, managed
with [GNU Stow](https://www.gnu.org/software/stow/).

## What's inside

| Package    | What it configures                                         |
| ---------- | ---------------------------------------------------------- |
| `niri`     | The niri scrollable-tiling Wayland compositor              |
| `kitty`    | Terminal emulator                                          |
| `fish`     | Friendly interactive shell                                 |
| `tmux`     | Terminal multiplexer                                       |
| `starship` | Shell prompt                                               |
| `waybar`   | Status bar                                                 |
| `fuzzel`   | Application launcher                                       |
| `mako`     | Notification daemon                                        |
| `swaylock` | Screen locker                                              |
| `yazi`     | Terminal file manager                                      |
| `btop`     | Resource monitor                                           |
| `git`      | Git configuration                                          |

Theme: **Catppuccin Mocha** everywhere.

## How Stow works

Each top-level folder is a *package* whose internal tree mirrors `$HOME`.
For example `niri/.config/niri/config.kdl` becomes a symlink at
`~/.config/niri/config.kdl`. The real file stays in this repo, so editing
either one edits both.

## Fresh machine

```bash
git clone <this repo> ~/.dotfiles
cd ~/.dotfiles
./install.sh            # stows every package
chsh -s /usr/bin/fish   # make fish your login shell (needs your password)
```

## Daily use

```bash
cd ~/.dotfiles
stow niri               # link one package
stow -D niri            # unlink one package
stow -R niri            # relink (after adding/removing files)
git add -A && git commit -m "..." && git push
```

## Starting the desktop

Log in on a TTY (tty1) and run:

```bash
niri-session
```

`niri-session` starts niri *as a session*: it exports the Wayland environment
to systemd/D-Bus and starts the services (portals, etc.). Plain `niri` also
works but is meant for nested/testing use.

## Key bindings (Mod = Super)

| Keys              | Action                        |
| ----------------- | ----------------------------- |
| `Mod+Return`/`T`  | Terminal (kitty)              |
| `Mod+D`           | App launcher (fuzzel)         |
| `Mod+E`           | File manager (thunar)         |
| `Mod+Q`           | Close window                  |
| `Mod+O`           | Overview                      |
| `Mod+H/J/K/L`     | Focus column/window           |
| `Mod+Ctrl+H/J/K/L`| Move column/window            |
| `Mod+1..9`        | Go to workspace               |
| `Mod+Ctrl+1..9`   | Move column to workspace      |
| `Mod+R`           | Cycle column width            |
| `Mod+F`           | Maximize column               |
| `Mod+Shift+F`     | Fullscreen                    |
| `Mod+V`           | Toggle floating               |
| `Mod+W`           | Toggle tabbed column          |
| `Mod+Alt+L`       | Lock screen                   |
| `Print`           | Screenshot                    |
| `Mod+Shift+S`     | Region screenshot -> swappy   |
| `Mod+Alt+V`       | Clipboard history             |
| `Mod+Shift+E`     | Quit niri                     |
| `Mod+Shift+/`     | Show all hotkeys              |

## Notes for VirtualBox

The compositor runs on the `vmwgfx` driver. For smooth animations enable
**Display → Graphics Controller: VMSVGA** and **Enable 3D Acceleration**, and
give the VM at least 64 MB video memory. If niri fails to start with an EGL
error, force software rendering:

```bash
LIBGL_ALWAYS_SOFTWARE=1 niri-session
```
