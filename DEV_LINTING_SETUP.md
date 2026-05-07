# 🛠️ Development Environment Setup Guide

## Global Tools Installed
- ✅ **ESLint** — Code quality & error detection
- ✅ **Prettier** — Code formatting
- ✅ **Airbnb Config** — Strict JavaScript style guide
- ✅ **Husky** — Git hooks for auto-linting

## Project Setup for New Projects

### 1. Initialize a New Project
```bash
mkdir my-project && cd my-project
npm init -y
```

### 2. Install Dev Dependencies
```bash
npm install --save-dev eslint prettier eslint-config-airbnb-base eslint-plugin-import lint-staged husky
```

### 3. Copy Template Configs
Copy these files from `/FULL-STACK-HEAVY/` to your new project:
- `.eslintrc.json`
- `.prettierrc.json`
- `.eslintignore`
- `.prettierignore`

### 4. Add NPM Scripts to package.json
```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "prepare": "husky install"
  }
}
```

### 5. Setup Git Hooks with Husky
```bash
npm run prepare
husky add .husky/pre-commit "npx lint-staged"
husky add .husky/pre-push "npm run lint"
```

### 6. Configure lint-staged (.lintstagedrc.json)
```json
{
  "*.js": ["eslint --fix", "prettier --write"],
  "*.json": ["prettier --write"],
  "*.md": ["prettier --write"]
}
```

## VS Code Extensions (Already Installed)
- ESLint
- Prettier - Code formatter
- EditorConfig for VS Code

## Usage

### Lint Your Code
```bash
npm run lint           # Check for errors
npm run lint:fix      # Auto-fix errors
```

### Format Your Code
```bash
npm run format        # Auto-format all files
npm run format:check  # Check formatting without changing
```

### Git Workflow
Commits will automatically be linted before they're created. Pushes will be checked for ESLint errors.

## Node Version Note
Your current Node version (18.19.1) works, but ESLint 10+ recommends Node 20+. To upgrade:
```bash
nvm install 20
nvm use 20
```

## Quick Reference
| Command | Purpose |
|---------|---------|
| `npm run lint` | Check code quality |
| `npm run lint:fix` | Auto-fix linting errors |
| `npm run format` | Auto-format code |
| `npm run prepare` | Setup git hooks |

---
**All configs are ready in `/FULL-STACK-HEAVY/` — copy to each new project!**
