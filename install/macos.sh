#!/bin/bash
# Fresh Dev Setup macOS

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZSH_DIR="${ZSH:-$HOME/.oh-my-zsh}"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH_DIR/custom}"
CHECK_ONLY=0

usage() {
	cat <<'EOF'
Usage: install/macos.sh [--check|--dry-run]

Options:
  --check, --dry-run, -n   Report what this installer would change, then exit.
  --help, -h              Show this help.
EOF
}

while [ "$#" -gt 0 ]; do
	case "$1" in
	--check | --dry-run | -n)
		CHECK_ONLY=1
		;;
	--help | -h)
		usage
		exit 0
		;;
	*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 2
		;;
	esac
	shift
done

formulae=(
	age
	ffmpeg
	gh
	just
	lcov
	mas
	mise
	mole
	pkl
	ripgrep
	tree
	yq
	zoxide
)

casks=(
	"1password|1Password"
	"1password-cli|"
	"docker|Docker"
	"tailscale|Tailscale"
	"thebrowsercompany-dia|Dia"
	"cursor|Cursor"
)

app_store_apps=(
	"497799835|Xcode"
)

npm_globals=(
	@atlas.labs/pi-goal
	@earendil-works/pi-coding-agent
	@fission-ai/openspec
	agent-browser
)

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

install_npm_global() {
	local package="$1"

	if npm list -g "$package" --depth=0 >/dev/null 2>&1; then
		echo "Global npm package already installed: $package"
	else
		npm install -g "$package"
	fi
}

all_mas_apps_installed() {
	local app app_name

	for app in "${app_store_apps[@]}"; do
		app_name="${app#*|}"
		if [ ! -d "/Applications/$app_name.app" ]; then
			return 1
		fi
	done

	return 0
}

check_link() {
	local target="$1"
	local source="$2"

	if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
		echo "OK link: $target -> $source"
	elif [ -e "$target" ] || [ -L "$target" ]; then
		echo "WOULD BACK UP AND REPLACE: $target -> $source"
	else
		echo "WOULD CREATE LINK: $target -> $source"
	fi
}

link_file() {
	local source="$1"
	local target="$2"

	mkdir -p "$(dirname "$target")"
	if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
		echo "Link already correct: $target -> $source"
		return
	fi
	if [ -e "$target" ] || [ -L "$target" ]; then
		local backup
		backup="$target.backup.$(date +%Y%m%d%H%M%S)"
		mv "$target" "$backup"
		echo "Backed up existing path: $target -> $backup"
	fi
	ln -s "$source" "$target"
}

