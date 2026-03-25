#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/home"

apply_stub() {
  local name="$1"
  local body="$2"
  printf '%s\n' "$body" >"$TMP_DIR/bin/$name"
  chmod +x "$TMP_DIR/bin/$name"
}

apply_stub uname '#!/usr/bin/env bash
echo Linux'
apply_stub apt-get '#!/usr/bin/env bash
echo "stub apt-get $*"'
apply_stub sudo '#!/usr/bin/env bash
echo "stub sudo $*"'
apply_stub python3 '#!/usr/bin/env bash
echo "stub python3 $*"'

OUTPUT_FILE="$TMP_DIR/output.txt"

if PATH="$TMP_DIR/bin:/usr/bin:/bin" HOME="$TMP_DIR/home" /bin/bash "$ROOT_DIR/bootstrap.sh" --dry-run >"$OUTPUT_FILE" 2>&1; then
  echo "bootstrap apt dry-run exited successfully"
else
  echo "bootstrap apt dry-run failed unexpectedly"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dry-run] sudo apt-get update' "$OUTPUT_FILE"; then
  echo "expected apt-get update in dry-run output"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dry-run] sudo apt-get install -y git curl neovim ripgrep fzf fd-find python3 python3-pip python3-venv unzip' "$OUTPUT_FILE"; then
  echo "expected apt dependency install in dry-run output"
  cat "$OUTPUT_FILE"
  exit 1
fi

if grep -q '\[dry-run] sudo apt-get install -y tree-sitter-cli' "$OUTPUT_FILE"; then
  echo "tree-sitter-cli should not be installed via apt on Ubuntu/Debian"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dry-run] nvm install node' "$OUTPUT_FILE"; then
  echo "expected nvm to install latest node in dry-run output"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dry-run] sanitize ~/.npmrc for nvm' "$OUTPUT_FILE"; then
  echo "expected ~/.npmrc sanitization in dry-run output"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dry-run] npm config delete prefix' "$OUTPUT_FILE"; then
  echo "expected npm prefix cleanup in dry-run output"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dry-run] nvm use --delete-prefix node' "$OUTPUT_FILE"; then
  echo "expected nvm to activate latest node in dry-run output"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dry-run] npm install -g tree-sitter-cli' "$OUTPUT_FILE"; then
  echo "expected tree-sitter-cli npm install in dry-run output"
  cat "$OUTPUT_FILE"
  exit 1
fi

cat "$OUTPUT_FILE"
