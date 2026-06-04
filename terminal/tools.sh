# Tool initializers
# Keep executable startup hooks isolated so shell startup is easier to debug.

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

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

# atlas completions
#compdef atlas
_incur_complete_atlas() {
    local completions=("${(@f)$(
        export _COMPLETE_INDEX=$(( CURRENT - 1 ))
        export COMPLETE="zsh"
        "atlas" -- "${words[@]}" 2>/dev/null
    )}")
    if [[ -n $completions ]]; then
        _describe 'values' completions -S ''
    fi
}
compdef _incur_complete_atlas atlas
