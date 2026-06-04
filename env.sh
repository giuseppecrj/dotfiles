# Environment
export CLICOLOR=1
export ZSH=$HOME/.oh-my-zsh
export GPG_TTY=$(tty)

# Homebrew
# macOS-only; hardcoded for Apple Silicon to avoid slow eval "$(brew shellenv)".
if [[ "$(uname -s)" == "Darwin" ]]; then
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"
    export HOMEBREW_PREFIX=/opt/homebrew
    export HOMEBREW_CELLAR=/opt/homebrew/Cellar
    export HOMEBREW_REPOSITORY=/opt/homebrew
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
fi

# PATH
export PATH="$HOME/.opencode/bin:$HOME/.grok/bin:$HOME/.local/bin:$HOME/.foundry/bin:$PATH"
export PATH="$PATH:$HOME/.bifrost/bin:$HOME/.lmstudio/bin"

# Completions
# Completion paths must be configured before oh-my-zsh runs compinit.
FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
fpath=(~/.grok/completions/zsh $fpath)

# Oh My Zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
if [[ -f "$ZSH_CUSTOM/themes/spaceship.zsh-theme" || -f "$ZSH/themes/spaceship.zsh-theme" ]]; then
    ZSH_THEME="spaceship"
elif [[ -f /opt/homebrew/opt/spaceship/spaceship.zsh ]]; then
    # Homebrew installs Spaceship as a prompt script, not an Oh My Zsh theme.
    ZSH_THEME=""
else
    ZSH_THEME="robbyrussell"
fi
SPACESHIP_SHOW_BATTERY="false"
SPACESHIP_GCLOUD_SHOW="false"
SPACESHIP_PROMPT_ASYNC="false"
plugins=(git macos)

source_if_exists() {
    [ -f "$1" ] && source "$1"
}

source_if_exists "$HOME/.oh-my-zsh/oh-my-zsh.sh"
if [[ "$ZSH_THEME" != "spaceship" ]]; then
    source_if_exists /opt/homebrew/opt/spaceship/spaceship.zsh
fi

# Terminal customizations
source_if_exists "$HOME/dotfiles/terminal/prompt.sh"
source_if_exists "$HOME/dotfiles/terminal/aliases.sh"
source_if_exists "$HOME/dotfiles/terminal/functions.sh"
source_if_exists "$HOME/dotfiles/terminal/tools.sh"

# Optional local files
source_if_exists "$HOME/.secrets.env"
source_if_exists "$HOME/.cargo/env"
