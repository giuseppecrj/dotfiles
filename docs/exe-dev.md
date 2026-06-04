# exe.dev workflow

This repo supports exe.dev as the default cloud development workflow.

## Mental model

- The base VM is the golden exe.dev VM.
- `devbase` is the local SSH alias for that VM.
- New development VMs should be cloned from the base VM with exe.dev `cp`.
- Do real project work in disposable clones, not in the base VM.
- Keep production VMs separate from personal/dev VMs.

```text
<base-vm>
  ├── project-feature-a
  ├── bug-repro-b
  └── agent-task-c
```

## Connect to the base devbox

SSH alias expected on the local machine:

```sshconfig
Host devbase
  HostName <base-vm>.exe.xyz
  User exedev
```

Then connect with:

```sh
ssh devbase
```

Or use the shell alias:

```sh
devbase
```

## Open the base devbox in Cursor

```sh
cursor --remote ssh-remote+devbase /home/exedev
```

Or use the shell alias:

```sh
cursor-devbase
```

## Create a new devbox from the base

Preferred flow:

```sh
ssh exe.dev 'cp <base-vm> my-feature'
ssh my-feature.exe.xyz
```

Configure the base VM name locally once:

```sh
mkdir -p ~/.config/dotfiles
echo '<base-vm>' > ~/.config/dotfiles/exedev-base
```

With dotfile helper:

```sh
exedev-cp my-feature
ssh my-feature.exe.xyz
```

Open clone in Cursor:

```sh
exedev-cursor my-feature
```

Optional path argument:

```sh
exedev-cursor my-feature /home/exedev/my-project
```

## Update the base devbox

Run from local machine:

```sh
exedev-update-base
```

Equivalent manual flow:

```sh
ssh devbase
cd ~/dotfiles
git pull --ff-only
./install.sh
```

After updating the base VM, future clones inherit the updated setup.

## Fresh VM bootstrap

Use this only when rebuilding from scratch instead of cloning from the base:

```sh
ssh exe.dev 'new --name my-devbox --image exeuntu --disk 50GB'
ssh my-devbox.exe.xyz
```

Inside the VM:

```sh
git clone https://github.com/giuseppecrj/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Then reconnect:

```sh
ssh my-devbox.exe.xyz
```

## GitHub integrations

exe.dev GitHub integrations are configured outside the VM via exe.dev. They are useful for private repos because tokens do not live on the VM.

Setup starts with:

```sh
ssh exe.dev 'integrations setup github'
```

After browser setup, create per-repo integrations, for example:

```sh
ssh exe.dev 'integrations add github --name myrepo --repository owner/myrepo --attach vm:<base-vm>'
```

Prefer tag-based integrations when many cloned VMs need the same repo access.

## Git commit signing

Linux devboxes can sign commits with your local 1Password SSH key via SSH agent forwarding.

Local SSH config should enable forwarding for trusted named devboxes only:

```sshconfig
Host devbase
  HostName <base-vm>.exe.xyz
  User exedev
  ForwardAgent yes
```

On the VM, `install/linux.sh` enables Git SSH signing only when this file exists:

```text
~/.config/git/signing_key.pub
```

That file contains the public signing key only. The private key stays on the local machine in 1Password. Signing works only while connected with agent forwarding.

Check forwarding:

```sh
ssh devbase 'echo $SSH_AUTH_SOCK && ssh-add -L'
```

Do not enable agent forwarding or personal signing keys on production VMs.

## AI/Pi login

Pi is installed by the Linux installer.

To authenticate Pi on a devbox:

```sh
pi
/login
```

If Pi auth is stored on the base VM, cloned VMs inherit it. That is convenient for personal dev clones, but do not copy personal AI auth into production VMs.

## Dev vs production

Recommended separation:

- Dev: clone from the base VM, code directly over SSH/Cursor, use `mise` tooling.
- Test/prototype: clone disposable VMs from the base VM.
- Production: use separate prod VMs, preferably Docker/Compose plus systemd and exe.dev HTTPS/custom domains.

Do not use the base devbox for production.

Future production base idea:

```text
prod-base
  ├── docker / compose
  ├── systemd services
  ├── no personal Pi OAuth
  └── secrets via exe.dev integrations
```

## Cleanup

List VMs:

```sh
ssh exe.dev 'ls'
```

Remove a disposable VM:

```sh
ssh exe.dev 'rm my-feature'
```

Keep the base VM unless intentionally rebuilding it.
