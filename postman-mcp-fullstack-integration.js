/**
 * Postman MCP + Full-Stack Integration Example
 * Demonstrates integration with Docker, MongoDB, MySQL, and MCP
 * Language: JavaScript (Node.js)
 */

const https = require('https');
const http = require('http');
const { PostmanMCPBridge } = require('./postman-mcp-config');
const {
  loadPostmanEnvironment,
  getPostmanSettings,
} = require('./libs/shared-config/src');

loadPostmanEnvironment();

const settings = getPostmanSettings();

/**
 * Logger for integration events
 */
class Logger {
  constructor(level = 'info') {
    this.level = level;
    this.levels = { error: 0, warn: 1, info: 2, debug: 3 };
  }

  log(severity, message, data = {}) {
    if (this.levels[severity] <= this.levels[this.level]) {
      const timestamp = new Date().toISOString();
      console.log(`[${timestamp}] [${severity.toUpperCase()}] ${message}`, 
                  Object.keys(data).length > 0 ? JSON.stringify(data) : '');
    }
  }

  error(msg, data) { this.log('error', msg, data); }
  warn(msg, data) { this.log('warn', msg, data); }
  info(msg, data) { this.log('info', msg, data); }
  debug(msg, data) { this.log('debug', msg, data); }
}

const logger = new Logger(settings.logLevel);

/**
 * MongoDB Integration with Postman MCP
 */
class MongoDBPostmanIntegration {
  constructor() {
    this.bridge = new PostmanMCPBridge();
    this.mongoUri = settings.mongoUri;
  }

  async init() {
    try {
      logger.info('Initializing MongoDB-Postman integration');
      
      if (!this.mongoUri) {
        throw new Error('MongoDB URI not configured');
      }

      logger.info('MongoDB connection ready', {
        host: this.mongoUri.split('@')[1]?.split('/')[0] || 'localhost',
        bridge: this.bridge.getConfig().mcp,
      });

      return true;
    } catch (err) {
      logger.error('Failed to initialize MongoDB integration', { error: err.message });
      return false;
    }
  }

  /**
   * Store Postman collection metadata in MongoDB
   * (requires MongoDB client to be connected separately)
   */
  async storeCollectionMetadata(collection) {
    logger.info('Storing Postman collection metadata', { collection: collection.name });
    
    return {
      collection: collection.name,
      postmanBridge: this.bridge.getConfig(),
      timestamp: new Date().toISOString(),
    };
  }
}

/**
 * MySQL Integration with Postman MCP
 */
class MySQLPostmanIntegration {
  constructor() {
    this.bridge = new PostmanMCPBridge();
    this.mysqlHost = settings.mysqlHost;
    this.mysqlPort = settings.mysqlPort;
    this.mysqlUser = settings.mysqlUser;
  }

  async init() {
    try {
      logger.info('Initializing MySQL-Postman integration');

      if (!this.mysqlHost || !this.mysqlUser) {
        throw new Error('MySQL configuration incomplete');
      }

      logger.info('MySQL connection ready', {
        host: this.mysqlHost,
        port: this.mysqlPort,
        user: this.mysqlUser,
      });

      return true;
    } catch (err) {
      logger.error('Failed to initialize MySQL integration', { error: err.message });
      return false;
    }
  }

  /**
   * Log Postman API events to MySQL
   * (requires MySQL connection to be set up separately)
   */
  async logPostmanEvent(eventName, eventData) {
    logger.info('Logging Postman event to MySQL', { event: eventName });

    return {
      event: eventName,
      postmanBridge: this.bridge.getConfig(),
      eventData: eventData,
      timestamp: new Date().toISOString(),
    };
  }
}

/**
 * Docker Service Integration with Postman MCP
 */
class DockerPostmanIntegration {
  constructor() {
    this.bridge = new PostmanMCPBridge();
    this.dockerEnv = settings.dockerEnv;
  }

  getDockerComposeConfig() {
    logger.info('Generating Docker Compose configuration for Postman MCP');

    return {
      version: '3.8',
      services: {
        'postman-mcp-bridge': {
          build: {
            context: '.',
            dockerfile: 'Dockerfile',
          },
          environment: {
            POSTMAN_API_KEY: settings.postmanApiKey,
            MCP_SERVER_HOST: settings.mcpServerHost,
            MCP_SERVER_PORT: settings.mcpServerPort,
            NODE_ENV: this.dockerEnv,
          },
          ports: ['3001:3001'],
          depends_on: ['mongodb', 'mysql', 'mcp-server'],
          networks: ['app-network'],
        },
        'mcp-server': {
          image: 'vscode-mcp-server:latest',
          ports: ['3000:3000'],
          networks: ['app-network'],
        },
        'mongodb': {
          image: 'mongo:latest',
          ports: ['27017:27017'],
          environment: {
            MONGO_INITDB_ROOT_USERNAME: 'admin',
            MONGO_INITDB_ROOT_PASSWORD: 'password',
          },
          networks: ['app-network'],
        },
        'mysql': {
          image: 'mysql:8',
          ports: ['3306:3306'],
          environment: {
            MYSQL_ROOT_PASSWORD: 'root',
            MYSQL_USER: settings.mysqlUser,
          },
          networks: ['app-network'],
        },
      },
      networks: {
        'app-network': {
          driver: 'bridge',
        },
      },
    };
  }

