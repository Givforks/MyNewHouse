# Environment Quick Start

Use this after cloning or syncing the repository to get the Nx/Postman environment running again quickly.

## One-time setup

```bash
cd /home/givenchi/FULL-STACK-HEAVY
cp .env.postman.template .env.postman
npm install
```

## Validate the workspace

```bash
npx nx show projects
npx nx run full-stack-heavy:postman:test
npx nx run full-stack-heavy:postman:test:mock-mcp
```

## Helpful modes

- Default mode keeps the real MCP health check and will warn if nothing is listening on `localhost:3000`.
- Mock mode starts a temporary health server and gives a fully green local run.

```bash
MCP_AUTO_MOCK=1 node postman-mcp-test.js
```

## After pulling updates

```bash
git checkout main
git pull origin main
npx nx show projects
```