check_macos_install() {
	echo "macOS installer check only. No changes will be made."
	echo

	echo "== System =="
	if xcode-select -p >/dev/null 2>&1; then
		echo "OK Xcode Command Line Tools: $(xcode-select -p)"
	else
		echo "WOULD PROMPT to install Xcode Command Line Tools"
	fi
	if [ "${SHELL:-}" = "/bin/zsh" ]; then
		echo "OK default shell: /bin/zsh"
	else
		echo "WOULD CHANGE default shell to /bin/zsh (current: ${SHELL:-unknown})"
	fi
	echo

	echo "== Homebrew =="
	if command -v brew >/dev/null 2>&1; then
		echo "OK Homebrew: $(command -v brew)"
		echo "WOULD RUN: brew update"
		for formula in "${formulae[@]}"; do
			if brew list --formula "$formula" >/dev/null 2>&1; then
				echo "OK formula: $formula"
			else
				echo "WOULD INSTALL formula: $formula"
			fi
		done
		for cask_entry in "${casks[@]}"; do
			local cask="${cask_entry%%|*}"
			local app_name="${cask_entry#*|}"
			if brew list --cask "$cask" >/dev/null 2>&1; then
				echo "OK cask: $cask"
			elif [ -n "$app_name" ] && [ -d "/Applications/$app_name.app" ]; then
				echo "OK app present outside Homebrew, would skip cask: $cask (/Applications/$app_name.app)"
			else
				echo "WOULD INSTALL cask: $cask"
			fi
		done
		echo "WOULD RUN: brew cleanup"
	else
		echo "WOULD INSTALL Homebrew, then install all configured formulae/casks"
	fi
	echo

	echo "== Dotfile links and files =="
	if [ ! -d "$HOME/dotfiles/.git" ]; then
		echo "WOULD CLONE dotfiles to $HOME/dotfiles"
	else
		echo "OK dotfiles clone: $HOME/dotfiles"
	fi
	check_link "$HOME/env.sh" "$DOTFILES_DIR/env.sh"
	check_link "$HOME/.zshrc" "$DOTFILES_DIR/.zshrc"
	check_link "$HOME/.pi/agent/settings.json" "$DOTFILES_DIR/pi/settings.json"
	if [ -L "$HOME/hooks.sh" ]; then
		echo "WOULD REMOVE old hooks symlink: $HOME/hooks.sh"
	elif [ -e "$HOME/hooks.sh" ]; then
		echo "WOULD LEAVE existing non-symlink in place: $HOME/hooks.sh"
	fi
	echo "WOULD COPY fonts/*.ttf to $HOME/Library/Fonts/"
	echo

	echo "== Shell, git, runtimes, and macOS defaults =="
	if [ -d "$ZSH_DIR" ]; then
		echo "OK oh-my-zsh directory: $ZSH_DIR"
	else
		echo "WOULD INSTALL oh-my-zsh into: $ZSH_DIR"
	fi
	if [ -d "$ZSH_CUSTOM_DIR/themes/spaceship-prompt/.git" ]; then
		echo "WOULD UPDATE Spaceship prompt theme"
	else
		echo "WOULD CLONE Spaceship prompt theme"
	fi
	local existing_name existing_email existing_signing_key
	existing_name="$(git config --global user.name 2>/dev/null || true)"
	existing_email="$(git config --global user.email 2>/dev/null || true)"
	existing_signing_key="$(git config --global user.signingkey 2>/dev/null || true)"
	if [ -n "$existing_name" ] && [ -n "$existing_email" ]; then
		echo "OK git identity exists: $existing_name <$existing_email>"
	else
		echo "WOULD PROMPT for missing git user.name/user.email"
	fi
	if [ -n "$existing_signing_key" ]; then
		echo "OK git SSH signing key exists"
	else
		echo "WOULD PROMPT for missing SSH signing public key (optional)"
	fi
	echo "WOULD UPDATE global git aliases, signing, credentials, and defaults"
	if command -v op >/dev/null 2>&1 && op account list 2>/dev/null | grep -q 'my\.1password\.com'; then
		echo "OK 1Password CLI account already configured"
	else
		echo "WOULD CONFIGURE 1Password CLI account"
	fi
	echo "WOULD CONFIGURE Git SSH signing"
	echo "WOULD ENSURE mise runtimes: node, go, bun, aube, fnox"
	if command -v mise >/dev/null 2>&1; then
		eval "$(mise activate bash)"
	fi
	for package in "${npm_globals[@]}"; do
		if npm list -g "$package" --depth=0 >/dev/null 2>&1; then
			echo "OK global npm package: $package"
		else
			echo "WOULD INSTALL global npm package: $package"
		fi
	done
	if command -v corepack >/dev/null 2>&1; then
		echo "OK corepack available; would enable it"
	else
		echo "WARN corepack not found after Node install"
	fi
	if command -v gopls >/dev/null 2>&1; then
		echo "OK Go tool: gopls"
	else
		echo "WOULD INSTALL Go tool: golang.org/x/tools/gopls@latest"
	fi
	if all_mas_apps_installed; then
		echo "OK all App Store apps installed; no App Store prompt needed"
	else
		echo "WOULD PROMPT for App Store sign-in, then ensure App Store apps:"
		for app in "${app_store_apps[@]}"; do
			local app_id="${app%%|*}"
			local app_name="${app#*|}"
			if [ -d "/Applications/$app_name.app" ]; then
				echo "OK App Store app: $app_name"
			else
				echo "WOULD INSTALL App Store app: $app_name ($app_id)"
			fi
		done
	fi
	echo "WOULD WRITE macOS defaults for dark mode, keyboard, mouse/trackpad, and Dock"
	echo "WOULD RESTART Finder and Dock"
}

if [ "$CHECK_ONLY" -eq 1 ]; then
	check_macos_install
	exit 0
fi

echo "Setting up Mac..."

# xcode.sh [START]
echo "Install Xcode Command Line Tools..."
if ! xcode-select -p >/dev/null 2>&1; then
	xcode-select --install || true
	read -r -p "Hit [Enter] to continue once Xcode Command Line Tools completes..."
fi

if xcodebuild -version >/dev/null 2>&1 && ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
	sudo xcodebuild -license accept || true
fi
# xcode.sh [END]

# homebrew.sh [START]
echo "Installing Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
	homebrew_installer="$(mktemp)"
	curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$homebrew_installer"
	/bin/bash "$homebrew_installer"
	rm -f "$homebrew_installer"
