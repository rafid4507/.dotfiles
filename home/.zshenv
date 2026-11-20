# ~/.zshenv - zsh entry point.
# Keep the interactive config in ~/.config/zsh so it can be tracked in dotfiles.
export ZDOTDIR="$HOME/.config/zsh"
[[ -f "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"
