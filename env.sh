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

# Rust
if [ -f $HOME/.cargo/env ]; then source $HOME/.cargo/env; fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then source $HOME/google-cloud-sdk/path.zsh.inc; fi

# The next line enables shell command completion for gcloud.
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then source $HOME/google-cloud-sdk/completion.zsh.inc; fi

# Hooks for zsh
if [ -f $HOME/dotfiles/hooks.sh ]; then source $HOME/dotfiles/hooks.sh; fi

export PATH="$PATH:$HOME/.foundry/bin"
export PATH="$PATH:$HOME/Library/Python/3.10/bin"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && . "$HOME/.fig/shell/zshrc.post.zsh"

