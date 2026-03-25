#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTNVIM_ROOT="$ROOT_DIR"
export DOTNVIM_DRY_RUN=0
export DOTNVIM_PACKAGE_MANAGER=""

if [[ "${1:-}" == "--dry-run" ]]; then
  export DOTNVIM_DRY_RUN=1
fi

# shellcheck source=scripts/install/common.sh
source "$ROOT_DIR/scripts/install/common.sh"

main() {
  ensure_repo_root
  ensure_local_bin_on_path

  case "$(uname -s)" in
    Darwin)
      # shellcheck source=scripts/install/macos.sh
      source "$ROOT_DIR/scripts/install/macos.sh"
      install_macos
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        export DOTNVIM_PACKAGE_MANAGER="apt"
        # shellcheck source=scripts/install/apt.sh
        source "$ROOT_DIR/scripts/install/apt.sh"
        install_apt
      elif command -v pacman >/dev/null 2>&1; then
        export DOTNVIM_PACKAGE_MANAGER="pacman"
        # shellcheck source=scripts/install/pacman.sh
        source "$ROOT_DIR/scripts/install/pacman.sh"
        install_pacman
      elif command -v dnf >/dev/null 2>&1; then
        export DOTNVIM_PACKAGE_MANAGER="dnf"
        # shellcheck source=scripts/install/dnf.sh
        source "$ROOT_DIR/scripts/install/dnf.sh"
        install_dnf
      else
        die "unsupported Linux package manager: expected apt-get, pacman, or dnf"
      fi
      ;;
    *)
      die "unsupported platform: $(uname -s)"
      ;;
  esac

  ensure_fd_alias
  ensure_tree_sitter_cli
  install_node_provider
  install_python_provider
  sync_lazyvim
  log "dotnvim bootstrap complete"
}

main "$@"
