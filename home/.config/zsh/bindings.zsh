# =========================================================
# Keybindings
# =========================================================

# Cursor shape per vi mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# Disable command mode line highlight
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# By default zsh-autosuggestions lets Right arrow (forward-char) accept a
# suggestion. Clear that list so only the smart Tab widget below accepts.
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()

# Ctrl+Y -> launch yazi via the `y` wrapper from aliases.zsh.
_yazi_widget() {
  BUFFER='y'
  CURSOR=${#BUFFER}
  zle accept-line
}

# zsh-vi-mode resets all bindings on init, so custom bindings
# must be registered via this hook to survive.
zvm_after_init() {
  # Smart Tab: accept a visible autosuggestion, otherwise complete normally.
  _autosuggest_accept_or_complete() {
    if [[ -n "$POSTDISPLAY" ]]; then
      zle autosuggest-accept
    else
      zle expand-or-complete
    fi
  }
  zle -N _autosuggest_accept_or_complete
  bindkey -M viins '^I' _autosuggest_accept_or_complete
  bindkey -M vicmd '^I' _autosuggest_accept_or_complete

  # Shift+Tab cycles backward through the completion menu.
  bindkey -M viins '^[[Z' reverse-menu-complete

  # Ctrl+Right -> move forward one word (^[[1;5C is the terminal escape code)
  bindkey '^[[1;5C' forward-word

  # Ctrl+Left -> move backward one word (^[[1;5D is the terminal escape code)
  bindkey '^[[1;5D' backward-word

  # Ctrl+F -> fzf file picker (no hidden files)
  bindkey '^F' _fzf_file_no_hidden

  # Ctrl+Y -> yazi file manager (cd to last directory on quit)
  zle -N _yazi_widget
  bindkey -M viins '^Y' _yazi_widget
  bindkey -M vicmd '^Y' _yazi_widget

  # Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
  bindkey '^\' autosuggest-toggle

  # Up/Down -> history search by substring (^[[A/^[[B are up/down arrow escape codes)
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  # Only overwrite Ctrl+R if fzf is installed and its widgets are loaded
  if zle -l | grep -q fzf-history-widget; then
    # Bind fzf specifically to the vi-insert mode (-M viins)
    bindkey -M viins '^R' fzf-history-widget
  fi
}
