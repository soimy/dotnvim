#!/usr/bin/env bash

install_apt() {
  log "installing Debian/Ubuntu dependencies via apt"
  sudo_run apt-get update
  sudo_run apt-get install -y git curl neovim ripgrep fzf fd-find nodejs npm python3 python3-pip
  install_optional_pkg apt lazygit
  install_optional_pkg apt tree-sitter-cli
}
