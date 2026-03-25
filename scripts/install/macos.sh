#!/usr/bin/env bash

install_macos() {
  command -v brew >/dev/null 2>&1 || die "Homebrew is required on macOS"
  log "installing macOS dependencies via Homebrew"
  run brew tap laishulu/homebrew
  run brew tap daipeihust/tap
  run brew install neovim git ripgrep fd fzf lazygit tree-sitter node python macism im-select
}