fi

if [ -x /opt/homebrew/bin/brew ]; then
	eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
	eval "$(/usr/local/bin/brew shellenv)"
fi

echo "Updating Homebrew Repository..."
brew update

echo "Installing CLI tools with Homebrew..."
for formula in "${formulae[@]}"; do
	install_formula "$formula"
done

echo "Install Apps..."
for cask_entry in "${casks[@]}"; do
	cask="${cask_entry%%|*}"
	app_name="${cask_entry#*|}"
	install_cask "$cask" "$app_name"
done
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

link_file "$DOTFILES_DIR/env.sh" "$HOME/env.sh"
link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
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
if [ -n "$existing_name" ]; then
	full_name="$existing_name"
	echo "Using existing git user.name: $full_name"
else
	full_name="$(prompt_with_default "Enter Name" "")"
	while [ -z "$full_name" ]; do
		full_name="$(prompt_with_default "Enter Name" "")"
	done
fi

if [ -n "$existing_email" ]; then
	email="$existing_email"
	echo "Using existing git user.email: $email"
else
	email="$(prompt_with_default "Enter Email" "")"
	while [ -z "$email" ]; do
		email="$(prompt_with_default "Enter Email" "")"
	done
fi

echo "Setting up git config..."
touch "$HOME/.gitignore"
grep -qxF ".secrets.env" "$HOME/.gitignore" || echo ".secrets.env" >>"$HOME/.gitignore"

git config --global color.ui auto
git config --global init.defaultBranch main

git config --global alias.done "!f() { BRANCH=\$(git branch --show-current); git checkout main && git pull && git branch -d \$BRANCH; }; f"
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
git config --global pull.rebase merges
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
if op account list 2>/dev/null | grep -q 'my\.1password\.com'; then
	echo "1Password CLI account already configured."
else
	echo "Please sign in to 1Password CLI if needed..."
	op account add --address my.1password.com --email "$email" || true
fi

# Keep private SSH keys inside 1Password. Do not export them to ~/.ssh.
# Use 1Password's official Git SSH signing binary and record the allowed signer.
allowed_signers_file="$HOME/.config/git/allowed_ssh_signers"
mkdir -p "$HOME/.config/git"

git config --global gpg.format ssh
git config --global commit.gpgsign true
git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
git config --global gpg.ssh.allowedSignersFile "$allowed_signers_file"
touch "$allowed_signers_file"

existing_signing_key="$(git config --global user.signingkey 2>/dev/null || true)"
if [ -n "$existing_signing_key" ]; then
	signing_key="$existing_signing_key"
	echo "Using existing git SSH signing key"
else
	signing_key="$(prompt_with_default "Enter SSH signing public key (optional)" "")"
fi
if [ -n "$signing_key" ]; then
	git config --global user.signingkey "$signing_key"
	grep -qxF "$email $signing_key" "$allowed_signers_file" || echo "$email $signing_key" >>"$allowed_signers_file"
fi

echo "Git SSH signing is configured to use the 1Password SSH agent."
# git.sh [END]

# Rosetta
if [ "$(uname -m)" = "arm64" ]; then
	if [ -e /Library/Apple/usr/libexec/oah ]; then
		echo "Rosetta already installed."
	else
		softwareupdate --install-rosetta --agree-to-license || true
	fi
fi

# node.sh [START]
echo "Installing dev runtimes with mise..."
# Install latest Node.js, Go, aube, and fnox; set global defaults
mise install node@latest go@latest bun@latest aube@latest fnox@latest
mise use -g node@latest go@latest bun@latest aube@latest fnox@latest
eval "$(mise activate bash)"

echo "Installing global npm tools..."
for package in "${npm_globals[@]}"; do
	install_npm_global "$package"
done
if command -v corepack >/dev/null 2>&1; then
	corepack enable || true
fi
# node.sh [END]

# go.sh [START]
cd "$HOME"

echo "Install Go tools..."
if command -v gopls >/dev/null 2>&1; then
	echo "Go tool already installed: gopls"
else
	go install golang.org/x/tools/gopls@latest
fi
# go.sh [END]

# appstore.sh [START]
if all_mas_apps_installed; then
	echo "All App Store apps already installed; skipping App Store sign-in prompt."
else
	read -r -p "Hit [Enter] after you sign in to the App Store..."
	echo "Installing App Store apps..."
	for app in "${app_store_apps[@]}"; do
		app_id="${app%%|*}"
		app_name="${app#*|}"
		install_mas_app "$app_id" "$app_name"
	done
fi
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
