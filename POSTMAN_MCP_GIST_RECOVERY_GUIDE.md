# 📦 Postman MCP - Gist Sync & Recovery Guide

## Overview

This guide explains how to sync your Postman MCP integration to GitHub Gist and recover it on new machines.

**Gist ID:** 3991f518ce5111b224258e07f5afe591  
**Gist URL:** https://gist.github.com/Givforks/3991f518ce5111b224258e07f5afe591

---

## 📤 Syncing to Gist

### Method 1: Using the Automated Script (Recommended)

```bash
cd /home/givenchi/FULL-STACK-HEAVY

# Run the sync script
bash postman-mcp-gist-sync.sh
```

This will:
1. ✅ Verify GitHub authentication
2. ✅ Prepare all files
3. ✅ Clone your gist
4. ✅ Sync new/updated files
5. ✅ Push changes to GitHub

### Method 2: Manual Sync with GitHub CLI

```bash
# 1. Clone your gist
export GITHUB_TOKEN="your_pat_here"
gh gist clone 3991f518ce5111b224258e07f5afe591 postman-mcp-gist
cd postman-mcp-gist

# 2. Copy files from workspace
cp /home/givenchi/FULL-STACK-HEAVY/postman-mcp-*.{js,sh} .
cp /home/givenchi/FULL-STACK-HEAVY/.env.postman.template .
cp /home/givenchi/FULL-STACK-HEAVY/POSTMAN_MCP_*.md .

# 3. Commit and push
git add .
git commit -m "feat: Update Postman MCP Integration (May 9, 2026)"
git push

# 4. Done!
echo "View at: https://gist.github.com/Givforks/3991f518ce5111b224258e07f5afe591"
```

### Method 3: Manual Sync via Web UI

1. Go to: https://gist.github.com/Givforks/3991f518ce5111b224258e07f5afe591
2. Click "Edit"
3. Add each file:
   - `postman-mcp-config.js`
   - `postman-mcp-test.js`
   - `postman-mcp-fullstack-integration.js`
   - `postman-mcp-integrate.sh`
   - `.env.postman.template`
   - `POSTMAN_MCP_SETUP.md`
   - `POSTMAN_MCP_INTEGRATION_SUMMARY.md`
4. Click "Update public gist"

---

## 📥 Recovery on New Machine

### Quick Recovery (Automated)

```bash
# 1. Set GitHub token
export GITHUB_TOKEN="your_pat_here"

# 2. Clone and setup
gh gist clone 3991f518ce5111b224258e07f5afe591 postman-mcp-setup
cd postman-mcp-setup

# 3. Run setup
bash postman-mcp-integrate.sh

# 4. Test
npm run postman:test
```

### Step-by-Step Recovery

#### Step 1: Install Prerequisites

```bash
# Node.js 18+ (or 20+ recommended)
node --version
npm --version

# GitHub CLI
gh --version

# If missing, install:
# Node: https://nodejs.org/
# GitHub CLI: https://cli.github.com/
```

#### Step 2: Authenticate with GitHub

```bash
# Option A: Interactive login
gh auth login

# Option B: Use existing token
export GITHUB_TOKEN="your_pat_here"
gh auth status
```

#### Step 3: Clone the Gist

```bash
# Clone to a working directory
gh gist clone 3991f518ce5111b224258e07f5afe591 postman-mcp-setup
cd postman-mcp-setup

# Verify files
ls -la
```

#### Step 4: Run Setup

```bash
# Make setup script executable
chmod +x postman-mcp-integrate.sh

# Run setup
bash postman-mcp-integrate.sh

# This will:
# ✅ Check prerequisites
# ✅ Create .env.postman
# ✅ Install dependencies
# ✅ Run tests
# ✅ Create quick reference
```

#### Step 5: Configure API Key

When prompted during setup:

```bash
Enter your Postman API Key (PMAK-...): 
PMAK-REPLACE_WITH_YOUR_API_KEY

MCP Server host (default: localhost): [ENTER]

MCP Server port (default: 3000): [ENTER]
```

