FNM_USING_LOCAL_VERSION=0
autoload -U add-zsh-hook

_fnm_autoload_hook () {
  if [[ -f .nvmrc && -r .nvmrc || -f .node-version && -r .node-version ]]; then
    FNM_USING_LOCAL_VERSION=1
    fnm use --install-if-missing
  elif [ $FNM_USING_LOCAL_VERSION -eq 1 ]; then
    FNM_USING_LOCAL_VERSION=0
    fnm use default --install-if-missing
  fi
}

add-zsh-hook chpwd _fnm_autoload_hook && _fnm_autoload_hook
