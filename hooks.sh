# Activate mise tool/version manager
if command -v mise >/dev/null; then
  eval "$(mise activate zsh)"
fi

# Activate fnox secret environment loader
if command -v fnox >/dev/null; then
  eval "$(fnox activate zsh)"
fi
