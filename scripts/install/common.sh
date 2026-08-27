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
    if ! sudo "$@"; then
      warn "sudo command failed: $*"
      warn "  - if this ran without an interactive terminal, sudo could not prompt for a password;"
      warn "    run bootstrap.sh in a normal terminal or grant passwordless sudo for package installs."
      warn "  - otherwise the package manager command itself errored; re-run it manually to see details."
      return 1
    fi
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
  # Fish cannot source nvm.sh (bash-only syntax). Detect a fish environment and
  # manage the Node runtime with fnm instead — installing and wiring it up if needed.
  if is_fish_env; then
    ensure_fish_fnm
    return 0
  fi

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
    export DOTNVIM_NODE_MANAGED=1
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
  export DOTNVIM_NODE_MANAGED=1
}

is_fish_env() {
  command -v fish >/dev/null 2>&1 || return 1
  if [[ -f "$HOME/.config/fish/config.fish" || -d "$HOME/.config/fish/conf.d" ]]; then
    return 0
  fi
  case "${SHELL-}" in
    *fish) return 0 ;;
  esac
  return 1
}

install_fnm() {
  if [[ "$(uname -s)" == "Darwin" ]] && command -v brew >/dev/null 2>&1; then
    log "installing fnm via Homebrew"
    run brew install fnm
    return 0
  fi

  local fnm_zip
  case "$(uname -s)" in
    Darwin)
      fnm_zip="fnm-macos.zip"
      ;;
    Linux)
      fnm_zip="fnm-linux.zip"
      case "$(uname -m)" in
        aarch* | armv8*) fnm_zip="fnm-arm64.zip" ;;
        arm | armv7*) fnm_zip="fnm-arm32.zip" ;;
      esac
      ;;
    *)
      die "unsupported platform for fnm install: $(uname -s)"
      ;;
  esac

  local fnm_base="https://github.com/Schniz/fnm/releases/latest/download"
  if is_dry_run; then
    printf '[dry-run] install fnm from %s/%s -> %s\n' "$fnm_base" "$fnm_zip" "$HOME/.local/bin/fnm"
    return 0
  fi

  log "downloading fnm binary from GitHub releases"
  local tmp
  tmp="$(mktemp -d)"
  if ! curl -fsSL --retry 3 "$fnm_base/$fnm_zip" -o "$tmp/fnm.zip"; then
    rm -rf "$tmp"
    die "failed to download fnm from $fnm_base/$fnm_zip"
  fi
  unzip -oq "$tmp/fnm.zip" -d "$tmp"
  if [[ ! -f "$tmp/fnm" ]]; then
    mv "$tmp/${fnm_zip%.zip}/fnm" "$tmp/fnm"
  fi
  mkdir -p "$HOME/.local/bin"
  cp "$tmp/fnm" "$HOME/.local/bin/fnm"
  chmod 0755 "$HOME/.local/bin/fnm"
  rm -rf "$tmp"
  command -v fnm >/dev/null 2>&1 || die "fnm not found in PATH after install (expected $HOME/.local/bin/fnm)"
}

configure_fish_fnm() {
  local fish_conf_dir="$HOME/.config/fish/conf.d"
  local fish_conf_file="$fish_conf_dir/fnm.fish"
  local fish_cfg="$HOME/.config/fish/config.fish"

  if is_dry_run; then
    printf '[dry-run] write fish fnm config to %s\n' "$fish_conf_file"
    printf '[dry-run] disable nvm sourcing in %s\n' "$fish_cfg"
    return 0
  fi

  mkdir -p "$fish_conf_dir"
  if [[ ! -f "$fish_conf_file" ]] || ! grep -q 'dotnvim' "$fish_conf_file"; then
    cat >"$fish_conf_file" <<EOF
# managed by dotnvim bootstrap
# nvm is not fish-compatible; fnm replaces it in fish environments.
fish_add_path $HOME/.local/bin
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end
EOF
    log "wrote $fish_conf_file"
  fi

  if [[ -f "$fish_cfg" ]] && grep -qE '^[[:space:]]*(source|\.)[[:space:]]+.*(init-nvm\.sh|nvm\.sh)' "$fish_cfg"; then
    sed -i.bak -E 's@^([[:space:]]*(source|\.)[[:space:]]+.*(init-nvm\.sh|nvm\.sh)[[:space:]]*)$@# dotnvim: nvm is not fish-compatible, replaced by fnm (see conf.d/fnm.fish) # \1@' "$fish_cfg"
    log "disabled nvm sourcing in $fish_cfg (backup saved as $fish_cfg.bak); fnm provides Node in fish"
  fi
}

ensure_fish_fnm() {
  if [[ "${DOTNVIM_FISH_FNM_READY:-0}" == "1" ]]; then
    return 0
  fi

  log "fish environment detected; using fnm as the Node version manager"

  if ! command -v fnm >/dev/null 2>&1; then
    install_fnm
  fi

  configure_fish_fnm

  if is_dry_run; then
    printf '[dry-run] eval "$(fnm env --shell bash --use-on-cd)"\n'
    printf '[dry-run] fnm install --lts --use\n'
    printf '[dry-run] fnm default "$(fnm current)"\n'
    export DOTNVIM_FISH_FNM_READY=1
    export DOTNVIM_NODE_RUNTIME_READY=1
    export DOTNVIM_NODE_MANAGED=1
    return 0
  fi

  command -v fnm >/dev/null 2>&1 || die "fnm not available after install"
  eval "$(fnm env --shell bash --use-on-cd)"
  fnm install --lts --use
  local version
  version="$(fnm current 2>/dev/null || true)"
  if [[ -n "$version" ]]; then
    fnm default "$version"
  else
    warn "could not determine the installed Node version to set as fnm default"
  fi
  command -v node >/dev/null 2>&1 || die "node not found after activating Node via fnm"
  command -v npm >/dev/null 2>&1 || die "npm not found after activating Node via fnm"
  export DOTNVIM_FISH_FNM_READY=1
  export DOTNVIM_NODE_RUNTIME_READY=1
  export DOTNVIM_NODE_MANAGED=1
}

ensure_npm_prefix() {
  ensure_node_runtime
  # With a version-managed Node runtime (nvm or fnm), npm global packages live
  # inside the manager's active Node directory; a fixed ~/.local prefix would
  # shadow per-version binaries.
  if [[ "${DOTNVIM_NODE_MANAGED:-0}" == "1" ]]; then
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
  if ! python3 -m pip --version >/dev/null 2>&1; then
    warn "python3 pip module unavailable (install python3-pip/python-pip), skipping python provider install"
    return 0
  fi
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
