#!/usr/bin/env bash
# Cloud/Linux devbox setup, suitable for exe.dev and Ubuntu-like VMs.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

install_apt_package() {
    local package="$1"

    if dpkg -s "$package" >/dev/null 2>&1; then
        echo "APT package already installed: $package"
    else
        $SUDO apt-get install -y "$package"
    fi
}

source_if_exists() {
    [ -f "$1" ] && source "$1"
}

echo "Setting up Linux devbox..."

if command -v apt-get >/dev/null 2>&1; then
    $SUDO apt-get update
    apt_packages=(
        build-essential
        ca-certificates
        curl
        git
        jq
        less
        ripgrep
        rsync
        tree
        unzip
        zsh
        zoxide
    )

    for package in "${apt_packages[@]}"; do
        install_apt_package "$package"
    done
else
    echo "Unsupported Linux package manager: expected apt-get" >&2
    exit 1
fi

echo "Installing Oh My Zsh..."
if [ ! -d "$ZSH_DIR" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Installing Spaceship prompt theme..."
mkdir -p "$ZSH_CUSTOM_DIR/themes"
if [ ! -d "$ZSH_CUSTOM_DIR/themes/spaceship-prompt/.git" ]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM_DIR/themes/spaceship-prompt"
else
    git -C "$ZSH_CUSTOM_DIR/themes/spaceship-prompt" pull --ff-only || true
fi
ln -sfn "$ZSH_CUSTOM_DIR/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM_DIR/themes/spaceship.zsh-theme"

echo "Installing mise..."
if ! command -v mise >/dev/null 2>&1; then
    curl https://mise.run | sh
fi
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"

echo "Installing dev runtimes with mise..."
mise install node@latest go@latest bun@latest aube@latest fnox@latest
mise use -g node@latest go@latest bun@latest aube@latest fnox@latest
eval "$(mise activate bash)"

echo "Installing global npm tools..."
npm install -g \
    @atlas.labs/pi-goal \
    @earendil-works/pi-coding-agent \
    @fission-ai/openspec \
    agent-browser \
    corepack
corepack enable || true

echo "Installing Go tools..."
go install golang.org/x/tools/gopls@latest

echo "Linking dotfiles..."
ln -sfn "$DOTFILES_DIR/env.sh" "$HOME/env.sh"
ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
if [ -L "$HOME/hooks.sh" ]; then
    rm "$HOME/hooks.sh"
elif [ -e "$HOME/hooks.sh" ]; then
    echo "Leaving existing non-symlink in place: $HOME/hooks.sh"
fi

if [ -d "$DOTFILES_DIR/fonts" ]; then
    mkdir -p "$HOME/.local/share/fonts"
    cp -f "$DOTFILES_DIR"/fonts/*.ttf "$HOME/.local/share/fonts/" 2>/dev/null || true
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$HOME/.local/share/fonts" || true
fi

if command -v zsh >/dev/null 2>&1 && [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    chsh -s "$(command -v zsh)" 2>/dev/null || echo "Could not change login shell; run: chsh -s $(command -v zsh)"
fi

echo "Linux devbox setup complete."
