export EDITOR="open -a Warp -W"
export VISUAL="open -a Warp -W"
export CLICOLOR=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export ZSH=$HOME/.oh-my-zsh
export PYENV_ROOT=$HOME/.pyenv
export GPG_TTY=$(tty)

# Homebrew — hardcoded for Apple Silicon, avoids slow eval "$(brew shellenv)"
export HOMEBREW_PREFIX=/opt/homebrew
export HOMEBREW_CELLAR=/opt/homebrew/Cellar
export HOMEBREW_REPOSITORY=/opt/homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"

# Brew completions must be in FPATH before compinit (which oh-my-zsh runs)
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"

FNM_USING_LOCAL_VERSION=0

ZSH_THEME="spaceship"
SPACESHIP_SHOW_BATTERY="false"
SPACESHIP_GCLOUD_SHOW="false"
SPACESHIP_PROMPT_ASYNC="false"

plugins=(git macos)

source "$HOME/.oh-my-zsh/oh-my-zsh.sh"

for file in "$HOME"/dotfiles/terminal/*.sh; do
    [ -f "$file" ] && source "$file"
done

# Tool initializers
command -v rbenv >/dev/null && eval "$(rbenv init -)"
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd)"
command -v pyenv >/dev/null && eval "$(pyenv init -)"
command -v wt >/dev/null && eval "$(wt config shell init zsh)"

if command -v fzf >/dev/null; then
    source <(fzf --zsh)
fi

if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh --cmd j)"
fi

source_if_exists() {
    [ -f "$1" ] && source "$1"
}

# Source optional files
source_if_exists "$HOME/.secrets.env"
source_if_exists "$HOME/.cargo/env"
source_if_exists "$HOME/dotfiles/hooks.sh"
[[ -f /opt/homebrew/opt/spaceship/spaceship.zsh ]] && source /opt/homebrew/opt/spaceship/spaceship.zsh
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# PATH
export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.foundry/bin:$PATH"
