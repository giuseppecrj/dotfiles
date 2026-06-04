# AGENTS.md

Guidance for AI coding agents working in this dotfiles repo.

## Project shape

This repo manages personal macOS and Linux/cloud-dev shell setup and bootstrap scripts.

Key files:

- `.zshrc` — intentionally tiny shell entrypoint. Keep it minimal.
- `env.sh` — main sectioned shell startup/config file.
- `terminal/aliases.sh` — shell aliases only.
- `terminal/functions.sh` — shell functions only.
- `terminal/prompt.sh` — prompt-related overrides only.
- `terminal/tools.sh` — executable tool initializers and shell integrations.
- `install.sh` — small OS dispatcher.
- `install/macos.sh` — macOS/laptop bootstrap installer.
- `install/linux.sh` — Linux/cloud-dev bootstrap installer, suitable for exe.dev-style VMs.
- `bin/` — helper executables.
- `fonts/` — font assets installed by `install.sh`.

## Shell config conventions

Keep `.zshrc` clean. It should only source the main config:

```zsh
#!/bin/zsh
source "$HOME/env.sh"
```

Use `env.sh` as the main readable config file with explicit comment sections. Do not split it further unless there is a strong reason.

Expected `env.sh` responsibilities:

- static environment exports
- OS-specific guarded environment exports, such as macOS Homebrew variables
- PATH setup
- completion path setup that must happen before oh-my-zsh/compinit
- oh-my-zsh theme/plugin setup
- explicit sourcing of files in `terminal/`
- optional local files such as secrets/cargo env

Keep these separate:

- aliases go in `terminal/aliases.sh`
- functions go in `terminal/functions.sh`
- prompt overrides go in `terminal/prompt.sh`
- tool startup hooks go in `terminal/tools.sh`

Do not reintroduce `hooks.sh`; its previous contents belong in `terminal/tools.sh`.

## Tool initializer conventions

Put executable shell integrations in `terminal/tools.sh`, for example:

- `mise activate`
- `fnox activate`
- `fzf --zsh`
- `zoxide init`
- bun completions
- CLI completion functions

Guard each integration with `command -v ... >/dev/null` or file-exists checks so shell startup does not fail when a tool is missing.

## Install script conventions

`install.sh` should stay a tiny dispatcher. Put OS-specific behavior in:

- `install/macos.sh` for macOS-only setup: Homebrew casks, Xcode, App Store, macOS defaults, `/Applications`, `~/Library/Fonts`.
- `install/linux.sh` for Linux/cloud-dev setup: apt packages, mise runtimes, Linux font path, zsh setup.

Installers should be idempotent where practical:

- use helper functions like `install_formula`, `install_cask`, or `install_apt_package`
- avoid failing when optional setup is already complete
- keep symlink setup aligned with current file structure
- do not link removed files such as `hooks.sh`

When changing shell files, update the relevant OS installer if symlinks or installed dependencies change.

## Removed/undesired items

Terminal-emulator-specific setup has intentionally been removed. Do not add app-specific terminal paths, casks, or editor settings unless explicitly requested.

Avoid adding editor-specific assumptions unless the user asks. Existing aliases may use `code`, but do not expand editor coupling without confirmation.

## Validation before finishing

After shell/bootstrap changes, run:

```bash
bash -n install.sh install/macos.sh install/linux.sh
zsh -n .zshrc env.sh terminal/aliases.sh terminal/functions.sh terminal/prompt.sh terminal/tools.sh
```

If removing app-specific setup, also search the repo for that app name excluding `.git/`.

Also check:

```bash
git status --short
git diff --check
```

## Git notes

The user may ask to commit and push. Before doing so, inspect status and ensure all intended files are staged. Use clear commit messages describing dotfile structure or shell setup changes.
