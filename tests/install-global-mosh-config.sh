#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/home"
LOG_FILE="$TMP_DIR/commands.log"

cat >"$TMP_DIR/bin/uname" <<'EOF'
#!/usr/bin/env bash
echo Linux
EOF

cat >"$TMP_DIR/bin/apt-get" <<'EOF'
#!/usr/bin/env bash
printf 'apt-get %s\n' "$*" >>"$LOG_FILE"
EOF

cat >"$TMP_DIR/bin/sudo" <<'EOF'
#!/usr/bin/env bash
printf 'sudo %s\n' "$*" >>"$LOG_FILE"
"$@"
EOF

chmod +x "$TMP_DIR/bin/uname" "$TMP_DIR/bin/apt-get" "$TMP_DIR/bin/sudo"

OUTPUT_FILE="$TMP_DIR/output.txt"

if PATH="$TMP_DIR/bin:/usr/bin:/bin" HOME="$TMP_DIR/home" LOG_FILE="$LOG_FILE" \
  bash "$ROOT_DIR/scripts/install-global-mosh-config" >"$OUTPUT_FILE" 2>&1; then
  echo "mosh installer exited successfully"
else
  echo "mosh installer failed unexpectedly"
  cat "$OUTPUT_FILE"
  exit 1
fi

WRAPPER="$TMP_DIR/home/.local/bin/mosh-connect"

if [[ ! -x "$WRAPPER" ]]; then
  echo "expected wrapper to be installed at $WRAPPER"
  exit 1
fi

if ! grep -q 'sudo apt-get update' "$LOG_FILE"; then
  echo "expected apt-get update to be invoked via sudo"
  cat "$LOG_FILE"
  exit 1
fi

if ! grep -q 'sudo apt-get install -y mosh' "$LOG_FILE"; then
  echo "expected mosh package install via apt-get"
  cat "$LOG_FILE"
  exit 1
fi

HELP_OUTPUT="$("$WRAPPER" 2>&1 || true)"
if [[ "$HELP_OUTPUT" != *"Usage: mosh-connect <destination> [mosh args...]"* ]]; then
  echo "expected wrapper help output"
  printf '%s\n' "$HELP_OUTPUT"
  exit 1
fi

cat >"$TMP_DIR/bin/mosh" <<'EOF'
#!/usr/bin/env bash
printf 'stub mosh %s\n' "$*"
EOF

chmod +x "$TMP_DIR/bin/mosh"

FORWARD_OUTPUT="$(PATH="$TMP_DIR/bin:/usr/bin:/bin" "$WRAPPER" user@example.com --ssh='ssh -p 2222')"
if [[ "$FORWARD_OUTPUT" != "stub mosh user@example.com --ssh=ssh -p 2222" ]]; then
  echo "expected wrapper to forward destination and remaining args to mosh"
  printf '%s\n' "$FORWARD_OUTPUT"
  exit 1
fi

echo "mosh installer smoke test passed"
