# MySQL VS Code Setup

See also [DEV_TOOLS_SETUP.md](DEV_TOOLS_SETUP.md) for the broader reusable VS Code tool profile.

This workspace uses a local MySQL server with these working connection details:
- Host: 127.0.0.1
- Port: 3306
- User: Givenchicodes
- Auth: password stored in VS Code/extension secret storage, not in plain text

Verified facts:
- MySQL server is running locally
- `Givenchicodes@localhost` works on `127.0.0.1:3306`
- Local ports `2002` and `20020` are not the MySQL endpoint on this machine
- Root access also works locally through MySQL admin access

Recommended VS Code setup:
1. Install SQLTools
2. Install SQLTools MySQL/MariaDB driver
3. Create a connection using the host and port above
4. Save the password in the extension prompt or secret storage

If the system is rebuilt or the workspace is reopened, reuse the values above rather than starting from scratch.