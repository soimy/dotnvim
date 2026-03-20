#!/usr/bin/env bash

install_dnf() {
  log "installing Fedora dependencies via dnf"
  sudo_run dnf install -y git curl neovim ripgrep fd-find fzf nodejs npm python3 python3-pip tree-sitter-cli
  install_optional_pkg dnf lazygit
}
