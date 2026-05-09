#!/bin/bash

###############################################################################
# Postman MCP Gist Sync Script
# Syncs all Postman MCP integration files to GitHub Gist
# Usage: bash postman-mcp-gist-sync.sh
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GIST_ID="3991f518ce5111b224258e07f5afe591"  # Enterprise Gist ID
WORKSPACE_DIR="/home/givenchi/FULL-STACK-HEAVY"
TEMP_DIR="/tmp/postman-mcp-gist-$RANDOM"

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

###############################################################################
# Step 1: Check Prerequisites
###############################################################################

check_prerequisites() {
    print_header "Step 1: Checking Prerequisites"

    # Check GitHub CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed"
        echo "Install from: https://cli.github.com/"
        exit 1
    fi

    print_success "GitHub CLI found: $(gh --version)"

    # Check authentication
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub"
        echo ""
        echo "Run: gh auth login"
        echo ""
        echo "Or set GITHUB_TOKEN:"
        echo "export GITHUB_TOKEN='your_pat_token'"
        exit 1
    fi

    print_success "GitHub authenticated as: $(gh auth status | grep 'Logged in' | awk '{print $NF}')"
}

###############################################################################
# Step 2: Prepare Files
###############################################################################

prepare_files() {
    print_header "Step 2: Preparing Files for Sync"

    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    print_success "Created temp directory: $TEMP_DIR"

    # Array of files to sync
    local FILES=(
        "postman-mcp-config.js"
        "postman-mcp-test.js"
        "postman-mcp-fullstack-integration.js"
        "postman-mcp-integrate.sh"
        ".env.postman.template"
        "POSTMAN_MCP_SETUP.md"
        "POSTMAN_MCP_INTEGRATION_SUMMARY.md"
        "POSTMAN_MCP_QUICK_START.txt"
    )

    # Copy files to temp directory
    for file in "${FILES[@]}"; do
        if [ -f "$WORKSPACE_DIR/$file" ]; then
            cp "$WORKSPACE_DIR/$file" "$TEMP_DIR/"
            print_success "Prepared: $file"
        else
            print_warning "File not found: $file (will skip)"
        fi
    done

    echo ""
    echo "Files ready in: $TEMP_DIR"
    ls -lh "$TEMP_DIR"
}

###############################################################################
# Step 3: Sync to Gist
###############################################################################

sync_to_gist() {
    print_header "Step 3: Syncing to GitHub Gist"

    print_info "Gist ID: $GIST_ID"
    print_info "URL: https://gist.github.com/$GIST_ID"
    echo ""

    # Clone gist
    print_info "Cloning gist to temporary location..."
    GIST_CLONE="/tmp/postman-mcp-gist-clone-$RANDOM"
    gh gist clone "$GIST_ID" "$GIST_CLONE"
    print_success "Gist cloned to: $GIST_CLONE"

    # Copy new files
    print_info "Copying Postman MCP files..."
    cp "$TEMP_DIR"/* "$GIST_CLONE/" 2>/dev/null || true

    # Update README
    create_gist_readme "$GIST_CLONE"

    # Commit and push
    print_info "Committing changes..."
    cd "$GIST_CLONE"
    git add .
    git commit -m "feat: Add Postman MCP Integration (May 9, 2026)" --allow-empty

    print_info "Pushing to GitHub..."
    git push

    print_success "Successfully synced to gist!"
    print_info "View changes: https://gist.github.com/$GIST_ID"

    cd - > /dev/null
}

###############################################################################
# Step 4: Create Gist README
###############################################################################

create_gist_readme() {
    local GIST_DIR=$1
    local README="$GIST_DIR/README_POSTMAN_MCP.md"

    cat > "$README" << 'EOF'
# 🔗 Postman MCP Integration for VS Code

Complete setup for integrating Postman API with VS Code MCP Server, with full support for Docker, MongoDB, and MySQL.

**Date:** May 9, 2026  
**API:** Postman PMAK-...  
**Status:** ✅ Production Ready

## 📦 Files Included

### Source Code (JavaScript/Node.js)
- `postman-mcp-config.js` — Main bridge configuration
- `postman-mcp-test.js` — Connection tests
- `postman-mcp-fullstack-integration.js` — Full-stack orchestrator
- `postman-mcp-integrate.sh` — Automated setup script

### Configuration
- `.env.postman.template` — Environment variables template
- `.env.postman` — Actual configuration (create from template)

### Documentation
- `POSTMAN_MCP_SETUP.md` — Comprehensive setup guide
- `POSTMAN_MCP_INTEGRATION_SUMMARY.md` — Complete overview
- `POSTMAN_MCP_QUICK_START.txt` — Quick reference

## 🚀 Quick Start

```bash
# 1. Clone from gist (if starting fresh)
gh gist clone 3991f518ce5111b224258e07f5afe591 postman-mcp
cd postman-mcp

# 2. Run setup
bash postman-mcp-integrate.sh

# 3. Test
node postman-mcp-test.js

# 4. Full-stack test
node postman-mcp-fullstack-integration.js
```

## 🔐 Security

- Environment variables stored in `.env.postman` (NOT in git)
- API keys masked in logs
- Permissions: `chmod 600 .env.postman`
- Never commit secrets

## 📞 Support

- See `POSTMAN_MCP_SETUP.md` for detailed documentation
- See `POSTMAN_MCP_QUICK_START.txt` for quick reference
- Contact: givens.abraham@live.com

---

**Maintained by:** Givens Emmah Abraham  
**Repository:** https://github.com/Givforks/MyNewHouse
EOF

    print_success "Created gist README: README_POSTMAN_MCP.md"
}

###############################################################################
# Step 5: Cleanup
###############################################################################

cleanup() {
    print_header "Step 5: Cleaning Up"

    print_info "Removing temporary directories..."
    rm -rf "$TEMP_DIR"
    rm -rf "/tmp/postman-mcp-gist-clone-$RANDOM" 2>/dev/null || true
    print_success "Cleanup complete"
}

###############################################################################
# Main
###############################################################################

main() {
    print_header "🔗 POSTMAN MCP GIST SYNC"

    echo "This script will sync all Postman MCP integration files to your GitHub Gist"
    echo ""
    print_info "Steps:"
    echo "  1. Check GitHub CLI authentication"
    echo "  2. Prepare files for upload"
    echo "  3. Clone your enterprise gist"
    echo "  4. Sync files to gist"
    echo "  5. Commit and push changes"
    echo ""

    read -p "$(echo -e "${BLUE}Continue? (y/n): ${NC}")" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Sync cancelled"
        exit 0
    fi

    # Run all steps
    check_prerequisites
    prepare_files
    sync_to_gist
    cleanup

    # Final summary
    print_header "✅ GIST SYNC COMPLETE"

    echo "All files have been synced to your gist!"
    echo ""
    print_success "View your gist: https://gist.github.com/$GIST_ID"
    echo ""
    echo "Next steps:"
    echo "  1. Review files on GitHub: https://gist.github.com/$GIST_ID"
    echo "  2. Share the gist link with your team"
    echo "  3. Use recovery commands to restore on new machines"
    echo ""
}

# Run main
main
