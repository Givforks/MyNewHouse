# Developer Tools Setup

This workspace keeps a reusable VS Code setup for common project integrations.

Current working MySQL details:
- Host: 127.0.0.1
- Port: 3306
- User: Givenchicodes
- Password: store in VS Code or extension secret storage, not in plain text

Workspace integrations to keep installed and signed in when needed:
- MySQL / SQLTools
- AWS Toolkit
- Postman for VS Code
- Docker
- GitHub Pull Requests and Issues

MongoDB recovery notes:
- Working local URI: `mongodb://givens.abraham%40live.com:Givenchi1@localhost:27017/`
- Verified with `mongosh` and `db.runCommand({ ping: 1 })`
- Local MongoDB is currently running in Docker as `mongo-vscode-temp`
- Use VS Code Settings Sync so the extension state and signed-in profile can be restored after a crash or reinstall
- Store passwords and connection secrets in VS Code or extension secret storage, not in plain text files

Recovery notes:
- VS Code Settings Sync is enabled to help restore editor state after sign-in.
- See [MONGODB_RECONNECT.md](MONGODB_RECONNECT.md) for the quick reconnect steps.
- Use VS Code Settings Sync so extensions and editor preferences come back after a reinstall or crash.
- Use the extension sign-in flows for AWS, Postman, and GitHub instead of writing credentials into files.
- Keep account passwords and API keys in the OS keychain or the extension secret store.
- If a project needs another environment later, add it here instead of recreating the setup from scratch.

Verified local MySQL facts:
- MySQL is running locally.
- `Givenchicodes@localhost` works on `127.0.0.1:3306`.
- Local ports `2002` and `20020` are not the MySQL endpoint on this machine.