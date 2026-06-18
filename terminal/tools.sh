# Tool initializers
# Keep executable startup hooks isolated so shell startup is easier to debug.

# wt CLI shell integration
command -v wt >/dev/null && eval "$(wt config shell init zsh)"

# fzf shell integration
if command -v fzf >/dev/null && [[ -o interactive && -t 1 ]]; then
    source <(fzf --zsh)
fi

# zoxide directory jumper
if command -v zoxide >/dev/null; then
    eval "$(zoxide init zsh --cmd j)"
fi

# mise tool/version manager
if command -v mise >/dev/null; then
    eval "$(mise activate zsh)"
fi

# fnox secret environment loader
if command -v fnox >/dev/null; then
    eval "$(fnox activate zsh)"
fi
