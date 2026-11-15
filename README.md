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
| `rofi`     | Application launcher / window switcher / dmenu             |
| `fuzzel`   | Fallback launcher (installed, not bound)                   |
| `mako`     | Notification daemon                                        |
| `swaylock` | Screen locker                                              |
| `yazi`     | Terminal file manager                                      |
| `btop`     | Resource monitor                                           |
| `gtk`      | GTK 3/4 theme + icon settings for GUI apps                 |
| `wallpapers` | The desktop wallpaper (aurora)                           |
| `applications` | Desktop entries (Notion web app) + icons               |
| `mimeapps` | Default apps (Chromium browser, Thunar file manager)       |
| `scripts`  | Helper scripts (`now-playing` popup + bar, workspace indicator) |
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

When a track starts, a small **animated card** appears just under the bar and
**auto-hides after ~4 seconds** (it stays put while the pointer is over it).
Instead of cover art — which players such as Chromium/YouTube Music usually fill
with an app or site logo — it shows **small playback buttons** (previous /
play-pause / next), the track name in a **short scrolling window** (about 12
characters at a time), the artist, and a little **animated equalizer**. There is
no duration/seek bar on purpose — the animation is what tells you it is actually
playing.

The same scrolling name + equalizer also live in the centre of the bar.

- **`scripts` → `~/.local/bin/now-playing`** follows the active player with
  [`playerctl`](https://github.com/altdesktop/playerctl) (through `playerctld`)
  and, on every track change, launches the popup widget.
- **`scripts` → `~/.local/bin/now-playing-widget`** *is* the popup: a tiny GTK4
  + [`gtk4-layer-shell`](https://github.com/wmww/gtk4-layer-shell) card anchored
  at the top-centre, hugging the bar. The playback buttons drive `playerctl`;
  the name scrolls through a ~12-character window. It auto-hides after ~4s.
- **`scripts` → `~/.local/bin/now-playing-bar`** drives the bar readout: the
  `custom/nowplaying` waybar module streams one animation frame per line. Click
  it to play/pause, right-click for next, middle-click for previous.

Everything is started by niri at login (`playerctld` + `now-playing` in
`config.kdl`) and works for any MPRIS player — Chromium/Notion, Pear Desktop,
mpv, and so on.

The animated popup needs two extra packages (in Arch's `extra`; the Ansible
playbook installs them automatically):

```bash
sudo pacman -S python-gobject gtk4-layer-shell
```

Without them, `now-playing` falls back to a plain (static) mako notification, so
the feature keeps working either way.

## Launcher (rofi)

`Mod+D` opens **rofi** (application launcher), `Mod+Tab` opens the window
switcher, and `Mod+Alt+V` pipes the clipboard history through `rofi -dmenu`.
It uses the **`squared-material-red`** theme from
[newmanls/rofi-themes-collection](https://github.com/newmanls/rofi-themes-collection)
(squared corners, Material Darker palette, red accent), shipped in the `rofi`
package:

- `rofi/.config/rofi/config.rasi` — rofi's behaviour + `@theme` line
- `rofi/.config/rofi/themes/squared-material-red.rasi` — the theme itself

Try it by hand: `rofi -show drun`, `rofi -show window`.

## Notifications

`mako` draws **small, compact cards** in the top-right corner, tucked right up
under the bar (a 4px margin), and they **fade after ~3s** (2s for low urgency).
Critical notifications stay until dismissed. The same compact look is used by
the `now-playing` fallback popup.

## Status bar

The bar is deliberately **compact and icon-led**: a workspace pill on the left,
the focused window next to it, the scrolling track name + clock in the middle,
and a tidy group of coloured icon modules on the right (tray, audio, network,
CPU, memory) separated by hair-thin dividers.

Two custom modules replace waybar's built-ins, because neither can animate:

- **`custom/workspaces`** (`~/.local/bin/ws-indicator`) shows a **dim dot for
  every workspace that has windows**, and draws the workspace you are on as a
  **filled "tab"** pill. Names are trimmed to at most 12 characters (e.g.
  `● web`). Empty workspaces are hidden. The dots are not individually
  clickable — use `Mod+1..9` / `Mod+0` to switch.
- **`custom/nowplaying`** (`~/.local/bin/now-playing-bar`) is the scrolling
  track readout described above.

> The indicator used to be called `niri-workspaces`, which made `niri` + `<Tab>`
> in the shell complete to a confusing third entry. It is now `ws-indicator`.

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
| `Mod+D`           | App launcher (rofi)           |
| `Mod+Tab`         | Window switcher (rofi)        |
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
