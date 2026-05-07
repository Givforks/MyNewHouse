#!/usr/bin/env bash
set -euo pipefail

# Installs recommended VS Code extensions for this environment.
# Usage: ./install_extensions.sh

RECOMMENDED=(
  "dbaeumer.vscode-eslint"
  "esbenp.prettier-vscode"
  "editorconfig.editorconfig"
  "eamodio.gitlens"
  "mongodb.mongodb-vscode"
  "mtxr.sqltools"
  "mtxr.sqltools-driver-mysql"
  "ms-azuretools.vscode-docker"
  "postman.postman-for-vscode"
  "GitHub.vscode-pull-request-github"
)

if ! command -v code >/dev/null 2>&1; then
  echo "VS Code CLI 'code' not found. Install VS Code and ensure 'code' is on PATH." >&2
  exit 2
fi

for ext in "${RECOMMENDED[@]}"; do
  echo "Installing extension: $ext"
  code --install-extension "$ext" --force || true
done

echo "Done. Restart VS Code if needed."
