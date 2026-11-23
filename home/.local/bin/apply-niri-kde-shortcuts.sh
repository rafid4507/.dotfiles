#!/usr/bin/env bash
# Apply the custom Niri-style keymap on KDE Plasma with Karousel.
#   Meta+H/L : switch to the window left / right in the current workspace
#   Alt+H/L  : focus column left / right
#   Meta+J/K : workspace up / down
#   Meta+U/I : move the focused column to workspace up / down
#   Alt+J/K  : focus window above / below in the column
set -euo pipefail

CFG="${XDG_CONFIG_HOME:-$HOME/.config}/kglobalshortcutsrc"

kw() {
  local -a groups=()
  while [[ "$1" != "--" ]]; do
    groups+=(--group "$1")
    shift
  done
  shift
  kwriteconfig6 --file "$CFG" "${groups[@]}" --key "$1" --notify "$2"
}

# ---------- Clear conflicting KDE defaults ----------
kw ksmserver -- 'Lock Session' 'Ctrl+Alt+L,Ctrl+Alt+L,Lock Session'

kw kwin -- 'Walk Through Windows' $'Alt+Tab\tMeta+Tab\tMeta+Z,Alt+Tab\tMeta+Tab,Walk Through Windows'
kw kwin -- 'Walk Through Windows (Reverse)' $'Alt+Shift+Tab\tMeta+Shift+Tab,Alt+Shift+Tab\tMeta+Shift+Tab,Walk Through Windows (Reverse)'

kw plasmashell -- 'show-on-mouse-pos' 'Meta+Shift+V,Meta+V,Show Clipboard Items at Mouse Position'
kw plasmashell -- 'activate widget 190' 'none,none,Activate Application Dashboard Widget'
kw plasmashell -- 'activate widget 4' 'none,none,Activate Pager Widget'
kw plasmashell -- 'manage activities' 'none,none,Show Activity Switcher'

# ---------- Meta: switch to the window left / right in this workspace ----------
kw kwin -- 'Switch Window Left'  'Meta+H,none,Switch to Window to the Left'
kw kwin -- 'Switch Window Right' 'Meta+L,none,Switch to Window to the Right'
kw kwin -- 'karousel-column-move-left'  'none,none,Karousel: Move column left'
kw kwin -- 'karousel-column-move-right' 'none,none,Karousel: Move column right'
kw kwin -- 'karousel-focus-previous' 'none,none,Karousel: Previous window in workspace'
kw kwin -- 'karousel-focus-next'     'none,none,Karousel: Next window in workspace'

# ---------- Karousel: tile the screen that currently has focus ----------
kw kwin -- 'karousel-screen-switch' $'Meta+M\tMeta+Ctrl+Return,Meta+Ctrl+Return,Karousel: Move Karousel grid to the current screen'

# ---------- Alt: focus column / window ----------
kw kwin -- 'karousel-focus-left'  'Alt+H,none,Karousel: Focus column left'
kw kwin -- 'karousel-focus-right' 'Alt+L,none,Karousel: Focus column right'
kw kwin -- 'karousel-focus-up'    'Alt+J,none,Karousel: Focus window above'
kw kwin -- 'karousel-focus-down'  'Alt+K,none,Karousel: Focus window below'

# ---------- Workspace navigation and moving columns ----------
kw kwin -- 'Switch to Previous Desktop' 'Meta+J,none,Switch to Previous Desktop'
kw kwin -- 'Switch to Next Desktop'     'Meta+K,none,Switch to Next Desktop'
kw kwin -- 'karousel-column-move-to-previous-desktop' 'Meta+U,none,Karousel: Move column to previous desktop'
kw kwin -- 'karousel-column-move-to-next-desktop'     'Meta+I,none,Karousel: Move column to next desktop'

# Free Meta+1..9 on Karousel so KWin can own them for desktops.
for n in 1 2 3 4 5 6 7 8 9; do
  kw kwin -- "karousel-focus-$n" "none,none,Karousel: Move focus to column $n"
