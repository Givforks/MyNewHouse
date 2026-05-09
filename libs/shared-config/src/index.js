const dotenv = require('dotenv');

const DEFAULT_POSTMAN_BASE_URL = 'https://api.postman.com';
const DEFAULT_MCP_SERVER_HOST = 'localhost';
const DEFAULT_MCP_SERVER_PORT = 3000;
const DEFAULT_LOG_LEVEL = 'info';
const DEFAULT_NODE_ENV = 'development';

function loadPostmanEnvironment(envPath = '.env.postman') {
  const result = dotenv.config({ path: envPath });

  if (result.error && result.error.code !== 'ENOENT') {
    throw result.error;
  }

  return result;
}

function toPort(value, fallback) {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

function maskSecret(value, visibleStart = 10, visibleEnd = 4) {
  if (!value) {
    return 'N/A';
  }

  if (value.length <= visibleStart + visibleEnd) {
    return `${value.slice(0, 4)}...`;
  }

  return `${value.substring(0, visibleStart)}...${value.substring(value.length - visibleEnd)}`;
}

function getPostmanSettings() {
  return {
    postmanApiKey: process.env.POSTMAN_API_KEY,
    postmanBaseUrl: process.env.POSTMAN_BASE_URL || DEFAULT_POSTMAN_BASE_URL,
    mcpServerHost: process.env.MCP_SERVER_HOST || DEFAULT_MCP_SERVER_HOST,
    mcpServerPort: toPort(process.env.MCP_SERVER_PORT, DEFAULT_MCP_SERVER_PORT),
    mongoUri: process.env.MONGODB_URI,
    mysqlHost: process.env.MYSQL_HOST,
    mysqlPort: toPort(process.env.MYSQL_PORT, 3306),
    mysqlUser: process.env.MYSQL_USER,
    logLevel: process.env.LOG_LEVEL || DEFAULT_LOG_LEVEL,
    dockerEnv: process.env.DOCKER_ENV || DEFAULT_NODE_ENV,
    nodeEnv: process.env.NODE_ENV || DEFAULT_NODE_ENV,
  };
}

module.exports = {
  loadPostmanEnvironment,
  getPostmanSettings,
  maskSecret,
};
