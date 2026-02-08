# Owner
export EDITOR="cursor -w"
export CLICOLOR=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export ZSH=$HOME/.oh-my-zsh
export PYENV_ROOT=$HOME/.pyenv
export GPG_TTY=$(tty)

FNM_USING_LOCAL_VERSION=0

plugins=(git macos)

source $HOME/.oh-my-zsh/oh-my-zsh.sh

for file in $HOME/dotfiles/terminal/*; do
    source $file
done

# Homebrew must be set up first — other tools are installed via brew
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Tool initializers
command -v rbenv >/dev/null && eval "$(rbenv init -)"
command -v fnm >/dev/null && eval "$(fnm env)"
command -v pyenv >/dev/null && eval "$(pyenv init -)"
command -v wt >/dev/null && eval "$(wt config shell init zsh)"

if command -v zoxide >/dev/null; then
    source <(fzf --zsh)
    eval "$(zoxide init zsh --cmd j)"
fi

# Source optional files
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
[[ -f "$HOME/dotfiles/hooks.sh" ]] && source "$HOME/dotfiles/hooks.sh"
command -v brew >/dev/null && [[ -f "$(brew --prefix)/opt/spaceship/spaceship.zsh" ]] && source "$(brew --prefix)/opt/spaceship/spaceship.zsh"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# PATH
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.foundry/bin:$HOME/Library/Python/3.10/bin:$PATH"
