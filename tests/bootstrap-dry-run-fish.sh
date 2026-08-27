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
apply_stub fish '#!/usr/bin/env bash
exit 0'

# Simulate an active fish user whose config.fish tries to source the
# bash-only nvm init script (exactly the reported failure).
mkdir -p "$TMP_DIR/home/.config/fish"
cat >"$TMP_DIR/home/.config/fish/config.fish" <<'EOF'
# nvim init
source /usr/share/nvm/init-nvm.sh
EOF

OUTPUT_FILE="$TMP_DIR/output.txt"

if PATH="$TMP_DIR/bin:/usr/bin:/bin" HOME="$TMP_DIR/home" SHELL=/bin/fish /bin/bash "$ROOT_DIR/bootstrap.sh" --dry-run >"$OUTPUT_FILE" 2>&1; then
  echo "bootstrap fish dry-run exited successfully"
else
  echo "bootstrap fish dry-run failed unexpectedly"
  cat "$OUTPUT_FILE"
  exit 1
fi

assert() {
  if ! grep -q -- "$1" "$OUTPUT_FILE"; then
    echo "missing expected output: $1"
    cat "$OUTPUT_FILE"
    exit 1
  fi
}

assert_absent() {
  if grep -q -- "$1" "$OUTPUT_FILE"; then
    echo "unexpected output present: $1"
    cat "$OUTPUT_FILE"
    exit 1
  fi
}

assert 'fish environment detected'
assert 'install fnm'
assert 'conf.d/fnm.fish'
assert 'disable nvm sourcing'
assert 'fnm env --shell bash --use-on-cd'
assert 'fnm install --lts --use'
assert 'fnm default'
assert 'npm install -g tree-sitter-cli'
assert 'dotnvim bootstrap complete'

# In a fish environment fnm replaces nvm entirely.
assert_absent 'nvm install node'

# dry-run must leave the real fish config untouched.
if ! grep -q 'source /usr/share/nvm/init-nvm.sh' "$TMP_DIR/home/.config/fish/config.fish"; then
  echo "dry-run should not edit config.fish"
  cat "$OUTPUT_FILE"
  exit 1
fi

cat "$OUTPUT_FILE"
