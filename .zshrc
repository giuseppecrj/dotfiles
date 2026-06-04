#!/bin/zsh
source "$HOME/env.sh"

export PATH="$PATH:$HOME/.bifrost/bin"
export PATH="$HOME/.local/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# LM Studio CLI
export PATH="$PATH:$HOME/.lmstudio/bin"

# Warp/Oz CLI
export PATH="$PATH:/Applications/Warp.app/Contents/Resources/bin"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
