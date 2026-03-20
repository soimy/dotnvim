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

run() {
  if [[ "${DOTNVIM_DRY_RUN:-0}" == "1" ]]; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  "$@"
}

run_shell() {
  if [[ "${DOTNVIM_DRY_RUN:-0}" == "1" ]]; then
    printf '[dry-run] %s\n' "$*"
    return 0
  fi
  bash -lc "$*"
}

sudo_run() {
  if [[ "${EUID}" -eq 0 ]]; then
    run "$@"
  elif command -v sudo >/dev/null 2>&1; then
    if [[ "${DOTNVIM_DRY_RUN:-0}" == "1" ]]; then
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
  if command -v fd >/dev/null 2>&1; then
    return 0
  fi
  if command -v fdfind >/dev/null 2>&1; then
    log "creating ~/.local/bin/fd symlink to fdfind"
    run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

ensure_tree_sitter_cli() {
  if command -v tree-sitter >/dev/null 2>&1; then
    return 0
  fi
  warn "tree-sitter CLI not found after package install, falling back to npm"
  install_npm_global tree-sitter-cli
}

ensure_npm_prefix() {
  local prefix
  prefix="$(npm config get prefix 2>/dev/null || true)"
  if [[ -n "$prefix" && -w "$prefix" ]]; then
    return 0
  fi
  log "configuring npm global prefix to ~/.local"
  run npm config set prefix "$HOME/.local"
}

install_npm_global() {
  ensure_npm_prefix
  run npm install -g "$@"
}

install_node_provider() {
  command -v npm >/dev/null 2>&1 || {
    warn "npm not found, skipping node provider install"
    return 0
  }
  log "installing Neovim node provider and Mermaid CLI"
  install_npm_global neovim @mermaid-js/mermaid-cli
}

install_python_provider() {
  command -v python3 >/dev/null 2>&1 || {
    warn "python3 not found, skipping python provider install"
    return 0
  }
  log "installing pynvim"
  if [[ "${DOTNVIM_DRY_RUN:-0}" == "1" ]]; then
    printf '[dry-run] python3 -m pip install --user --break-system-packages --upgrade pynvim\n'
    return 0
  fi
  if python3 -m pip install --help 2>/dev/null | grep -q -- '--break-system-packages'; then
    python3 -m pip install --user --break-system-packages --upgrade pynvim
  else
    python3 -m pip install --user --upgrade pynvim
  fi
}

sync_lazyvim() {
  command -v nvim >/dev/null 2>&1 || die "nvim not found after dependency install"
  log "syncing LazyVim plugins"
  if [[ "${DOTNVIM_DRY_RUN:-0}" == "1" ]]; then
    printf "[dry-run] nvim --headless '+Lazy! sync' '+qa'\n"
    return 0
  fi
  nvim --headless '+Lazy! sync' '+qa'
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
