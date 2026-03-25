#!/usr/bin/env bash

set -euo pipefail

log() {
  printf '[dotnvim] %s\n' "$*"
}

warn() {
  printf '[dotnvim][warn] %s\n' "$*" >&2
}

die() {
  printf '[dotnvim][error] %s\n' "$*" >&2
  exit 1
}

is_dry_run() {
  [[ "${DOTNVIM_DRY_RUN:-0}" == "1" ]]
}

run() {
  if is_dry_run; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  "$@"
}

run_shell() {
  if is_dry_run; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  bash -lc "$*"
}

sudo_run() {
  if [[ "${EUID}" -eq 0 ]]; then
    run "$@"
  elif command -v sudo >/dev/null 2>&1; then
    if is_dry_run; then
      printf '[dry-run] sudo %s\n' "$*"
      return 0
    fi
    sudo "$@"
  else
    die "sudo is required to install system packages"
  fi
}

ensure_repo_root() {
  [[ -f "${DOTNVIM_ROOT}/init.lua" ]] || die "bootstrap.sh must be run from the dotnvim repository"
}

ensure_local_bin_on_path() {
  mkdir -p "$HOME/.local/bin"
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
  esac
}

ensure_fd_alias() {
  if is_dry_run; then
    return 0
  fi
  if command -v fd >/dev/null 2>&1; then
    return 0
  fi
  if command -v fdfind >/dev/null 2>&1; then
    log "creating ~/.local/bin/fd symlink to fdfind"
    run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

ensure_tree_sitter_cli() {
  if [[ "${DOTNVIM_PACKAGE_MANAGER:-}" == "apt" ]]; then
    log "installing tree-sitter CLI via npm on apt-based systems"
    install_npm_global tree-sitter-cli
    return 0
  fi
  if is_dry_run; then
    return 0
  fi
  if command -v tree-sitter >/dev/null 2>&1; then
    return 0
  fi
  warn "tree-sitter CLI not found after package install, falling back to npm"
  install_npm_global tree-sitter-cli
}

ensure_node_runtime() {
  if [[ "${DOTNVIM_PACKAGE_MANAGER:-}" != "apt" ]]; then
    return 0
  fi

  if [[ "${DOTNVIM_NODE_RUNTIME_READY:-0}" == "1" ]]; then
    return 0
  fi

  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"

  if is_dry_run; then
    log "activating latest Node.js via nvm on apt-based systems"
    printf '[dry-run] sanitize ~/.npmrc for nvm\n'
    printf '[dry-run] export NVM_DIR=%s\n' "$nvm_dir"
    printf '[dry-run] . %s/nvm.sh\n' "$nvm_dir"
    printf '[dry-run] npm config delete prefix\n'
    printf '[dry-run] npm config delete globalconfig\n'
    printf '[dry-run] nvm install node\n'
    printf '[dry-run] nvm alias default node\n'
    printf '[dry-run] nvm use --delete-prefix node\n'
    export DOTNVIM_NODE_RUNTIME_READY=1
    return 0
  fi

  local npmrc="$HOME/.npmrc"
  if [[ -f "$npmrc" ]] && grep -Eq '^(prefix|globalconfig)=' "$npmrc"; then
    log "removing npm prefix settings that conflict with nvm"
    local sanitized_npmrc
    sanitized_npmrc="$(mktemp)"
    grep -Ev '^(prefix|globalconfig)=' "$npmrc" >"$sanitized_npmrc" || true
    if [[ -s "$sanitized_npmrc" ]]; then
      mv "$sanitized_npmrc" "$npmrc"
    else
      rm -f "$npmrc" "$sanitized_npmrc"
    fi
  fi

  [[ -s "$nvm_dir/nvm.sh" ]] || die "nvm is required on Ubuntu/Debian; expected $nvm_dir/nvm.sh"

  # shellcheck source=/dev/null
  . "$nvm_dir/nvm.sh"
  command -v nvm >/dev/null 2>&1 || die "failed to load nvm from $nvm_dir/nvm.sh"

  log "activating latest Node.js via nvm on apt-based systems"
  npm config delete prefix >/dev/null 2>&1 || true
  npm config delete globalconfig >/dev/null 2>&1 || true
  nvm install node
  nvm alias default node
  nvm use --delete-prefix node

  command -v npm >/dev/null 2>&1 || die "npm not found after activating Node.js via nvm"
  export DOTNVIM_NODE_RUNTIME_READY=1
}

ensure_npm_prefix() {
  ensure_node_runtime
  if [[ "${DOTNVIM_PACKAGE_MANAGER:-}" == "apt" ]]; then
    return 0
  fi
  if is_dry_run; then
    log "configuring npm global prefix to ~/.local"
    printf '[dry-run] npm config set prefix %s\n' "$HOME/.local"
    return 0
  fi
  local prefix
  prefix="$(npm config get prefix 2>/dev/null || true)"
  if [[ -n "$prefix" && -w "$prefix" ]]; then
    return 0
  fi
  log "configuring npm global prefix to ~/.local"
  run npm config set prefix "$HOME/.local"
}

install_npm_global() {
  if is_dry_run; then
    ensure_npm_prefix
    printf '[dry-run] npm install -g %s\n' "$*"
    return 0
  fi
  ensure_npm_prefix
  run npm install -g "$@"
}

install_node_provider() {
  ensure_node_runtime
  if is_dry_run; then
    log "installing Neovim node provider and Mermaid CLI"
    install_npm_global neovim @mermaid-js/mermaid-cli
    return 0
  fi
  command -v npm >/dev/null 2>&1 || {
    warn "npm not found, skipping node provider install"
    return 0
  }
  log "installing Neovim node provider and Mermaid CLI"
  install_npm_global neovim @mermaid-js/mermaid-cli
}

install_python_provider() {
  if is_dry_run; then
    log "installing pynvim"
    printf '[dry-run] python3 -m pip install --user --break-system-packages --upgrade pynvim\n'
    return 0
  fi
  command -v python3 >/dev/null 2>&1 || {
    warn "python3 not found, skipping python provider install"
    return 0
  }
  log "installing pynvim"
  if python3 -m pip install --help 2>/dev/null | grep -q -- '--break-system-packages'; then
    python3 -m pip install --user --break-system-packages --upgrade pynvim
  else
    python3 -m pip install --user --upgrade pynvim
  fi
}

nvim_bootstrap_args() {
  printf 'env XDG_CONFIG_HOME=%q NVIM_APPNAME=%q nvim' "$(dirname "$DOTNVIM_ROOT")" "$(basename "$DOTNVIM_ROOT")"
}

sync_lazyvim() {
  if is_dry_run; then
    log "syncing LazyVim plugins"
    printf "[dry-run] %s --headless '+Lazy! sync' '+qa'\n" "$(nvim_bootstrap_args)"
    printf "[dry-run] %s --headless \"+lua require('config.bootstrap').mason_sync()\" '+qa'\n" "$(nvim_bootstrap_args)"
    return 0
  fi
  command -v nvim >/dev/null 2>&1 || die "nvim not found after dependency install"
  log "syncing LazyVim plugins"
  env XDG_CONFIG_HOME="$(dirname "$DOTNVIM_ROOT")" NVIM_APPNAME="$(basename "$DOTNVIM_ROOT")" \
    nvim --headless '+Lazy! sync' '+qa'
  log "waiting for Mason tools to finish installing"
  env XDG_CONFIG_HOME="$(dirname "$DOTNVIM_ROOT")" NVIM_APPNAME="$(basename "$DOTNVIM_ROOT")" \
    nvim --headless "+lua require('config.bootstrap').mason_sync()" '+qa'
}

install_optional_pkg() {
  local manager="$1"
  local package="$2"
  case "$manager" in
    brew)
      run brew install "$package" || warn "failed to install optional package: $package"
      ;;
    apt)
      sudo_run apt-get install -y "$package" || warn "failed to install optional package: $package"
      ;;
    pacman)
      sudo_run pacman -Sy --needed --noconfirm "$package" || warn "failed to install optional package: $package"
      ;;
    dnf)
      sudo_run dnf install -y "$package" || warn "failed to install optional package: $package"
      ;;
    *)
      warn "unknown optional package manager: $manager"
      ;;
  esac
}
