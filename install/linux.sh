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
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise >/dev/null 2>&1; then
    curl https://mise.run | sh
fi
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
mkdir -p "$HOME/.config/zed/themes" "$HOME/.pi/agent"
ln -sfn "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
ln -sfn "$DOTFILES_DIR/zed/themes/better-itg-flat-dark.json" "$HOME/.config/zed/themes/better-itg-flat-dark.json"
ln -sfn "$DOTFILES_DIR/pi/settings.json" "$HOME/.pi/agent/settings.json"
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

echo "Configuring git..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
sort -u "$HOME/.ssh/known_hosts" -o "$HOME/.ssh/known_hosts" 2>/dev/null || true
chmod 600 "$HOME/.ssh/known_hosts" 2>/dev/null || true

touch "$HOME/.gitignore"
grep -qxF ".secrets.env" "$HOME/.gitignore" || echo ".secrets.env" >> "$HOME/.gitignore"
grep -qxF ".DS_Store" "$HOME/.gitignore" || echo ".DS_Store" >> "$HOME/.gitignore"

git_user_name="${DOTFILES_GIT_NAME:-$(git config --global user.name 2>/dev/null || true)}"
git_user_email="${DOTFILES_GIT_EMAIL:-$(git config --global user.email 2>/dev/null || true)}"
git config --global user.name "${git_user_name:-Developer}"
git config --global user.email "${git_user_email:-devbox@example.invalid}"
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

git config --global core.editor "nano"
git config --global core.excludesfile "$HOME/.gitignore"
git config --global core.whitespace -trailing-space

git config --global diff.mnemonicPrefix true
git config --global diff.renames true
git config --global diff.wordRegex .
git config --global diff.submodule log
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

if command -v gh >/dev/null 2>&1; then
    git config --global --unset-all credential.https://github.com.helper >/dev/null 2>&1 || true
    git config --global --add credential.https://github.com.helper ""
    git config --global --add credential.https://github.com.helper "!$(command -v gh) auth git-credential"
    git config --global --unset-all credential.https://gist.github.com.helper >/dev/null 2>&1 || true
    git config --global --add credential.https://gist.github.com.helper ""
    git config --global --add credential.https://gist.github.com.helper "!$(command -v gh) auth git-credential"
fi

# Enable SSH commit signing only when a public signing key has been explicitly
# provisioned on the VM. The private key should stay off-box, typically via
# forwarded 1Password SSH agent from the local machine.
if [ -f "$HOME/.config/git/signing_key.pub" ]; then
    mkdir -p "$HOME/.config/git"
    touch "$HOME/.config/git/allowed_signers"
    signing_key="$(cat "$HOME/.config/git/signing_key.pub")"
    git config --global gpg.format ssh
    git config --global user.signingkey "$signing_key"
    git config --global gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
    grep -qxF "$(git config --global user.email) $signing_key" "$HOME/.config/git/allowed_signers" 2>/dev/null || \
        echo "$(git config --global user.email) $signing_key" >> "$HOME/.config/git/allowed_signers"
    git config --global commit.gpgSign true
else
    git config --global commit.gpgSign false
fi

if command -v zsh >/dev/null 2>&1 && [ "${SHELL:-}" != "$(command -v zsh)" ]; then
    if [ -t 0 ]; then
        chsh -s "$(command -v zsh)" || echo "Could not change login shell; using ~/.bash_profile zsh handoff instead."
    else
        echo "Login shell is still ${SHELL:-unknown}; using ~/.bash_profile zsh handoff."
    fi

    for bash_startup in "$HOME/.bash_profile" "$HOME/.bashrc"; do
        if ! grep -q "dotfiles zsh handoff" "$bash_startup" 2>/dev/null; then
            cat >> "$bash_startup" <<'EOF'

# dotfiles zsh handoff
case $- in
    *i*)
        if [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
            exec zsh -l
        fi
        ;;
esac
EOF
        fi
    done
fi

echo "Linux devbox setup complete."
