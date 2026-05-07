#!/usr/bin/env bash
set -e

# Copies linting/formatting templates from this repo to a new project
# Usage: ./init_project.sh /path/to/new/project

TEMPLATES_DIR="$(dirname "$0")"
TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
  echo "Usage: $0 /path/to/new/project"
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Target directory does not exist: $TARGET_DIR"
  exit 1
fi

cp "$TEMPLATES_DIR/.eslintrc.json" "$TARGET_DIR/" || true
cp "$TEMPLATES_DIR/.prettierrc.json" "$TARGET_DIR/" || true
cp "$TEMPLATES_DIR/.eslintignore" "$TARGET_DIR/" || true
cp "$TEMPLATES_DIR/.prettierignore" "$TARGET_DIR/" || true
cp "$TEMPLATES_DIR/.lintstagedrc.json" "$TARGET_DIR/" || true
cp "$TEMPLATES_DIR/package.json.template" "$TARGET_DIR/package.json" || true

echo "Templates copied to $TARGET_DIR"

echo "Run in your project: npm install --save-dev eslint prettier eslint-config-airbnb-base eslint-plugin-import lint-staged husky"

echo "Then run: npm run prepare"
chmod +x "$TEMPLATES_DIR/init_project.sh"
