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
| `gtk`      | GTK 3/4 theme + icon settings for GUI apps                 |
| `wallpapers` | The desktop wallpaper (aurora)                           |
| `applications` | Desktop entries (Notion web app) + icons               |
| `mimeapps` | Default apps (Chromium browser, Thunar file manager)       |
| `scripts`  | Small helper scripts (`now-playing` album-art popup)       |
| `git`      | Git configuration                                          |

Theme: **Catppuccin Mocha** everywhere.

## How Stow works

Each top-level folder is a *package* whose internal tree mirrors `$HOME`.
For example `niri/.config/niri/config.kdl` becomes a symlink at
`~/.config/niri/config.kdl`. The real file stays in this repo, so editing
either one edits both.

## Fresh machine

**Option A — everything (recommended for switching devices):** installs all
packages, services, *and* the dotfiles via Ansible:

```bash
git clone git@github.com:rafid4507/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh          # installs Ansible + runs the playbook
```

**Option B — dotfiles only** (if the packages are already installed):

```bash
git clone git@github.com:rafid4507/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh            # stows every package
chsh -s /usr/bin/fish   # make fish your login shell (needs your password)
```

## Shell: fish + tmux

`fish` is your login shell, and every interactive terminal **auto-attaches to a
shared tmux session named `main`**, so your work survives closing a window.

- Detach: `Ctrl-a d` · Reattach: just open any terminal (or `tmux a -t main`)
- Split: `Ctrl-a |` / `Ctrl-a -` · New window: `Ctrl-a c` · Reload config: `Ctrl-a r`
- Escape hatch (a raw shell, no tmux): `NO_TMUX=1 fish`
- The bare Linux console (`TERM=linux`) is deliberately excluded, so running
  `niri-session` on tty1 stays clean.

## Default programs

| Role         | App                                                                    |
| ------------ | ---------------------------------------------------------------------- |
| Terminal     | `kitty`                                                                |
| File manager | `thunar` (default handler for `inode/directory`)                       |
| Browser      | `chromium` (also handles `http`/`https` links)                         |
| Music        | **Pear Desktop** — `pear-desktop-bin` (the renamed th-ch/youtube-music) |
| Notion       | Chromium app window: `chromium --app=https://notion.so` (a `Notion` launcher entry ships in the `applications` package) |

**Chromium always opens on the `web` workspace** — the dedicated 10th one —
including its `--app=` windows such as Notion. Jump there with `Mod+0`.

The music app is not in the official repos; install it from the AUR:

```bash
yay -S pear-desktop-bin
```

## Now playing

Whenever audio starts, a card pops up at the top of the screen with the **album
art, track title and artist**. It is made of two parts:

- **`scripts` → `~/.local/bin/now-playing`** follows the active player with
  [`playerctl`](https://github.com/altdesktop/playerctl) (through `playerctld`)
  and sends a mako notification carrying the cover art. mako's
  `[app-name=now-playing]` criteria turn it into a big-cover card.
- **Waybar's `mpris` module** shows a persistent `♪ Title — Artist` readout in
  the centre of the bar. Click it to play/pause, right-click for next,
  middle-click for previous.

Both are started by niri at login (`playerctld` + `now-playing` in
`config.kdl`), so they work for any MPRIS player — Chromium/Notion, Pear
Desktop, mpv, and so on.

## Status bar

The workspace indicator shows **only the workspace you are currently on**
(`current-only` in the waybar config), so the named workspaces `1`–`9` and
`web` no longer fill the bar with empty numbered placeholders.

## Daily use

```bash
cd ~/.dotfiles
stow niri               # link one package
stow -D niri            # unlink one package
stow -R niri            # relink (after adding/removing files)
git add -A && git commit -m "..." && git push
```

## Rebuilding the whole machine (optional)

The [`ansible/`](ansible/) folder contains a playbook that installs every
package, enables the services, and deploys these dotfiles on a fresh Arch
install with a single command. It is **not required** for normal use — Stow and
`install.sh` are enough — but it makes a from-scratch rebuild one command:

```bash
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbook.yml --ask-become-pass
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
| `Mod+1..9`        | Go to fixed workspace 1-9     |
| `Mod+Ctrl+1..9`   | Move column to workspace 1-9  |
| `Mod+0`           | Go to the `web` workspace (10th) |
| `Mod+Ctrl+0`      | Move column to `web`          |
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
