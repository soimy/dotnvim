#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin" "$TMP_DIR/home"
LOG_FILE="$TMP_DIR/commands.log"

cat >"$TMP_DIR/bin/git" <<'EOF'
#!/usr/bin/env bash
printf 'git %s\n' "$*" >>"$LOG_FILE"
if [[ "${1:-}" == "clone" ]]; then
  target="${@: -1}"
  mkdir -p "$target/.git" "$target/bin"
  cat >"$target/bin/install_plugins" <<'INNER'
#!/usr/bin/env bash
printf 'install_plugins XDG_CONFIG_HOME=%s TMUX_PLUGIN_MANAGER_PATH=%s\n' "${XDG_CONFIG_HOME:-}" "${TMUX_PLUGIN_MANAGER_PATH:-}" >>"$LOG_FILE"
INNER
  chmod +x "$target/bin/install_plugins"
fi
EOF

chmod +x "$TMP_DIR/bin/git"

OUTPUT_FILE="$TMP_DIR/output.txt"

if PATH="$TMP_DIR/bin:/usr/bin:/bin" HOME="$TMP_DIR/home" LOG_FILE="$LOG_FILE" \
  bash "$ROOT_DIR/scripts/install-global-tmux-config" >"$OUTPUT_FILE" 2>&1; then
  echo "tmux installer exited successfully"
else
  echo "tmux installer failed unexpectedly"
  cat "$OUTPUT_FILE"
  exit 1
fi

TARGET_FILE="$TMP_DIR/home/.config/tmux/tmux.conf"
TPM_DIR="$TMP_DIR/home/.config/tmux/plugins/tpm"

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "expected tmux config to be installed at $TARGET_FILE"
  exit 1
fi

if ! grep -Fq "$TMP_DIR/home/.config/tmux/tmux.conf" "$TARGET_FILE"; then
  echo "expected installed tmux config to contain expanded home path"
  cat "$TARGET_FILE"
  exit 1
fi

if [[ ! -x "$TPM_DIR/bin/install_plugins" ]]; then
  echo "expected TPM install_plugins helper at $TPM_DIR/bin/install_plugins"
  exit 1
fi

if ! grep -q 'git clone --depth 1 https://github.com/tmux-plugins/tpm' "$LOG_FILE"; then
  echo "expected TPM clone command"
  cat "$LOG_FILE"
  exit 1
fi

if ! grep -q "install_plugins XDG_CONFIG_HOME=$TMP_DIR/home/.config TMUX_PLUGIN_MANAGER_PATH=$TMP_DIR/home/.config/tmux/plugins/" "$LOG_FILE"; then
  echo "expected install_plugins invocation with tmux environment"
  cat "$LOG_FILE"
  exit 1
fi

cat >"$TARGET_FILE" <<'EOF'
legacy tmux config
EOF

if PATH="$TMP_DIR/bin:/usr/bin:/bin" HOME="$TMP_DIR/home" LOG_FILE="$LOG_FILE" \
  bash "$ROOT_DIR/scripts/install-global-tmux-config" >"$OUTPUT_FILE.2" 2>&1; then
  echo "tmux reinstall exited successfully"
else
  echo "tmux reinstall failed unexpectedly"
  cat "$OUTPUT_FILE.2"
  exit 1
fi

BACKUP_FILE="$(find "$TMP_DIR/home/.config/tmux" -maxdepth 1 -name 'tmux.conf.bak.*' | head -n 1)"
if [[ -z "$BACKUP_FILE" ]]; then
  echo "expected backup file for existing tmux config"
  ls -la "$TMP_DIR/home/.config/tmux"
  exit 1
fi

if ! grep -Fq 'legacy tmux config' "$BACKUP_FILE"; then
  echo "expected backup to preserve previous tmux config content"
  cat "$BACKUP_FILE"
  exit 1
fi

echo "tmux installer smoke test passed"
