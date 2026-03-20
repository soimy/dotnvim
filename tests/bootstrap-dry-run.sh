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

if PATH="$TMP_DIR/bin:/usr/bin:/bin" HOME="$TMP_DIR/home" bash "$ROOT_DIR/bootstrap.sh" --dry-run >"$OUTPUT_FILE" 2>&1; then
  echo "bootstrap dry-run exited successfully"
  cat "$OUTPUT_FILE"
else
  echo "bootstrap dry-run failed unexpectedly"
  cat "$OUTPUT_FILE"
  exit 1
fi
