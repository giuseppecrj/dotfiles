for file in ~/dotfiles/terminal/*
do
    source $file
done

PATH="$PATH:/usr/local/bin"
PATH="$PATH:~/bin"
PATH="$PATH:/usr/local/bin:/usr/local/sbin"
PATH="$PATH:~/.fnm"

if test $(which fnm)
then
    eval "$(fnm env)"
fi

[ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh

# PATH
export PATH=$PATH
