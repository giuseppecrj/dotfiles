#!/usr/bin/env bash
# Dispatch to the OS-specific installer.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
    Darwin)
        exec "$DOTFILES_DIR/install/macos.sh" "$@"
        ;;
    Linux)
        exec "$DOTFILES_DIR/install/linux.sh" "$@"
        ;;
    *)
        echo "Unsupported OS: $(uname -s)" >&2
        exit 1
        ;;
esac
