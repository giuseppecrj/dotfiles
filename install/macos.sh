#!/bin/bash
# Fresh Dev Setup macOS

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"

prompt_with_default() {
    local prompt="$1"
    local default_value="$2"
    local value=""

    if [ -n "$default_value" ]; then
        read -r -p "$prompt [$default_value]: " value
        echo "${value:-$default_value}"
    else
        read -r -p "$prompt: " value
        echo "$value"
    fi
}

install_formula() {
    local formula="$1"

    if brew list --formula "$formula" >/dev/null 2>&1; then
        echo "Formula already installed: $formula"
    else
        brew install "$formula"
    fi
}

install_cask() {
    local cask="$1"
    local app_name="${2:-}"

    if brew list --cask "$cask" >/dev/null 2>&1; then
        echo "Cask already installed: $cask"
        return
    fi

    if [ -n "$app_name" ] && [ -d "/Applications/$app_name.app" ]; then
        echo "App already present outside Homebrew, skipping cask: $cask (/Applications/$app_name.app)"
        return
    fi

    brew install --cask "$cask"
}

install_mas_app() {
    local app_id="$1"
    local app_name="$2"

    if [ -d "/Applications/$app_name.app" ]; then
        echo "App Store app already installed: $app_name"
    else
        mas install "$app_id"
    fi
}

echo "Setting up Mac..."

# xcode.sh [START]
echo "Install Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install || true
    read -r -p "Hit [Enter] to continue once Xcode Command Line Tools completes..."
fi

if xcodebuild -version >/dev/null 2>&1; then
    sudo xcodebuild -license accept || true
fi
# xcode.sh [END]

# homebrew.sh [START]
echo "Installing Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

echo "Updating Homebrew Repository..."
brew update

echo "Installing Homebrew taps..."
brew tap oven-sh/bun
brew tap tenderly/tenderly
brew tap withgraphite/tap

echo "Installing CLI tools with Homebrew..."
formulae=(
    age
    awk
    buf
    chezmoi
    cloudflared
    ffmpeg
    gh
    go
    jq
    just
    lcov
    mas
    mise
    mole
    pkl
    pnpm
    ripgrep
    rust
    spaceship
    tree
    uv
    yarn
    yq
    zoxide
    oven-sh/bun/bun@1.3.3
    tenderly/tenderly/tenderly
    withgraphite/tap/graphite
)

for formula in "${formulae[@]}"; do
    install_formula "$formula"
done

echo "Install Apps..."
install_cask 1password "1Password"
install_cask 1password-cli
install_cask docker "Docker"
install_cask lm-studio "LM Studio"
install_cask ngrok
install_cask obsidian "Obsidian"
install_cask postgres-app "Postgres"
install_cask tailscale "Tailscale"
install_cask thebrowsercompany-dia "Dia"
# Intentionally not installed here: non-Pi agent apps, AI IDEs, chat/meeting apps, and hardware-specific drivers.
# homebrew.sh [END]

# dots.sh [START]
echo "Defaulting to zsh..."
if [ "${SHELL:-}" != "/bin/zsh" ]; then
    chsh -s /bin/zsh
fi

echo "Setup dotfiles..."
if [ ! -d "$HOME/dotfiles/.git" ]; then
    git clone git@github.com:giuseppecrj/dotfiles.git "$HOME/dotfiles"
fi
if [ -d "$HOME/dotfiles/.git" ]; then
    DOTFILES_DIR="$HOME/dotfiles"
fi

ln -sfn "$DOTFILES_DIR/env.sh" "$HOME/env.sh"
ln -sfn "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
if [ -L "$HOME/hooks.sh" ]; then
    rm "$HOME/hooks.sh"
elif [ -e "$HOME/hooks.sh" ]; then
    echo "Leaving existing non-symlink in place: $HOME/hooks.sh"
fi

