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

for file in $HOME/dotfiles/terminal/*
do
    source $file
done

# Homebrew
if test "$(which brew)"; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Rbenv
if test "$(which rbenv)"; then
    eval "$(rbenv init -)"
fi

# fnm
if test "$(which fnm)"; then
    eval "$(fnm env)"
fi

# pyenv
if test "$(which pyenv)"; then
    eval "$(pyenv init -)"
fi

# zoxide
if test "$(which zoxide)"; then
    source <(fzf --zsh)
    eval "$(zoxide init zsh --cmd j)"
fi

# Source files if they exist
source_if_exists() {
    [ -f "$1" ] && source "$1"
}

source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/dotfiles/hooks.sh"

export PATH="$PATH:$HOME/.foundry/bin"
export PATH="$PATH:$HOME/Library/Python/3.10/bin"
