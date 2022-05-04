#!/bin/bash
# Fresh Dev Setup OSX

echo "Setting up Mac..."

# ssh.sh [START]

echo "Getting user info from git..."
read -p "Enter Name: " full_name
read -p "Enter Email: " email

echo "Creating SSH Key..."

ssh-keygen -t rsa -b 4096 -C $email

echo "Public Key Created ..."
echo "Adding public key to ssh-agent..."

eval "$(ssh-agent -s)"

f="ServerAliveInterval 5
ServerAliveCountMax 1
Host *
	IdentityFile ~/.ssh/id_rsa"

echo "$f" >> ~/.ssh/config

ssh-add -K ~/.ssh/id_rsa

cat ~/.ssh/id_rsa.pub | pbcopy

echo "SSH public key has been copied to clipboard"
echo "Paste this public key into Github settings"

open https://github.com/settings/keys

# ssh.sh [END]

# xcode.sh [START]
read -p "Hit [Enter] to continue once public key is added..."
echo "Install Xcode Dev Tools..."
xcode-select --install
read -p "Hit [Enter] to contine once Xcode Tools completes..."
sudo xcodebuild -license
# xcode.sh [END]

# git.sh [START]
echo "Setting up git config..."
echo ".DS_Store\n.vscode\nnode_modules" >> ~/.gitignore
git config --global core.excludesfile ~/.gitignore
git config --global user.name $full_name
git config --global user.email $email
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
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

# dots.sh [END]

# homebrew.sh [START]
echo "Installing Homebrew..."
if test !$(which brew); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

echo "Installing Oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
source ~/.zshrc

# installing spaceship theme [START]
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
# installing spaceship theme [END]

echo "Updating Homebrew Repository..."
brew update

echo "Installing Tools with Homebrew..."
brew install git-extras
brew install git-flow
brew install tree
brew install wget
brew install trash
brew install mas
brew install grep
brew install fnm
brew install go
brew install autojump
brew install rbenv
brew install pyenv
brew install spaceship

echo "Install Apps..."
brew install --cask alfred
brew install --cask docker
brew install --cask ledger-live
brew install --cask slack
brew install --cask spotify
brew install --cask brave-browser
brew install --cask github
brew install --cask 1password
brew install --cask google-drive
brew install --cask fig
brew install --cask remix-ide
brew install --cask ganache
brew install --cask discord
brew install --cask notion
brew install --cask remarkable
brew install --cask telegram

echo "Cleanup Homebrew..."
brew cleanup
# homebew.sh [END]

# Rosetta
softwareupdate --install-rosetta

# node.sh [START]
echo "Installing nodeJS..."
fnm install 16
fnm install 14
fnm alias 14 default
fnm alias 16 latest
source ~/.zshrc

echo "Setting up nodeJS environments..."
fnm use default
# ln -s /opt/homebrew/bin/code /opt/homebrew/bin/s
source ~/.zshrc
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

sudo spctl --master-disable
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 0
defaults write com.apple.keyboard.fnState -int 1
defaults write com.apple.mouse.scaling -float 1.5
defaults write com.apple.swipescrolldirection -int 1
defaults write com.apple.trackpad.forceClick -int 1
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock "dashboard-in-overlay" -int 1
defaults write com.apple.dock "expose-group-apps" -int 0
defaults write com.apple.dock "expose-group-by-app" -int 0
defaults write com.apple.dock largesize -int 96
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock tilesize -int 31
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock mineffect -string "scale"

killall Finder
# default-osx [END]

echo "All Set!!!!!"
