#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MCP_HOST="${MCP_SERVER_HOST:-localhost}"
MCP_PORT="${MCP_SERVER_PORT:-3000}"

echo "Starting local MCP server on ${MCP_HOST}:${MCP_PORT}..."
node mcp-server.js > /tmp/full-stack-heavy-mcp.log 2>&1 &
MCP_PID=$!

cleanup() {
  if kill -0 "$MCP_PID" 2>/dev/null; then
    kill "$MCP_PID" 2>/dev/null || true
    wait "$MCP_PID" 2>/dev/null || true
  fi
}

trap cleanup EXIT

# Give the local MCP server a short window to bind before testing.
for _ in {1..20}; do
  if curl -fsS "http://${MCP_HOST}:${MCP_PORT}/health" >/dev/null 2>&1; then
    break
  fi
  sleep 0.2
done

echo "Running live Postman connectivity test..."
npx nx run full-stack-heavy:postman:test

echo "Live verification complete."
