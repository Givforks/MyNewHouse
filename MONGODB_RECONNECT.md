# MongoDB Reconnect Guide

Use this when VS Code or the system needs MongoDB restored quickly after a crash or reinstall.

## Working Connection

- URI: `mongodb://givens.abraham%40live.com:Givenchi1@localhost:27017/`
- Status: verified with `mongosh` and `db.runCommand({ ping: 1 })`

## VS Code Steps

1. Open VS Code.
2. Open the Command Palette with `Ctrl+Shift+P`.
3. Run `MongoDB: Connect`.
4. Choose `Paste connection string`.
5. Paste the working URI above.
6. When prompted, choose `Save connection` and give it a name like `local-mongo`.
7. Open the MongoDB sidebar and click the saved connection to reconnect.

## If the connection fails

- Confirm the local MongoDB container is running.
- Re-test with:

```bash
mongosh "mongodb://givens.abraham%40live.com:Givenchi1@localhost:27017/" --eval "db.runCommand({ping:1})"
```

- If the container is missing, recreate it with Docker and then reconnect in VS Code.