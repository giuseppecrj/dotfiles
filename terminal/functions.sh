# CUSTOM
# -----------------------
# Simple calculator
function calc() {
  local result=""
  result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')"
  #                       └─ default (when `--mathlib` is used) is 20
  #
  if [[ "$result" == *.* ]]; then
    # improve the output for decimal numbers
    printf '%s' "$result" |
    sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
        -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
        -e 's/0*$//;s/\.$//'   # remove trailing zeros
  else
    printf '%s' "$result"
  fi
  printf "\n"
}

# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$@"
}

function clone() {
  git clone "$1" "$2"
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')"
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh
  else
    local arg=-sh
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@"
  else
    du $arg .[^.]* *
  fi
}

# Use Git’s colored diff when available
hash git &>/dev/null
if [ $? -eq 0 ]; then
  function diff() {
    git diff --no-index --color-words "$@"
  }
fi

# Create a data URL from a file
function dataurl() {
  local mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Create a data URL from a file and copy it to the clipboard
function dataurlc() {
  dataurl "$1" | pbcopy
}

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  sleep 1 && open "http://localhost:8080/" &
  python3 -m http.server 8080
}

# Compare original and gzipped file size
function gz() {
  local origsize=$(wc -c < "$1")
  local gzipsize=$(gzip -c "$1" | wc -c)
  local ratio=$(echo "$gzipsize * 100/ $origsize" | bc -l)
  printf "orig: %d bytes\n" "$origsize"
  printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio"
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function json() {
  if [ -t 0 ]; then # argument
    python3 -mjson.tool --json-lines <<< "$*"
  else # pipe
    python3 -mjson.tool --json-lines
  fi
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
function tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

function tunnel() {
  if [ -z "$1" ]; then
    echo "Usage: tunnel <public-url-or-host>"
    return 1
  fi

  echo "Start tunnel for: $1"
}

function exedev-cp() {
  if [ -z "$1" ]; then
    echo "Usage: exedev-cp <new-vm-name> [base-vm-name]"
    echo "Example: exedev-cp my-feature"
    return 1
  fi

  local new_vm="$1"
  local base_vm="${2:-devbase}"

  ssh exe.dev "cp ${base_vm} ${new_vm}"
}

function exedev-cursor() {
  if [ -z "$1" ]; then
    echo "Usage: exedev-cursor <vm-name> [path]"
    echo "Example: exedev-cursor my-feature /home/exedev"
    return 1
  fi

  local vm_name="$1"
  local remote_path="${2:-/home/exedev}"

  cursor --remote "ssh-remote+${vm_name}.exe.xyz" "$remote_path"
}

function exedev-update-base() {
  ssh devbase 'cd ~/dotfiles && git pull --ff-only && ./install.sh'
}

function selectors() {
  if [ -z "$1" ]; then
    echo "Usage: selectors <ContractName>"
    echo "Example: selectors MembershipFacet"
    return 1
  fi

  local contract_name="$1"
  local json_path="out/${contract_name}.sol/${contract_name}.json"

  if [ ! -f "$json_path" ]; then
    echo "❌ Error: Contract artifact not found at: $json_path"
    echo "💡 Tip: Run 'forge build' first or check the contract name"
    return 1
  fi

  echo "📋 Function Selectors for ${contract_name}:\n"
  jq -r '.methodIdentifiers | to_entries[] | "\(.value) | \(.key)"' "$json_path" | sort | column -t -s "|"
}
