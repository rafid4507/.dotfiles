# ~/.config/zsh/.zshenv
# Sourced by ~/.zshenv (see the shim at the root of these dotfiles).

# ---------- XDG base directories ----------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
# Default editor used by git, crontab, etc.
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# ---------- GPG ----------
# Only set GPG_TTY when attached to a terminal (avoids "not a tty" at login).
if [[ -t 0 ]]; then
  export GPG_TTY=$(tty)
fi

# ---------- ZDOTDIR ----------
# Safe to set here too, so this file works even if sourced directly.
export ZDOTDIR="$HOME/.config/zsh"

# ---------- Starship ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

# ---------- PATH ----------
# Personal binaries/scripts
export PATH="$HOME/.local/bin:$PATH"
