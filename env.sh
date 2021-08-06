# OH-MY-ZSH
export ZSH="~/.oh-my-zsh"

# PATH
export PATH="/usr/local/bin:$PATH"

# Owner
export CLICOLOR=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export LDFLAGS="-L/usr/local/opt/libffi/lib"
export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

# options
ZSH_THEME="spaceship"
SPACESHIP_SHOW_BATTERY="false"
plugins(git)

# source files
source $ZSH/oh-my-zsh.sh

for file in ~/dotfiles/terminal/*
do
    source $file
done

# Autojump
if [ -f '/usr/local/etc/profile.d/autojump.sh' ]; then source '/usr/local/etc/profile.d/autojump.sh'; fi

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
