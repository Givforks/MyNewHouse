# 🔗 Postman MCP Integration Setup Guide

## Overview

This guide covers the complete setup for integrating **Postman API** with **VS Code MCP Server**, enabling seamless API collection management and MCP tool execution from Postman.

**Date Created:** May 9, 2026
**Environment:** mini (full setup)
**Language:** JavaScript (Node.js)

---

## 📋 Prerequisites

- Node.js 18.19.1 or higher (20+ recommended)
- Postman API Account with API Key
- VS Code with MCP Server running (or configured to start)
- Docker (optional, for containerized setup)
- MongoDB & MySQL (existing connections available)

---

## 🚀 Quick Start (5 minutes)

### 1. Get Your Postman API Key

1. Go to [Postman API Keys](https://web.postman.co/settings/me/api-keys)
2. Generate a new API key (starts with `PMAK-`)
3. Copy and save it securely

### 2. Set Up Environment Variables

```bash
# Navigate to your project
cd /home/givenchi/FULL-STACK-HEAVY

# Copy the template
cp .env.postman.template .env.postman

# Edit .env.postman with your Postman API key
nano .env.postman
# OR
vim .env.postman
```

**⚠️ Security Note:** Never commit `.env.postman` to Git. Add to `.gitignore`:
```
.env.postman
.env.postman.local
```

### 3. Install Dependencies

```bash
# Install dotenv (if not already installed)
npm install dotenv

# Verify the installation
npm list dotenv
```

### 4. Test the Connection

```bash
# Run the connection test
node postman-mcp-test.js
```

Expected output:
```
🧪 Postman MCP Connection Tests
============================================================

1️⃣  Configuration Check
------------------------------------------------------------
Status: PASS
Message: Configuration is valid

Config Summary:
  Postman API: https://api.postman.com
  API Key: PMAK-69f9ec...e46e23bc
  MCP Server: http://localhost:3000

2️⃣  Postman API Connectivity
------------------------------------------------------------
Status: PASS
Message: Successfully connected to Postman API
Workspaces Found: 3

3️⃣  MCP Server Connectivity
------------------------------------------------------------
Status: WARN
Message: MCP server not reachable: connect ECONNREFUSED 127.0.0.1:3000
Target: localhost:3000

============================================================

✅ Overall Status: CHECK REQUIRED
```

If you see `PASS` for configuration and Postman API, you're good to go! The MCP server warning is expected if it's not currently running.

---

## 📁 File Structure

```
/home/givenchi/FULL-STACK-HEAVY/
├── .env.postman                    # ⚠️ Environment variables (create from template)
├── .env.postman.template           # Template for environment variables
├── postman-mcp-config.js           # Main configuration bridge
├── postman-mcp-test.js             # Connection test script
├── postman-mcp-integrate.sh        # Integration automation script
├── POSTMAN_MCP_SETUP.md            # This file
├── package.json                    # Dependencies (with MCP scripts)
├── .gitignore                      # Git ignore rules
└── [existing files]
```

---

## 🔧 Configuration Details

### postman-mcp-config.js

Main bridge class that connects Postman API to VS Code MCP.

**Key Methods:**

```javascript
const { PostmanMCPBridge } = require('./postman-mcp-config');

// Initialize bridge
const bridge = new PostmanMCPBridge();

// Get API headers for Postman requests
const headers = bridge.getHeaders();
// Returns: { 'X-API-Key': '...', 'Content-Type': 'application/json' }

// Get MCP connection details
const mcpConn = bridge.getMCPConnection();
// Returns: { host: 'localhost', port: 3000, url: 'http://localhost:3000' }

// Build Postman API endpoint
const endpoint = bridge.buildEndpoint('/collections');
// Returns: 'https://api.postman.com/collections'

// Validate configuration
const validation = bridge.validate();
// Returns: { valid: true, checks: { ... } }

// Get full config summary
const config = bridge.getConfig();
```

---

## 📡 API Endpoints Reference

### Postman Collections

```javascript
// Get all collections
GET /collections
Headers: X-API-Key: <YOUR_KEY>

// Get collection details
GET /collections/{collection_id}

// Create a new collection
POST /collections
Body: { collection: { name: "...", description: "..." } }

// Update collection
PUT /collections/{collection_id}

// Delete collection
DELETE /collections/{collection_id}
```

### Postman Workspaces

```javascript
// List all workspaces
GET /workspaces
Headers: X-API-Key: <YOUR_KEY>

// Get workspace details
GET /workspaces/{workspace_id}

// List workspace collections
GET /workspaces/{workspace_id}/collections
```

### MCP Server Integration

```javascript
// Health check
GET http://localhost:3000/health

// List available tools
GET http://localhost:3000/tools

// Execute MCP tool
POST http://localhost:3000/tools/{tool_name}/execute
Body: { params: { ... } }
```

---

## 🛠️ Usage Examples

### Example 1: List Postman Workspaces

```javascript
const https = require('https');
const { PostmanMCPBridge } = require('./postman-mcp-config');

const bridge = new PostmanMCPBridge();
const headers = bridge.getHeaders();
const endpoint = bridge.buildEndpoint('/workspaces');

const options = {
  hostname: 'api.postman.com',
  path: '/workspaces',
  method: 'GET',
  headers: headers,
};

const req = https.request(options, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    const workspaces = JSON.parse(data);
    console.log('Workspaces:', workspaces);
  });
});

req.end();
```

### Example 2: Initialize MCP Bridge and Check Status

```javascript
const { PostmanMCPBridge } = require('./postman-mcp-config');

try {
  const bridge = new PostmanMCPBridge();
  
  if (!bridge.validate().valid) {
    console.error('Invalid configuration');
    process.exit(1);
  }

  console.log('✅ Bridge initialized successfully');
  console.log('Config:', bridge.getConfig());
  console.log('MCP Connection:', bridge.getMCPConnection());
} catch (err) {
  console.error('Failed to initialize bridge:', err.message);
}
```

### Example 3: Integrate with Docker Services

```bash
# Start Docker services with MCP and Postman support
docker-compose up -d

# Run MCP server
npm run mcp:start

# In another terminal, test the integration
npm run postman:test

# List available Postman collections
npm run postman:list-collections
```

---

## 📦 Package.json Scripts

Add these scripts to `package.json`:

```json
{
  "scripts": {
    "postman:config": "node postman-mcp-config.js",
    "postman:test": "node postman-mcp-test.js",
    "postman:setup": "bash postman-mcp-integrate.sh",
    "mcp:start": "node mcp-server.js",
    "mcp:test": "node postman-mcp-test.js"
  }
}
```

---

## 🐳 Docker Integration

### Option 1: Run in Docker Container

```bash
# Build image
docker build -t postman-mcp-bridge:latest .

# Run container with environment
docker run \
  -e POSTMAN_API_KEY=$POSTMAN_API_KEY \
  -e MCP_SERVER_HOST=host.docker.internal \
  -e MCP_SERVER_PORT=3000 \
  postman-mcp-bridge:latest \
  npm run postman:test
```

### Option 2: Use Docker Compose

Add to `docker-compose.yml`:

```yaml
services:
  postman-mcp:
    build: .
    environment:
      - POSTMAN_API_KEY=${POSTMAN_API_KEY}
      - MCP_SERVER_HOST=mcp-server
      - MCP_SERVER_PORT=3000
    depends_on:
      - mcp-server
    networks:
      - app-network

  mcp-server:
    image: vscode-mcp-server:latest
    ports:
      - "3000:3000"
    networks:
      - app-network
```

Start all services:
```bash
docker-compose up -d
```

---

## 🔄 Integration with Existing Services

### MongoDB Integration

```javascript
const { MongoClient } = require('mongodb');
const { PostmanMCPBridge } = require('./postman-mcp-config');
require('dotenv').config({ path: '.env.postman' });

const mongoUri = process.env.MONGODB_URI;
const client = new MongoClient(mongoUri);

const bridge = new PostmanMCPBridge();

// Use MongoDB and Postman together
(async () => {
  await client.connect();
  const db = client.db('mydb');
  
  // Store Postman collection metadata in MongoDB
  const collectionsDb = db.collection('postman_collections');
  await collectionsDb.insertOne({
    bridge: bridge.getConfig(),
    timestamp: new Date(),
  });
  
  await client.close();
})();
```

### MySQL Integration

```javascript
const mysql = require('mysql2/promise');
const { PostmanMCPBridge } = require('./postman-mcp-config');
require('dotenv').config({ path: '.env.postman' });

const connection = await mysql.createConnection({
  host: process.env.MYSQL_HOST,
  user: process.env.MYSQL_USER,
  password: process.env.MYSQL_PASSWORD,
  database: 'myapp',
});

const bridge = new PostmanMCPBridge();

// Log Postman integration events to MySQL
const query = 'INSERT INTO postman_logs (event, config) VALUES (?, ?)';
await connection.execute(query, [
  'bridge_initialized',
  JSON.stringify(bridge.getConfig()),
]);
```

---

## 🔐 Security Best Practices

### 1. **API Key Management**
- ✅ Store in `.env.postman` (never commit)
- ✅ Use VS Code Settings Sync secret storage for sensitive values
- ✅ Rotate API keys regularly
- ❌ Never hardcode keys in source files
- ❌ Never log or display full API keys

### 2. **Environment Separation**
```bash
# Development
cp .env.postman.template .env.postman

# Staging (use different API key)
cp .env.postman.template .env.postman.staging

# Production (use service account key)
cp .env.postman.template .env.postman.production
```

### 3. **Access Control**
```bash
# Restrict .env.postman to user only
chmod 600 .env.postman

# Verify permissions
ls -la .env.postman
# Should show: -rw------- (600)
```

### 4. **Audit Logging**
```javascript
// Enable detailed logging for security events
const logger = require('winston');

logger.info('PostmanMCP Bridge initialized', {
  timestamp: new Date(),
  user: process.env.USER,
  host: os.hostname(),
});
```

---

## 🚨 Troubleshooting

### Issue: "POSTMAN_API_KEY is not set"

**Solution:**
```bash
# 1. Verify .env.postman exists
ls -la .env.postman

# 2. Check if .env file is being loaded
grep POSTMAN_API_KEY .env.postman

# 3. Reload your terminal session
source ~/.bashrc
# or
bash
```

### Issue: "MCP server not reachable"

**Solution:**
```bash
# 1. Check if MCP server is running
lsof -i :3000

# 2. Start the MCP server
npm run mcp:start

# 3. Verify VS Code MCP extension is loaded
# - Open VS Code
# - Check Extensions panel for MCP Server
```

### Issue: "Postman API connection timeout"

**Solution:**
```bash
# 1. Verify API key is valid
node -e "console.log(process.env.POSTMAN_API_KEY)" 

# 2. Check network connectivity
curl -H "X-API-Key: $POSTMAN_API_KEY" https://api.postman.com/workspaces

# 3. Increase timeout in .env.postman
API_REQUEST_TIMEOUT=10000
```

### Issue: Configuration validation fails

**Solution:**
```bash
# 1. Run diagnostic test
node postman-mcp-test.js

# 2. Check configuration individually
node -e "const {PostmanMCPBridge} = require('./postman-mcp-config'); const b = new PostmanMCPBridge(); console.log(b.validate());"

# 3. Verify all required env variables
grep -E "^(POSTMAN_|MCP_)" .env.postman
```

---

## 🔄 Recovery Procedures

### After VS Code Crash

```bash
# 1. Reconnect Postman API
source .env.postman

# 2. Verify connection
npm run postman:test

# 3. Restart MCP server
npm run mcp:start
```

### After System Reboot

```bash
# 1. Clone from gist (if needed)
export GITHUB_TOKEN="your_pat"
gh gist clone 3991f518ce5111b224258e07f5afe591

# 2. Install dependencies
npm install

# 3. Set up environment
cp .env.postman.template .env.postman
# Edit with your API key

# 4. Test everything
npm run postman:test
```

### Database Reconnection

```bash
# If MongoDB drops connection
# - Connection will auto-reconnect (MONGODB_RECONNECT.md)

# If MySQL drops connection
# - Pool will retry connections
# - Check MYSQL_VSCODE_SETUP.md for details
```

---

## 📚 Related Documentation

- [MONGODB_RECONNECT.md](./MONGODB_RECONNECT.md) — MongoDB reconnection guide
- [MYSQL_VSCODE_SETUP.md](./MYSQL_VSCODE_SETUP.md) — MySQL connection setup
- [DEV_TOOLS_SETUP.md](./DEV_TOOLS_SETUP.md) — Development tools configuration
- [FRAMEWORKS_AND_TOOLS.md](./FRAMEWORKS_AND_TOOLS.md) — Technology stack overview

---

## 🎯 Next Steps

1. ✅ Copy `.env.postman.template` → `.env.postman`
2. ✅ Add your Postman API key to `.env.postman`
3. ✅ Run `npm run postman:test`
4. ✅ Check documentation in VS Code
5. ✅ Start using Postman API in your MCP workflows

---

## 📞 Support

For issues or questions:

1. Check [Troubleshooting](#-troubleshooting) section
2. Review [Postman API Docs](https://learning.postman.com/docs/developer/intro-api/)
3. Check [VS Code MCP Documentation](https://code.visualstudio.com/docs/editor/mcp)
4. Contact: givens.abraham@live.com

---

**Last Updated:** May 9, 2026
**Maintained by:** Givens Emmah Abraham
**Repository:** https://github.com/Givforks/MyNewHouse
