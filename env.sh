# PATH
export PATH="/usr/local/bin:$PATH"

# # Owner
export CLICOLOR=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export LDFLAGS="-L/usr/local/opt/libffi/lib"
export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"
export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"
SPACESHIP_SHOW_BATTERY="false"
plugins=(git)

source $HOME/.oh-my-zsh/oh-my-zsh.sh

for file in ~/dotfiles/terminal/*
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

# Autojump
if [ -f '/opt/homebrew/etc/profile.d/autojump.sh' ]; then source '/opt/homebrew/etc/profile.d/autojump.sh'; fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/g/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/g/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/g/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/g/google-cloud-sdk/completion.zsh.inc'; fi
