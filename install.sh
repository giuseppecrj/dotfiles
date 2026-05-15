#!/bin/bash
# Fresh Dev Setup OSX

echo "Setting up Mac..."

# xcode.sh [START]
echo "Install Xcode Dev Tools..."
xcode-select --install
read -p "Hit [Enter] to contine once Xcode Tools completes..."
sudo xcodebuild -license
# xcode.sh [END]

# git.sh [START]
echo "Getting user info from git..."
read -p "Enter Name: " full_name
read -p "Enter Email: " email

echo "Setting up git config..."
echo ".DS_Store\n.vscode\nnode_modules\n.secrets.env" >> ~/.gitignore
git config --global core.editor "code --wait"
git config --global core.excludesfile ~/.gitignore
git config --global core.whitespace -trailing-space

git config --global user.name $full_name
git config --global user.email $email

git config --global init.defaultBranch main

git config --global alias.ck "checkout"
git config --global alias.st "status"
# git.sh [END]

# dots.sh [START]

echo "Defaulting to zsh..."
chsh -s /bin/zsh

echo "Setup dotfiles..."
cd ~
git clone git@github.com:giuseppecrj/dotfiles.git
ln -s ~/dotfiles/env.sh ~/env.sh
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/hooks.sh ~/hooks.sh

# dots.sh [END]

# homebrew.sh [START]
echo "Installing Homebrew..."
if test !$(which brew); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Installing Oh-my-zsh..."
if [ ! -d "$ZSH" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "Updating Homebrew Repository..."
brew update

echo "Installing Tools with Homebrew..."
brew install yarn fnm zoxide spaceship

echo "Install Apps..."
brew install --cask 1password
brew install --cask 1password-cli

echo "Setting up 1Password CLI and SSH agent..."
echo "Please sign in to 1Password CLI if needed..."
op account add --address my.1password.com --email "$email" || true

# Keep private SSH keys inside 1Password. Do not export them to ~/.ssh.
# Enable the 1Password SSH agent in the 1Password app, then use it for Git SSH signing.
mkdir -p ~/dotfiles/bin ~/.config/git
chmod 755 ~/dotfiles/bin/git-ssh-sign-1password 2>/dev/null || true

git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global gpg.ssh.program "$HOME/dotfiles/bin/git-ssh-sign-1password"
git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
touch "$HOME/.config/git/allowed_signers"

echo "Git SSH signing is configured to use the 1Password SSH agent."
echo "Add your public signing key to ~/.config/git/allowed_signers if it is not present."

echo "Cleanup Homebrew..."
brew cleanup
# homebew.sh [END]

# Rosetta
softwareupdate --install-rosetta

# node.sh [START]
echo "Installing nodeJS..."
# Install current LTS versions
fnm install 20
fnm install 18
fnm alias 18 default
fnm alias 20 latest

# Add fnm shell integration
if ! grep -q "fnm" ~/.zshrc; then
    echo 'eval "$(fnm env --use-on-cd)"' >> ~/.zshrc
fi

source ~/.zshrc

echo "Setting up nodeJS environments..."
fnm use default
# node.sh [END]

# go.sh [START]
cd ~

echo "Install Go mods..."
go get golang.org/x/tools/gopls@latest

source ~/.zshrc
# go.sh [END]

# appstore.sh [START]
read -p "Hit [Enter] after you sign in to the App Store..."
echo "Installings Xcode..."
mas install 497799835 # Xcode
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
killall Finder
killall Dock

echo "System preferences have been updated"
# default-osx [END]

echo "All Set!!!!!"