mkdir -p "$HOME/Library/Fonts"
cp -f "$DOTFILES_DIR"/fonts/*.ttf "$HOME/Library/Fonts/"
# dots.sh [END]

# oh-my-zsh.sh [START]
echo "Installing Oh-my-zsh..."
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
# oh-my-zsh.sh [END]

# git.sh [START]
echo "Getting user info from git..."
existing_name="$(git config --global user.name 2>/dev/null || true)"
existing_email="$(git config --global user.email 2>/dev/null || true)"
full_name="$(prompt_with_default "Enter Name" "$existing_name")"
email="$(prompt_with_default "Enter Email" "$existing_email")"

while [ -z "$full_name" ]; do
    full_name="$(prompt_with_default "Enter Name" "")"
done

while [ -z "$email" ]; do
    email="$(prompt_with_default "Enter Email" "")"
done

echo "Setting up git config..."
touch "$HOME/.gitignore"
grep -qxF ".secrets.env" "$HOME/.gitignore" || echo ".secrets.env" >> "$HOME/.gitignore"

git config --global color.ui auto
git config --global init.defaultBranch main

git config --global alias.done '!f() { BRANCH=$(git branch --show-current); git checkout main && git pull && git branch -d $BRANCH; }; f'
git config --global alias.aliases "!git config --get-regexp alias | sed -re 's/alias\\.(\\S*)\\s(.*)$/\\1 = \\2/g'"
git config --global alias.ci commit
git config --global alias.ck checkout
git config --global alias.st status
git config --global alias.br branch
git config --global alias.prune "remote prune origin"
git config --global alias.lines "diff --shortstat"
git config --global alias.lg "log --graph --date=relative --pretty=tformat:'%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%an %ad)%Creset'"
git config --global alias.oops "commit --amend --no-edit"
git config --global alias.push-with-lease "push --force-with-lease"
git config --global alias.rebase-with-hooks "rebase -x 'git reset --soft HEAD~1 && git commit -C HEAD@{1}'"
git config --global alias.review-local "!git lg @{push}.."
git config --global alias.reword "commit --amend"
git config --global alias.uncommit "reset --soft HEAD~1"
git config --global alias.untrack "rm --cache --"
git config --global alias.cleanup "!git branch --merged | grep  -v '\*\|main\|develop' | xargs -n 1 -r git branch -d"
git config --global alias.cleanups "!git branch -vv | grep ': gone]' | grep -v '\*' | awk '{ print \$1; }' | xargs -r git branch -D"

git config --global core.excludesfile "$HOME/.gitignore"
git config --global core.whitespace -trailing-space

git config --global diff.mnemonicPrefix true
git config --global diff.renames true
git config --global diff.wordRegex .
git config --global diff.submodule log
git config --global --unset-all diff.tool >/dev/null 2>&1 || true
git config --global --remove-section difftool.cursor >/dev/null 2>&1 || true

git config --global fetch.recurseSubmodules on-demand
git config --global grep.break true
git config --global grep.heading true
git config --global grep.lineNumber true
git config --global grep.extendedRegexp true
git config --global log.abbrevCommit true
git config --global log.follow true
git config --global log.decorate false
git config --global merge.ff false
git config --global mergetool.keepBackup false
git config --global mergetool.keepTemporaries false
git config --global mergetool.writeToTemp true
git config --global mergetool.prompt false
git config --global pull.rebase true
git config --global push.default upstream
git config --global push.followTags true
git config --global push.autoSetupRemote true
git config --global status.submoduleSummary true
git config --global status.showUntrackedFiles all
git config --global color.branch.upstream cyan
git config --global tag.sort version:refname

git config --global --unset-all versionsort.prereleaseSuffix >/dev/null 2>&1 || true
for suffix in -pre .pre -beta .beta -rc .rc; do
    git config --global --add versionsort.prereleaseSuffix "$suffix"
done

git config --global credential.helper osxkeychain
git config --global --unset-all credential.https://github.com.helper >/dev/null 2>&1 || true
git config --global --add credential.https://github.com.helper ""
git config --global --add credential.https://github.com.helper "!$(brew --prefix)/bin/gh auth git-credential"
git config --global --unset-all credential.https://gist.github.com.helper >/dev/null 2>&1 || true
git config --global --add credential.https://gist.github.com.helper ""
git config --global --add credential.https://gist.github.com.helper "!$(brew --prefix)/bin/gh auth git-credential"

git config --global user.name "$full_name"
git config --global user.email "$email"

echo "Setting up 1Password CLI and SSH agent..."
echo "Please sign in to 1Password CLI if needed..."
op account add --address my.1password.com --email "$email" || true

# Keep private SSH keys inside 1Password. Do not export them to ~/.ssh.
# Enable the 1Password SSH agent in the 1Password app, then use it for Git SSH signing.
mkdir -p "$DOTFILES_DIR/bin" "$HOME/.config/git"
chmod 755 "$DOTFILES_DIR/bin/git-ssh-sign-1password" 2>/dev/null || true

git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global gpg.ssh.program "$DOTFILES_DIR/bin/git-ssh-sign-1password"
git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
touch "$HOME/.config/git/allowed_signers"

existing_signing_key="$(git config --global user.signingkey 2>/dev/null || true)"
signing_key="$(prompt_with_default "Enter SSH signing public key (optional)" "$existing_signing_key")"
if [ -n "$signing_key" ]; then
    git config --global user.signingkey "$signing_key"
    grep -qxF "$email $signing_key" "$HOME/.config/git/allowed_signers" || echo "$email $signing_key" >> "$HOME/.config/git/allowed_signers"
fi

echo "Git SSH signing is configured to use the 1Password SSH agent."
# git.sh [END]

# Rosetta
if [ "$(uname -m)" = "arm64" ]; then
    softwareupdate --install-rosetta --agree-to-license || true
fi

# node.sh [START]
echo "Installing dev runtimes with mise..."
# Install latest Node.js, Go, aube, and fnox; set global defaults
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
# node.sh [END]

# go.sh [START]
cd "$HOME"

echo "Install Go tools..."
go install golang.org/x/tools/gopls@latest
# go.sh [END]

# appstore.sh [START]
read -r -p "Hit [Enter] after you sign in to the App Store..."
echo "Installing App Store apps..."
app_store_apps=(
    "497799835|Xcode"
)

for app in "${app_store_apps[@]}"; do
    app_id="${app%%|*}"
    app_name="${app#*|}"
    install_mas_app "$app_id" "$app_name"
done
# appstore.sh [END]

# default-osx [START]
echo "Setup defaults..."

# Gatekeeper is intentionally left enabled. If you need to run an unsigned app,
# allow that app explicitly in System Settings instead of disabling Gatekeeper globally.

# Set system preferences
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 0
defaults write com.apple.keyboard.fnState -int 1
defaults write com.apple.mouse.scaling -float 1.5
defaults write com.apple.swipescrolldirection -int 1
defaults write com.apple.trackpad.forceClick -int 1
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Dock settings
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "dashboard-in-overlay" -int 1
defaults write com.apple.dock "expose-group-apps" -int 0
defaults write com.apple.dock "expose-group-by-app" -int 0
defaults write com.apple.dock largesize -int 96
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock tilesize -int 31

# Restart affected applications
killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

echo "System preferences have been updated"
# default-osx [END]

echo "Cleanup Homebrew..."
brew cleanup

echo "All Set!!!!!"
