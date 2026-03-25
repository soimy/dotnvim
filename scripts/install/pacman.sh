#!/usr/bin/env bash

install_pacman() {
  log "installing Arch dependencies via pacman"
  sudo_run pacman -Sy --needed --noconfirm git curl neovim ripgrep fd fzf lazygit tree-sitter-cli nodejs npm python python-pip unzip
}