#### Step 6: Verify Setup

```bash
# Test Postman API connectivity
node postman-mcp-test.js

# Test full-stack integration
node postman-mcp-fullstack-integration.js

# Expected output:
# ✅ Configuration: PASS
# ✅ Postman API: PASS
# ⚠️  MCP Server: WARN (normal if not running)
# ✅ MongoDB: CONFIGURED
# ✅ MySQL: CONFIGURED
```

---

## 🔄 Updating the Gist

### Update Files When You Make Changes

```bash
# 1. Make changes in /home/givenchi/FULL-STACK-HEAVY/

# 2. Copy updated files to gist clone
cd /tmp/postman-mcp-gist-clone
cp /home/givenchi/FULL-STACK-HEAVY/postman-mcp-config.js .

# 3. Commit and push
git add .
git commit -m "fix: Update postman-mcp-config.js"
git push

# OR use the automated script
bash /home/givenchi/FULL-STACK-HEAVY/postman-mcp-gist-sync.sh
```

### Schedule Regular Syncs

```bash
# Add to crontab for weekly sync
# Run: crontab -e
# Add this line:

# Weekly sync (every Sunday at 2 AM)
0 2 * * 0 cd /home/givenchi/FULL-STACK-HEAVY && bash postman-mcp-gist-sync.sh >> /tmp/postman-mcp-sync.log 2>&1
```

---

## 🔐 Managing the API Key Securely

### On Your Primary Machine

```bash
# 1. Store in .env.postman (not committed to git)
echo "POSTMAN_API_KEY=PMAK-..." > .env.postman

# 2. Set restrictive permissions
chmod 600 .env.postman

# 3. Verify it's in .gitignore
echo ".env.postman" >> .gitignore
```

### On Restored Machines

```bash
# The .env.postman.template is synced to the gist
# Create .env.postman from template:

cp .env.postman.template .env.postman
chmod 600 .env.postman

# Edit to add your API key:
nano .env.postman
# Add: POSTMAN_API_KEY=PMAK-...

# Test:
node postman-mcp-test.js
```

### Alternative: Use GitHub Secrets (For Teams)

```bash
# Store API key in GitHub as a secret
# Then in your gist/workflow, retrieve it:

if [ -z "$POSTMAN_API_KEY" ]; then
  export POSTMAN_API_KEY=$(gh secret get POSTMAN_API_KEY)
fi
```

---

## 📋 Gist File Manifest

All files synced to the gist:

```
README_POSTMAN_MCP.md                 # Gist README
postman-mcp-config.js                 # Bridge configuration
postman-mcp-test.js                   # Connection tests
postman-mcp-fullstack-integration.js  # Full-stack orchestrator
postman-mcp-integrate.sh              # Automated setup
postman-mcp-gist-sync.sh              # Gist sync script
.env.postman.template                 # Environment template
POSTMAN_MCP_SETUP.md                  # Setup guide
POSTMAN_MCP_INTEGRATION_SUMMARY.md   # Complete overview
POSTMAN_MCP_QUICK_START.txt          # Quick reference
POSTMAN_MCP_GIST_RECOVERY_GUIDE.md   # This file
```

---

## 🚨 Troubleshooting

### Issue: "gh auth status - not authenticated"

**Solution:**
```bash
# Option 1: Interactive login
gh auth login

# Option 2: Use PAT token
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxx"
gh auth status
```

### Issue: "Cannot push to gist"

**Solution:**
```bash
# Verify authentication
gh auth status

# Check if you own the gist
gh gist view 3991f518ce5111b224258e07f5afe591

# If issues persist, clone with auth:
export GITHUB_TOKEN="your_token"
gh gist clone 3991f518ce5111b224258e07f5afe591
```

### Issue: "Setup fails with timeout"

**Solution:**
```bash
# Increase timeout in .env.postman
echo "API_REQUEST_TIMEOUT=10000" >> .env.postman

# Re-run setup
bash postman-mcp-integrate.sh
```

