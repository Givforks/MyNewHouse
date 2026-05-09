/**
 * Postman MCP Configuration Bridge
 * Connects Postman API to VS Code MCP Server
 * Environment: JavaScript (Node.js compatible)
 */

const {
  loadPostmanEnvironment,
  getPostmanSettings,
  maskSecret,
} = require('./libs/shared-config/src');

loadPostmanEnvironment();

const settings = getPostmanSettings();

/**
 * Postman MCP Configuration
 */
class PostmanMCPBridge {
  constructor() {
    if (!settings.postmanApiKey) {
      throw new Error('Postman API key is not set in .env.postman');
    }
    this.apiKey = settings.postmanApiKey;
    this.baseUrl = settings.postmanBaseUrl;
    this.mcpHost = settings.mcpServerHost;
    this.mcpPort = settings.mcpServerPort;
  }

  /**
   * Get Postman API headers
   */
  getHeaders() {
    return {
      'X-API-Key': this.apiKey,
      'Content-Type': 'application/json',
    };
  }

  /**
   * Get MCP connection details
   */
  getMCPConnection() {
    return {
      host: this.mcpHost,
      port: this.mcpPort,
      url: `http://${this.mcpHost}:${this.mcpPort}`,
    };
  }

  /**
   * Build Postman API endpoint
   */
  buildEndpoint(resource) {
    return `${this.baseUrl}${resource}`;
  }

  /**
   * Validate configuration
   */
  validate() {
    const checks = {
      apiKeyPresent: !!this.apiKey,
      baseUrlValid: this.baseUrl.startsWith('https://'),
      mcpHostValid: this.mcpHost.length > 0,
      mcpPortValid: this.mcpPort > 0 && this.mcpPort < 65536,
    };

    const allValid = Object.values(checks).every(v => v === true);
    return { valid: allValid, checks };
  }

  /**
   * Get configuration summary
   */
  getConfig() {
    return {
      postman: {
        apiUrl: this.baseUrl,
        apiKeyPrefix: maskSecret(this.apiKey),
      },
      mcp: {
        host: this.mcpHost,
        port: this.mcpPort,
        connectionUrl: `http://${this.mcpHost}:${this.mcpPort}`,
      },
    };
  }
}

module.exports = {
  PostmanMCPBridge,
  config: {
    postmanApiKey: settings.postmanApiKey,
    postmanBaseUrl: settings.postmanBaseUrl,
    mcpServerHost: settings.mcpServerHost,
    mcpServerPort: settings.mcpServerPort,
  },
};
