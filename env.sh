for file in ~/dotfiles/terminal/*
do
    source $file
done

# PATH
export PATH="/usr/local/bin:$PATH"

# Owner
export CLICOLOR=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export LDFLAGS="-L/usr/local/opt/libffi/lib"
export PKG_CONFIG_PATH="/usr/local/opt/libffi/lib/pkgconfig"

# Autojump
if [ -f '/usr/local/etc/profile.d/autojump.sh' ]; then source '/usr/local/etc/profile.d/autojump.sh'; fi

# Homebrew
if test $(which brew); then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
