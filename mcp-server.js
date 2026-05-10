#!/usr/bin/env node
/**
 * Minimal local MCP-compatible HTTP server for local readiness checks.
 * Endpoints:
 * - GET /health
 * - GET /tools
 * - POST /tools/:name/execute
 */

const http = require('http');
const {
  loadPostmanEnvironment,
  getPostmanSettings,
} = require('./libs/shared-config/src');

loadPostmanEnvironment();
const settings = getPostmanSettings();

function writeJson(res, statusCode, payload) {
  res.writeHead(statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
}

function parseRequestBody(req) {
  return new Promise((resolve) => {
    let raw = '';

    req.on('data', (chunk) => {
      raw += chunk;
    });

    req.on('end', () => {
      if (!raw) {
        resolve({});
        return;
      }

      try {
        resolve(JSON.parse(raw));
      } catch (_) {
        resolve({ raw });
      }
    });
  });
}

function createMcpServer() {
  return http.createServer(async (req, res) => {
    const method = req.method || 'GET';
    const url = req.url || '/';

    if (method === 'GET' && url === '/health') {
      writeJson(res, 200, {
        status: 'ok',
        service: 'local-mcp-server',
        host: settings.mcpServerHost,
        port: settings.mcpServerPort,
        timestamp: new Date().toISOString(),
      });
      return;
    }

    if (method === 'GET' && url === '/tools') {
      writeJson(res, 200, {
        tools: [
          {
            name: 'ping',
            description: 'Basic reachability tool',
          },
        ],
      });
      return;
    }

    const execMatch = url.match(/^\/tools\/([^/]+)\/execute$/);
    if (method === 'POST' && execMatch) {
      const payload = await parseRequestBody(req);
      writeJson(res, 200, {
        ok: true,
        tool: execMatch[1],
        received: payload,
        timestamp: new Date().toISOString(),
      });
      return;
    }

    writeJson(res, 404, {
      error: 'not-found',
      message: `No route for ${method} ${url}`,
    });
  });
}

function startServer() {
  const server = createMcpServer();

  server.on('error', (err) => {
    console.error(`Failed to start local MCP server: ${err.message}`);
    process.exit(1);
  });

  server.listen(settings.mcpServerPort, settings.mcpServerHost, () => {
    console.log(`Local MCP server listening on http://${settings.mcpServerHost}:${settings.mcpServerPort}`);
  });

  return server;
}

if (require.main === module) {
  startServer();
}

module.exports = {
  createMcpServer,
  startServer,
};