### Issue: Files not syncing

**Solution:**
```bash
# 1. Verify files exist
ls -la /home/givenchi/FULL-STACK-HEAVY/postman-mcp-*

# 2. Check permissions
chmod +x /home/givenchi/FULL-STACK-HEAVY/postman-mcp-gist-sync.sh

# 3. Run sync with debugging
bash -x /home/givenchi/FULL-STACK-HEAVY/postman-mcp-gist-sync.sh
```

---

## 📞 Quick Reference

### Essential Commands

```bash
# One-time setup
bash postman-mcp-integrate.sh

# Test connection
node postman-mcp-test.js

# Test full-stack
node postman-mcp-fullstack-integration.js

# View configuration
node -e "const {PostmanMCPBridge} = require('./postman-mcp-config'); console.log(new PostmanMCPBridge().getConfig());"

# Sync to gist
bash postman-mcp-gist-sync.sh

# Clone from gist
gh gist clone 3991f518ce5111b224258e07f5afe591 postman-mcp-setup

# View gist online
open https://gist.github.com/Givforks/3991f518ce5111b224258e07f5afe591
```

### Key Environment Variables

```bash
# Postman
POSTMAN_API_KEY=PMAK-...
POSTMAN_BASE_URL=https://api.postman.com

# MCP Server
MCP_SERVER_HOST=localhost
MCP_SERVER_PORT=3000

# Databases
MONGODB_URI=mongodb://...
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306

# Settings
NODE_ENV=development
LOG_LEVEL=info
API_REQUEST_TIMEOUT=5000
```

---

## 🎯 Best Practices

### 1. Keep Secrets Secure

- ✅ Never commit `.env.postman`
- ✅ Always use `.env.postman.template` for sharing
- ✅ Set `chmod 600` on `.env.postman`
- ✅ Use GitHub Secrets for CI/CD

### 2. Regular Backups

```bash
# Sync to gist regularly
bash postman-mcp-gist-sync.sh

# Or add to crontab:
# Weekly backup
0 2 * * 0 cd /home/givenchi/FULL-STACK-HEAVY && bash postman-mcp-gist-sync.sh
```

### 3. Version Control

```bash
# Track changes to setup files (except .env.postman)
git add postman-mcp-*.js
git add postman-mcp-*.sh
git add .env.postman.template
git add POSTMAN_MCP_*.md
git commit -m "feat: Update Postman MCP integration"
```

### 4. Disaster Recovery Plan

1. ✅ Keep gist up to date
2. ✅ Document your setup
3. ✅ Store API key securely (not in git)
4. ✅ Use Settings Sync for VS Code
5. ✅ Test recovery procedure regularly

---

## 📚 Related Documentation

- [POSTMAN_MCP_SETUP.md](./POSTMAN_MCP_SETUP.md) — Comprehensive setup guide
- [POSTMAN_MCP_INTEGRATION_SUMMARY.md](./POSTMAN_MCP_INTEGRATION_SUMMARY.md) — Complete overview
- [POSTMAN_MCP_QUICK_START.txt](./POSTMAN_MCP_QUICK_START.txt) — Quick reference
- [ENTERPRISE_GIST_SUMMARY.md](./ENTERPRISE_GIST_SUMMARY.md) — Full enterprise setup

---

## 🎓 Learning Resources

- **Postman API Docs**: https://learning.postman.com/docs/developer/intro-api/
- **VS Code MCP**: https://code.visualstudio.com/docs/editor/mcp
- **GitHub Gist CLI**: https://cli.github.com/manual/gh_gist
- **GitHub Actions**: https://docs.github.com/en/actions

---

## 📞 Support

For issues or questions:

1. Check troubleshooting section above
2. Review related documentation files
3. Contact: givens.abraham@live.com
4. GitHub: https://github.com/Givforks

---

**Last Updated:** May 9, 2026  
**Maintained by:** Givens Emmah Abraham  
**Enterprise Gist:** https://gist.github.com/Givforks/3991f518ce5111b224258e07f5afe591
