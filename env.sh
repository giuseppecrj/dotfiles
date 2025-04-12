# Owner
export EDITOR="cursor -w"
export CLICOLOR=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export ZSH=$HOME/.oh-my-zsh
export GPG_TTY=$(tty)

ZSH_THEME="spaceship"
SPACESHIP_SHOW_BATTERY="false"
SPACESHIP_GCLOUD_SHOW="false"
SPACESHIP_PROMPT_ASYNC="false"
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

# fnm
if test "$(which fnm)"; then
    eval "$(fnm env)"
fi

# zoxide
if test "$(which zoxide)"; then
    eval "$(zoxide init zsh --cmd j)"
fi

# Source files if they exist
source_if_exists() {
    [ -f "$1" ] && source "$1"
}

source_if_exists "$HOME/dotfiles/hooks.sh"
export PATH="$PATH:$HOME/.foundry/bin"