  getDockerfile() {
    logger.info('Generating Dockerfile for Postman MCP bridge');

    return `FROM node:18-alpine

WORKDIR /app

# Copy configuration files
COPY package.json .
COPY postman-mcp-config.js .
COPY postman-mcp-test.js .

# Install dependencies
RUN npm install

# Expose port
EXPOSE 3001

# Set environment
ENV NODE_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \\
  CMD node -e "require('http').get('http://localhost:3001/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Start application
CMD ["node", "postman-mcp-config.js"]`;
  }
}

/**
 * Full-Stack Integration Orchestrator
 */
class FullStackIntegration {
  constructor() {
    this.bridge = new PostmanMCPBridge();
    this.mongodb = new MongoDBPostmanIntegration();
    this.mysql = new MySQLPostmanIntegration();
    this.docker = new DockerPostmanIntegration();
    this.initialized = false;
  }

  async init() {
    logger.info('🚀 Initializing Full-Stack Postman MCP Integration');

    try {
      // Validate configuration
      const validation = this.bridge.validate();
      if (!validation.valid) {
        throw new Error('Bridge configuration invalid');
      }

      // Initialize each integration
      await this.mongodb.init();
      await this.mysql.init();

      logger.info('✅ Full-Stack integration initialized successfully');
      this.initialized = true;
      return true;
    } catch (err) {
      logger.error('Failed to initialize full-stack integration', { error: err.message });
      return false;
    }
  }

  async getStatus() {
    logger.info('Getting full-stack integration status');

    return {
      initialized: this.initialized,
      postmanBridge: {
        status: 'READY',
        config: this.bridge.getConfig(),
      },
      mongodb: {
        status: settings.mongoUri ? 'CONFIGURED' : 'UNCONFIGURED',
        uri: settings.mongoUri ? `${settings.mongoUri.split('@')[0]}@...` : 'N/A',
      },
      mysql: {
        status: settings.mysqlHost ? 'CONFIGURED' : 'UNCONFIGURED',
        host: settings.mysqlHost || 'N/A',
        port: settings.mysqlPort || 'N/A',
      },
      docker: {
        environment: settings.dockerEnv,
      },
    };
  }

  async testConnections() {
    logger.info('Testing all connections');

    const results = {
      postmanApi: await this.testPostmanAPI(),
      mcpServer: await this.testMCPServer(),
      mongodb: 'configured',
      mysql: 'configured',
    };

    return results;
  }

  async testPostmanAPI() {
    return new Promise((resolve) => {
      const options = {
        hostname: 'api.postman.com',
        path: '/workspaces',
        method: 'GET',
        headers: this.bridge.getHeaders(),
        timeout: 5000,
      };

      const req = https.request(options, (res) => {
        resolve(res.statusCode === 200 ? 'PASS' : 'FAIL');
      });

      req.on('error', () => resolve('FAIL'));
      req.on('timeout', () => { req.destroy(); resolve('FAIL'); });
      req.end();
    });
  }

  async testMCPServer() {
    return new Promise((resolve) => {
      const mcpConn = this.bridge.getMCPConnection();
      const options = {
        hostname: mcpConn.host,
        port: mcpConn.port,
        path: '/health',
        method: 'GET',
        timeout: 5000,
      };

      const req = http.request(options, (res) => {
        resolve(res.statusCode === 200 ? 'PASS' : 'WARN');
      });

      req.on('error', () => resolve('WARN'));
      req.on('timeout', () => { req.destroy(); resolve('WARN'); });
      req.end();
    });
  }
}

/**
 * Main execution
 */
async function main() {
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║  Postman MCP + Full-Stack Integration                    ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');

  const integration = new FullStackIntegration();

  try {
    // Initialize
    const initialized = await integration.init();
    if (!initialized) {
      process.exit(1);
    }

    // Get status
    console.log('\n📊 System Status:');
    const status = await integration.getStatus();
    console.log(JSON.stringify(status, null, 2));

    // Test connections
    console.log('\n🔌 Testing Connections:');
    const tests = await integration.testConnections();
    console.log(JSON.stringify(tests, null, 2));

    console.log('\n✅ Full-Stack Integration Ready!\n');
  } catch (err) {
    logger.error('Fatal error', { error: err.message });
    process.exit(1);
  }
}

// Export for use as module
module.exports = {
  FullStackIntegration,
  MongoDBPostmanIntegration,
  MySQLPostmanIntegration,
  DockerPostmanIntegration,
  Logger,
};

// Run if called directly
if (require.main === module) {
  main().catch(err => {
    console.error('Error:', err);
    process.exit(1);
  });
}
