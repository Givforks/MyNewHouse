/**
 * Postman MCP Connection Test
 * Validates Postman API connectivity and MCP server readiness
 * Run with: node postman-mcp-test.js
 */

const https = require('https');
const http = require('http');
const { PostmanMCPBridge } = require('./postman-mcp-config');
const {
  loadPostmanEnvironment,
  getPostmanSettings,
  maskSecret,
} = require('./libs/shared-config/src');

loadPostmanEnvironment();

const settings = getPostmanSettings();

function shouldAutoMockMcp() {
  const value = (process.env.MCP_AUTO_MOCK || '').toLowerCase();
  return value === '1' || value === 'true' || value === 'yes';
}

async function startMockMcpServerIfEnabled() {
  if (!shouldAutoMockMcp()) {
    return null;
  }

  return new Promise((resolve) => {
    const server = http.createServer((req, res) => {
      if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', source: 'mock-mcp' }));
        return;
      }

      res.writeHead(404, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'not-found' }));
    });

    server.on('error', (err) => {
      if (err.code === 'EADDRINUSE') {
        console.log(`Using existing MCP service on ${settings.mcpServerHost}:${settings.mcpServerPort}`);
        resolve(null);
        return;
      }

      console.warn(`Unable to start mock MCP server: ${err.message}`);
      resolve(null);
    });

    server.listen(settings.mcpServerPort, settings.mcpServerHost, () => {
      console.log(`Mock MCP server started on ${settings.mcpServerHost}:${settings.mcpServerPort}`);
      resolve(server);
    });
  });
}

async function stopMockMcpServer(server) {
  if (!server) {
    return;
  }

  await new Promise((resolve) => {
    server.close(() => {
      console.log('Mock MCP server stopped');
      resolve();
    });
  });
}

/**
 * Test Postman API connectivity
 */
async function testPostmanAPI() {
  return new Promise((resolve) => {
    if (!settings.postmanApiKey) {
      resolve({
        status: 'FAIL',
        message: 'Postman API key not set',
        timestamp: new Date().toISOString(),
      });
      return;
    }

    const options = {
      hostname: 'api.postman.com',
      path: '/workspaces',
      method: 'GET',
      headers: {
        'X-API-Key': settings.postmanApiKey,
        'Content-Type': 'application/json',
      },
      timeout: 5000,
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        resolve({
          status: res.statusCode === 200 ? 'PASS' : 'FAIL',
          statusCode: res.statusCode,
          message: res.statusCode === 200 
            ? 'Successfully connected to Postman API'
            : `Postman API returned status ${res.statusCode}`,
          timestamp: new Date().toISOString(),
          workspacesCount: res.statusCode === 200 ? JSON.parse(data).workspaces?.length : 0,
        });
      });
    });

    req.on('error', (err) => {
      resolve({
        status: 'FAIL',
        message: `Postman API error: ${err.message}`,
        timestamp: new Date().toISOString(),
      });
    });

    req.on('timeout', () => {
      req.destroy();
      resolve({
        status: 'FAIL',
        message: 'Postman API request timeout',
        timestamp: new Date().toISOString(),
      });
    });

    req.end();
  });
}

/**
 * Test MCP Server connectivity
 */
async function testMCPServer() {
  return new Promise((resolve) => {
    const options = {
      hostname: settings.mcpServerHost,
      port: settings.mcpServerPort,
      path: '/health',
      method: 'GET',
      timeout: 5000,
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        resolve({
          status: res.statusCode === 200 ? 'PASS' : 'WARN',
          statusCode: res.statusCode,
          message: res.statusCode === 200 
            ? 'MCP server is healthy'
            : `MCP server returned status ${res.statusCode}`,
          timestamp: new Date().toISOString(),
        });
      });
    });

    req.on('error', (err) => {
      resolve({
        status: 'WARN',
        message: `MCP server not reachable: ${err.message}`,
        timestamp: new Date().toISOString(),
      });
    });

    req.on('timeout', () => {
      req.destroy();
      resolve({
        status: 'WARN',
        message: `MCP server timeout (${settings.mcpServerHost}:${settings.mcpServerPort})`,
        timestamp: new Date().toISOString(),
      });
    });

    req.end();
  });
}

/**
 * Validate configuration
 */
function testConfiguration() {
  try {
    const bridge = new PostmanMCPBridge();
    const validation = bridge.validate();

    return {
      status: validation.valid ? 'PASS' : 'FAIL',
      message: validation.valid 
        ? 'Configuration is valid'
        : 'Configuration has invalid values',
      checks: validation.checks,
      config: bridge.getConfig(),
      timestamp: new Date().toISOString(),
    };
  } catch (err) {
    return {
      status: 'FAIL',
      message: `Configuration error: ${err.message}`,
      timestamp: new Date().toISOString(),
    };
  }
}

/**
 * Run all tests and display results
 */
async function runTests() {
  let mockMcpServer;

  console.log('\n🧪 Postman MCP Connection Tests\n');
  console.log('=' .repeat(60));

  mockMcpServer = await startMockMcpServerIfEnabled();

  // Test Configuration
  console.log('\n1️⃣  Configuration Check');
  console.log('-'.repeat(60));
  const configTest = testConfiguration();
  console.log(`Status: ${configTest.status}`);
  console.log(`Message: ${configTest.message}`);
  if (configTest.status === 'PASS') {
    console.log(`\nConfig Summary:`);
    console.log(`  Postman API: ${configTest.config.postman.apiUrl}`);
    console.log(`  API Key: ${maskSecret(settings.postmanApiKey)}`);
    console.log(`  MCP Server: ${configTest.config.mcp.connectionUrl}`);
  }

  // Test Postman API
  console.log('\n2️⃣  Postman API Connectivity');
  console.log('-'.repeat(60));
  const postmanTest = await testPostmanAPI();
  console.log(`Status: ${postmanTest.status}`);
  console.log(`Message: ${postmanTest.message}`);
  if (postmanTest.workspacesCount !== undefined) {
    console.log(`Workspaces Found: ${postmanTest.workspacesCount}`);
  }

  // Test MCP Server
  console.log('\n3️⃣  MCP Server Connectivity');
  console.log('-'.repeat(60));
  const mcpTest = await testMCPServer();
  console.log(`Status: ${mcpTest.status}`);
  console.log(`Message: ${mcpTest.message}`);
  console.log(`Target: ${settings.mcpServerHost}:${settings.mcpServerPort}`);

  // Summary
  console.log('\n' + '='.repeat(60));
  const allPass = configTest.status === 'PASS' && postmanTest.status === 'PASS';
  console.log(`\n✅ Overall Status: ${allPass ? 'READY' : 'CHECK REQUIRED'}\n`);

  await stopMockMcpServer(mockMcpServer);
  process.exit(allPass ? 0 : 1);
}

// Run tests
runTests().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
