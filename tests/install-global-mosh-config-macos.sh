#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/home" "$TMP_DIR/homebrew/bin" "$TMP_DIR/homebrew/sbin"
LOG_FILE="$TMP_DIR/commands.log"

cat >"$TMP_DIR/bin/uname" <<'EOF'
#!/usr/bin/env bash
echo Darwin
EOF

cat >"$TMP_DIR/bin/brew" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "--prefix" ]]; then
  printf '%s\n' "$BREW_PREFIX"
  exit 0
fi

printf 'brew %s\n' "$*" >>"$LOG_FILE"
EOF

chmod +x "$TMP_DIR/bin/uname" "$TMP_DIR/bin/brew"

OUTPUT_FILE="$TMP_DIR/output.txt"

if PATH="$TMP_DIR/bin:/usr/bin:/bin" HOME="$TMP_DIR/home" LOG_FILE="$LOG_FILE" BREW_PREFIX="$TMP_DIR/homebrew" \
  bash "$ROOT_DIR/scripts/install-global-mosh-config" >"$OUTPUT_FILE" 2>&1; then
  echo "macOS mosh installer exited successfully"
else
  echo "macOS mosh installer failed unexpectedly"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q 'brew install mosh' "$LOG_FILE"; then
  echo "expected brew install mosh to be invoked"
  cat "$LOG_FILE"
  exit 1
fi

WRAPPER="$TMP_DIR/home/.local/bin/mosh-connect"
if [[ ! -x "$WRAPPER" ]]; then
  echo "expected wrapper to be installed at $WRAPPER"
  exit 1
fi

ZSHENV="$TMP_DIR/home/.zshenv"
if [[ ! -f "$ZSHENV" ]]; then
  echo "expected ~/.zshenv to be created on macOS"
  exit 1
fi

if ! grep -Fq "$TMP_DIR/homebrew/bin" "$ZSHENV"; then
  echo "expected ~/.zshenv to include Homebrew bin path"
  cat "$ZSHENV"
  exit 1
fi

if ! grep -Fq "$TMP_DIR/homebrew/sbin" "$ZSHENV"; then
  echo "expected ~/.zshenv to include Homebrew sbin path"
  cat "$ZSHENV"
  exit 1
fi

echo "macOS mosh installer smoke test passed"
