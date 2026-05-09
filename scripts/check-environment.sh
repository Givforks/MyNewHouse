#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

echo "Nx projects:"
npx nx show projects

echo
echo "Default Postman test:"
npx nx run full-stack-heavy:postman:test

echo
echo "Mock Postman test:"
npx nx run full-stack-heavy:postman:test:mock-mcp
