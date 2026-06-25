---
name: create-exedev-project
description: >-
  Clone the user's base exe.dev VM into a disposable project VM, optionally
  clone or scaffold a project such as a Foundry/Forge Solidity repo, and open
  it in Cursor. Use when the user wants to start work in exe.dev or create a
  fresh cloud devbox for a task.
---

# exe.dev Project Workspace

## When to Use

Use this skill when the user wants to start a new task or project inside an
exe.dev VM cloned from their base devbox, for example:

- "open a new exe.dev project for this repo"
- "make me a disposable VM for a Foundry project"
- "clone this Solidity repo in exe.dev and open it"
- "scaffold a simple Forge contract project on exe.dev"

Do not use the base VM for project work. Create a disposable clone from the base
VM, set up the project there, then open it in Cursor over SSH.

## Required Local Helpers

The dotfiles provide these shell helpers in `terminal/functions.sh`:

- `exedev-cp <new-vm-name> [base-vm-name]`
- `exedev-cursor <vm-name> [path]`
- `devbase`
- `cursor-devbase`

The base VM name comes from either:

- `$EXEDEV_BASE_VM`
- `~/.config/dotfiles/exedev-base`

## Procedure

1. Clarify the desired workspace:
   - VM name, if the user has a preference.
   - Whether to clone an existing repository or scaffold a new project.
   - Project type, e.g. `foundry`, `node`, `go`, or generic.
   - Desired remote path, defaulting to `/home/exedev/<project-name>`.

2. Choose a safe VM name:
   - Prefer the user's requested name.
   - Otherwise derive a short lowercase name from the project/task, such as
     `forge-counter` or `bug-repro-auth`.
   - Avoid spaces and shell-special characters.

3. Clone the base VM from the local machine:

   ```bash
   exedev-cp <vm-name>
   ```

4. Wait briefly, then verify SSH works:

   ```bash
   ssh <vm-name>.exe.xyz 'echo ready'
   ```

5. Set up the project on the new VM.

   Existing repository:

   ```bash
   ssh <vm-name>.exe.xyz 'git clone <repo-url> <project-path>'
   ```

   New Foundry/Forge project:

   ```bash
   ssh <vm-name>.exe.xyz '
     mkdir -p <project-path> &&
     cd <project-path> &&
     forge init --no-commit
   '
   ```

   If the user's dotfiles alias/template is desired instead:

   ```bash
   ssh <vm-name>.exe.xyz '
     cd /home/exedev &&
     forge init <project-name> \
       --template https://github.com/giuseppecrj/foundry-bun &&
     cd <project-name> &&
     mise install
   '
   ```

6. Run project-specific bootstrap commands when appropriate:

   ```bash
   ssh <vm-name>.exe.xyz 'cd <project-path> && mise install'
   ssh <vm-name>.exe.xyz 'cd <project-path> && forge build'
   ```

   Only run commands that match the project type and user's intent.

7. Open the VM/project in Cursor from the local machine:

   ```bash
   exedev-cursor <vm-name> <project-path>
   ```

8. Report the VM name, path, and any commands run.

## Pitfalls

- Do not mutate the base VM for project-specific work.
- Do not copy secrets into disposable VMs unless the user explicitly requests it.
- Quote SSH commands carefully when paths or URLs contain special characters.
- If `exedev-cp` cannot find the base VM, ask the user to set
  `EXEDEV_BASE_VM` or write `~/.config/dotfiles/exedev-base`.
- Cursor remote URLs use the VS Code remote URI format:
  `vscode-remote://ssh-remote+<vm>.exe.xyz/path`.

## Verification

A setup is successful when:

- `ssh <vm-name>.exe.xyz 'echo ready'` succeeds.
- The requested project exists at the chosen remote path.
- For Foundry projects, `forge build` succeeds or any failure is reported.
- Cursor opens via `exedev-cursor <vm-name> <project-path>`.
