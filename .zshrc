#!/bin/zsh
source "$HOME/env.sh"

export PATH="$PATH:$HOME/.bifrost/bin"
export PATH="$HOME/.local/bin:$PATH"

# Amp CLI
export PATH="$HOME/.amp/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section
