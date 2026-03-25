#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/home"

cat >"$TMP_DIR/bin/uname" <<'EOF'
#!/usr/bin/env bash
echo Linux
EOF

cat >"$TMP_DIR/bin/dnf" <<'EOF'
#!/usr/bin/env bash
echo "stub dnf $*"
EOF

cat >"$TMP_DIR/bin/sudo" <<'EOF'
#!/usr/bin/env bash
echo "stub sudo $*"
EOF

cat >"$TMP_DIR/bin/python3" <<'EOF'
#!/usr/bin/env bash
echo "stub python3 $*"
EOF

chmod +x "$TMP_DIR/bin/"*

OUTPUT_FILE="$TMP_DIR/output.txt"

if PATH="$TMP_DIR/bin:/bin" HOME="$TMP_DIR/home" /bin/bash "$ROOT_DIR/bootstrap.sh" --dry-run >"$OUTPUT_FILE" 2>&1; then
  echo "bootstrap dry-run exited successfully"
  cat "$OUTPUT_FILE"
else
  echo "bootstrap dry-run failed unexpectedly"
  cat "$OUTPUT_FILE"
  exit 1
fi

if ! grep -q '\[dotnvim] dotnvim bootstrap complete' "$OUTPUT_FILE"; then
  echo "expected bootstrap completion log in dry-run output"
  exit 1
fi

if ! grep -Eq '\[dry-run] sudo (apt-get install -y git curl neovim ripgrep fzf fd-find python3 python3-pip unzip|dnf install -y git curl neovim ripgrep fd-find fzf nodejs npm python3 python3-pip unzip tree-sitter-cli)' "$OUTPUT_FILE"; then
  echo "expected Linux dependency install to include unzip in dry-run output"
  exit 1
fi
