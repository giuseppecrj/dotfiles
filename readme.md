# dotfiles

## Install

```sh
cd ~
git clone https://github.com/giuseppecrj/dotfiles.git
cd ~/dotfiles
./install.sh
```

`install.sh` detects the OS and dispatches to:

- `install/macos.sh` on macOS
- `install/linux.sh` on Linux/cloud devboxes
