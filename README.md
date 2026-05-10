# MyNewHouse Development Templates

[![CI](https://github.com/Givforks/MyNewHouse/actions/workflows/ci.yml/badge.svg)](https://github.com/Givforks/MyNewHouse/actions)

Author: Givens Emmah Abraham

GitHub: https://github.com/Givforks
Website: http://www.givenchicodes.tech/
Location: Abuja, Nigeria

Contact:
- Phone: +96597967212
- WhatsApp: +96551032177

This repository stores reusable VS Code, linting, formatting, and project bootstrap templates for full-stack JavaScript work.

## What is included

- ESLint and Prettier configuration files
- VS Code workspace settings and extension recommendations
- Husky and lint-staged templates
- Project bootstrap script: `init_project.sh`
- Setup and recovery guides for future machines

## How to use it

1. Clone this repository.
2. Copy the template files into a new project.
3. Install the required dev dependencies.
4. Run `npm run prepare` in your project to activate Husky hooks.

See `SYNC_INSTRUCTIONS.md` for how to recover the setup after signing into VS Code.

## Postman MCP Quick Checks

Use these commands inside this workspace:

- `npm run postman:test` runs the default readiness check.
- `npm run postman:test:mock-mcp` runs the same check with an auto-mocked local MCP endpoint.
- `npm run postman:test:live` starts the local MCP server, runs the default readiness check, then stops the server.

Nx equivalents:

- `npx nx run full-stack-heavy:postman:test`
- `npx nx run full-stack-heavy:postman:test:mock-mcp`
- `npx nx run full-stack-heavy:postman:test:live`

## Circuit Breaker States

If you are documenting resilient services or API clients, the circuit breaker pattern has three states:

- Closed: normal operation; requests flow through as usual.
- Open: tripped or failing; requests are blocked to prevent more damage.
- Half-open: testing recovery; a small number of requests are allowed to see whether the service is healthy again.

These notes can be reused in API, backend, and microservice documentation.