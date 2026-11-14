# ============================================================================
#  fish — friendly interactive shell
#  Managed by GNU Stow:  ~/.dotfiles/fish/.config/fish/config.fish
#  fish reads this on every start; the `status is-interactive` block only
#  runs for interactive shells (i.e. your terminals, not scripts).
# ============================================================================

if status is-interactive
    # A clean greeting (fish otherwise prints a welcome message).
    set -g fish_greeting ""

    # ── Prompt: starship ─────────────────────────────────────────────────────
    if type -q starship
        starship init fish | source
    end

    # ── zoxide: `z <dir>` jumps to frequently used directories ───────────────
    if type -q zoxide
        zoxide init fish | source
    end

    # ── fzf key bindings: Ctrl-R history, Ctrl-T files, Alt-C cd ─────────────
    if type -q fzf
        fzf --fish | source
    end
end

# ── Environment variables (set for login shells too) ─────────────────────────
set -gx EDITOR vim
set -gx VISUAL vim
set -gx PAGER less
set -gx LESS "-R"
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx TERMINAL kitty
# Tell apps we are on niri (only if not already set by the session).
set -q XDG_CURRENT_DESKTOP; or set -gx XDG_CURRENT_DESKTOP niri

# ── PATH ─────────────────────────────────────────────────────────────────────
fish_add_path -g ~/.local/bin ~/.cargo/bin ~/go/bin

# ── Aliases ──────────────────────────────────────────────────────────────────
alias ls   'eza --icons --group-directories-first'
alias ll   'eza -l  --icons --group-directories-first --git'
alias la   'eza -la --icons --group-directories-first --git'
alias lt   'eza --tree --level=2 --icons'
alias l    'eza -1 --icons'
alias cat  'bat -pp'
alias catp 'bat'
alias grep 'rg'
alias find 'fd'
alias free 'free -h'
alias ports 'ss -tulpn'
alias mkdir 'mkdir -p'
alias reload 'niri msg action reload-config'
alias fetch 'fastfetch'

# ── Abbreviations (expand in place as you type; press space to accept) ───────
abbr -a g    git
abbr -a gs   'git status'
abbr -a ga   'git add'
abbr -a gc   'git commit'
abbr -a gp   'git push'
abbr -a gl   'git pull'
abbr -a gd   'git diff'
abbr -a gco  'git checkout'
abbr -a gb   'git branch'
abbr -a v    vim
abbr -a ta   'tmux attach'
abbr -a tn   'tmux new -s'
abbr -a y    yazi
abbr -a ff   fastfetch