done

# ---------- Keep the existing window-moving keys ----------
kw kwin -- 'karousel-window-move-left'  'Meta+Ctrl+H,none,Karousel: Move window left'
kw kwin -- 'karousel-window-move-right' 'Meta+Ctrl+L,none,Karousel: Move window right'
kw kwin -- 'karousel-window-move-up'    'Meta+Ctrl+K,none,Karousel: Move window up'
kw kwin -- 'karousel-window-move-down'  'Meta+Ctrl+J,none,Karousel: Move window down'
kw kwin -- 'karousel-window-toggle-floating' 'Meta+V,none,Karousel: Toggle floating'
kw kwin -- 'karousel-cycle-preset-widths'    'Meta+R,none,Karousel: Cycle through preset column widths'

# ---------- KWin: window actions ----------
kw kwin -- 'Window Maximize' 'Meta+F,Meta+PgUp,Maximize Window'
kw kwin -- 'Window Close'    'Meta+Q,Alt+F4,Close Window'

# Karousel Overview is the primary overview; KWin's built-in one gets no shortcut.
kw kwin -- 'Karousel Overview' $'Meta+O\tMeta+Ctrl+O,none,Karousel: Toggle overview'
kw kwin -- 'Overview'          'none,Meta+W,Toggle Overview'

# Make sure the effect and Karousel stay enabled on next KWin start.
kwriteconfig6 --file "${XDG_CONFIG_HOME:-$HOME/.config}/kwinrc" \
  --group Plugins --key karouselEnabled true --notify
kwriteconfig6 --file "${XDG_CONFIG_HOME:-$HOME/.config}/kwinrc" \
  --group Plugins --key karousel_overviewEnabled true --notify

# ---------- KWin: virtual desktops ----------
declare -A SWITCH_DEFAULTS=(
  [1]=$'Ctrl+F1\tMeta+1\tMeta+F1'
  [2]=$'Ctrl+F2\tMeta+2\tMeta+F2'
  [3]=$'Ctrl+F3\tMeta+3\tMeta+F3'
  [4]=$'Ctrl+F4\tMeta+F4'
  [5]='none'
  [6]='none' [7]='none' [8]='none' [9]='none'
)
# Desktop 4 is reached with Meta+9, desktop 5 with Meta+0; Meta+4/5 stay free.
declare -A SWITCH_KEYS=(
  [1]='Meta+1' [2]='Meta+2' [3]='Meta+3' [4]='Meta+9' [5]='Meta+0'
  [6]='Meta+6' [7]='Meta+7' [8]='Meta+8' [9]='none'
)
for n in 1 2 3 4 5 6 7 8 9; do
  kw kwin -- "Switch to Desktop $n" "${SWITCH_KEYS[$n]},${SWITCH_DEFAULTS[$n]},Switch to Desktop $n"
  kw kwin -- "Window to Desktop $n" "Meta+Ctrl+$n,none,Window to Desktop $n"
done
kw kwin -- 'Switch to Desktop 10' 'none,none,Switch to Desktop 10'

# ---------- Plasma task manager: free Meta+1..9 ----------
for n in 1 2 3 9; do
  kw plasmashell -- "activate task manager entry $n" "Meta+Alt+$n,Meta+$n,Activate Task Manager Entry $n"
done
for n in 4 5 6 7 8; do
  kw plasmashell -- "activate task manager entry $n" "none,Meta+$n,Activate Task Manager Entry $n"
done

# ---------- Launchers ----------
kw services org.kde.krunner.desktop -- _launch $'Alt+F2\tMeta+D'
kw services org.kde.konsole.desktop -- _launch $'Meta+Return\tMeta+T'
kw services systemsettings.desktop -- _launch 'Meta+S'
kw services org.kde.plasma-systemmonitor.desktop -- _launch 'Ctrl+Shift+Esc'

echo "Done. Run apply-niri-kde-shortcuts-live.py to apply without logging out."
