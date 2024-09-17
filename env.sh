# Owner
export EDITOR="cursor -w"
export CLICOLOR=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export ZSH=$HOME/.oh-my-zsh
export PYENV_ROOT=$HOME/.pyenv
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export GPG_TTY=$(tty)

ZSH_THEME="spaceship"
SPACESHIP_SHOW_BATTERY="false"
SPACESHIP_GCLOUD_SHOW="false"
FNM_USING_LOCAL_VERSION=0

plugins=(git)

source $HOME/.oh-my-zsh/oh-my-zsh.sh

if [ -d "$HOME/dotfiles/terminal" ]; then
    for file in "$HOME"/dotfiles/terminal/*; do
        [ -f "$file" ] && source "$file"
    done
fi

# Homebrew
if command -v brew >/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Rbenv
if command -v rbenv >/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

# fnm
command -v fnm >/dev/null 2>&1 && eval "$(fnm env)"

# pyenv
command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init -)"

# zoxide
if command -v zoxide >/dev/null 2>&1; then
    source <(fzf --zsh)
    eval "$(zoxide init zsh --cmd j)"
fi

# Source files if they exist
source_if_exists() {
    [ -f "$1" ] && source "$1"
}

source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/google-cloud-sdk/path.zsh.inc"
source_if_exists "$HOME/google-cloud-sdk/completion.zsh.inc"
source_if_exists "$HOME/dotfiles/hooks.sh"

export PATH="$PATH:$HOME/.foundry/bin"
export PATH="$PATH:$HOME/Library/Python/3.10/bin"

