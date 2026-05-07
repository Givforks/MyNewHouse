# ⚙️ VS Code Settings for Development Environment

## Recommended .vscode/settings.json
Add to your project's `.vscode/settings.json`:

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "prettier.semi": true,
  "prettier.singleQuote": true,
  "prettier.trailingComma": "es5",
  "prettier.tabWidth": 2,
  "prettier.printWidth": 100,
  
  "eslint.enable": true,
  "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
  "eslint.format.enable": true,
  "eslint.codeActionsOnSave.mode": "all",
  
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.eslint": "explicit"
    }
  },
  
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.wordWrap": "on"
  },
  
  "files.exclude": {
    "node_modules": true,
    ".git": true,
    "dist": true,
    "build": true,
    ".next": true
  },
  
  "search.exclude": {
    "node_modules": true,
    "dist": true,
    "build": true
  }
}
```

## Recommended .vscode/extensions.json
Create `.vscode/extensions.json` in your project:

```json
{
  "recommendations": [
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    "editorconfig.editorconfig",
    "ms-vscode.makefile-tools",
    "GitHub.copilot",
    "mongodb.mongodb-vscode",
    "ms-vscode.vscode-sql-database",
    "ms-docker.docker",
    "eamodio.gitlens",
    "ms-postman.postman"
  ]
}
```

## Keyboard Shortcuts
Add to `.vscode/keybindings.json` for quick access:

```json
[
  {
    "key": "alt+l",
    "command": "eslint.executeAutofix"
  },
  {
    "key": "alt+f",
    "command": "editor.action.formatDocument"
  }
]
```

**Alt+L** → Auto-fix ESLint errors  
**Alt+F** → Format document with Prettier

## Global VS Code Settings
These apply everywhere (open `.vscode/settings.json` in user profile):

```json
{
  "editor.formatOnSave": true,
  "editor.formatOnPaste": false,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.wordWrap": "on",
  "editor.fontSize": 14,
  "editor.fontFamily": "'Fira Code', 'Courier New', monospace",
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "git.autofetch": true,
  "git.autoRepositoryDetection": "openEditors",
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
```

---

**All settings ready! Copy to `.vscode/` folder in each project.**
