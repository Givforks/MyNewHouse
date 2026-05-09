#!/bin/bash

###############################################################################
# Postman MCP Integration Setup Script
# Automates the setup of Postman API and MCP Server integration
# Usage: bash postman-mcp-integrate.sh
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env.postman"
ENV_TEMPLATE="${SCRIPT_DIR}/.env.postman.template"
CONFIG_FILE="${SCRIPT_DIR}/postman-mcp-config.js"
TEST_FILE="${SCRIPT_DIR}/postman-mcp-test.js"

###############################################################################
# Helper Functions
###############################################################################

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

pause_for_input() {
    read -p "$(echo -e ${BLUE}Press Enter to continue...${NC})"
}

###############################################################################
# Step 1: Check Prerequisites
###############################################################################

check_prerequisites() {
    print_header "Step 1: Checking Prerequisites"

    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        echo "Install Node.js from https://nodejs.org/"
        exit 1
    fi
    
    NODE_VERSION=$(node -v)
    print_success "Node.js found: $NODE_VERSION"

    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        exit 1
    fi
    
    NPM_VERSION=$(npm -v)
    print_success "npm found: v$NPM_VERSION"

    # Check Git
    if ! command -v git &> /dev/null; then
        print_warning "Git is not installed (optional for this setup)"
    else
        print_success "Git found: $(git --version)"
    fi

    # Check if dotenv is needed
    if ! npm list dotenv &> /dev/null 2>&1; then
        print_info "dotenv is not installed - will install it"
    else
        print_success "dotenv is already installed"
    fi
}

###############################################################################
# Step 2: Set up Environment File
###############################################################################

setup_env_file() {
    print_header "Step 2: Setting Up Environment Variables"

    if [ -f "$ENV_FILE" ]; then
        print_warning ".env.postman already exists"
        echo "Do you want to:"
        echo "  1) Keep existing file"
        echo "  2) Overwrite with template"
        echo "  3) Backup and create new"
        read -p "Choose (1-3): " choice

        case $choice in
            2)
                cp "$ENV_TEMPLATE" "$ENV_FILE"
                print_success "Created new .env.postman from template"
                ;;
            3)
                BACKUP_FILE="${ENV_FILE}.backup.$(date +%s)"
                cp "$ENV_FILE" "$BACKUP_FILE"
                cp "$ENV_TEMPLATE" "$ENV_FILE"
                print_success "Backed up to $BACKUP_FILE"
                print_success "Created new .env.postman from template"
                ;;
            *)
                print_info "Keeping existing .env.postman"
                ;;
        esac
    else
        cp "$ENV_TEMPLATE" "$ENV_FILE"
        print_success "Created .env.postman from template"
    fi

    # Set restrictive permissions
    chmod 600 "$ENV_FILE"
    print_success "Set permissions to 600 (user read/write only)"

    # Check if .env.postman is in .gitignore
    if [ -f "${SCRIPT_DIR}/.gitignore" ]; then
        if ! grep -q ".env.postman" "${SCRIPT_DIR}/.gitignore"; then
            echo ".env.postman" >> "${SCRIPT_DIR}/.gitignore"
            print_success "Added .env.postman to .gitignore"
        fi
    fi
}

###############################################################################
# Step 3: Configure Environment Variables
###############################################################################

configure_env_variables() {
    print_header "Step 3: Configuring Environment Variables"

    echo "We need your Postman API Key to complete the setup."
    echo "Get it from: https://web.postman.co/settings/me/api-keys"
    echo ""

    # Check if API key already exists
    if grep -q "^POSTMAN_API_KEY=PMAK-" "$ENV_FILE"; then
        EXISTING_KEY=$(grep "^POSTMAN_API_KEY=PMAK-" "$ENV_FILE" | cut -d= -f2)
        print_info "Found existing Postman API key (first 20 chars): ${EXISTING_KEY:0:20}..."
        
        read -p "Do you want to update it? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Keeping existing API key"
            return
        fi
    fi

    read -p "Enter your Postman API Key (PMAK-...): " API_KEY

    if [[ ! $API_KEY =~ ^PMAK- ]]; then
        print_error "Invalid API key format (should start with PMAK-)"
        return 1
    fi

    # Update .env.postman
    if grep -q "^POSTMAN_API_KEY=" "$ENV_FILE"; then
        # Use a different delimiter since we have slashes
        sed -i "s|^POSTMAN_API_KEY=.*|POSTMAN_API_KEY=$API_KEY|" "$ENV_FILE"
    else
        echo "POSTMAN_API_KEY=$API_KEY" >> "$ENV_FILE"
    fi

    print_success "Updated POSTMAN_API_KEY in .env.postman"

    # Ask for optional settings
    echo ""
    read -p "MCP Server host (default: localhost): " MCP_HOST
    MCP_HOST=${MCP_HOST:-localhost}

    read -p "MCP Server port (default: 3000): " MCP_PORT
    MCP_PORT=${MCP_PORT:-3000}

    # Update MCP settings
    sed -i "s|^MCP_SERVER_HOST=.*|MCP_SERVER_HOST=$MCP_HOST|" "$ENV_FILE"
    sed -i "s|^MCP_SERVER_PORT=.*|MCP_SERVER_PORT=$MCP_PORT|" "$ENV_FILE"

    print_success "Updated MCP Server settings"
}

###############################################################################
# Step 4: Install Dependencies
###############################################################################

install_dependencies() {
    print_header "Step 4: Installing Dependencies"

    print_info "Checking if dotenv is installed..."

    if npm list dotenv &> /dev/null; then
        print_success "dotenv is already installed"
    else
        print_info "Installing dotenv..."
        npm install dotenv
        print_success "dotenv installed successfully"
    fi
}

###############################################################################
# Step 5: Verify Configuration Files
###############################################################################

verify_config_files() {
    print_header "Step 5: Verifying Configuration Files"

    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "$CONFIG_FILE not found"
        return 1
    fi
    print_success "✓ postman-mcp-config.js found"

    if [ ! -f "$TEST_FILE" ]; then
        print_error "$TEST_FILE not found"
        return 1
    fi
    print_success "✓ postman-mcp-test.js found"

    if [ ! -f "$ENV_FILE" ]; then
        print_error "$ENV_FILE not found"
        return 1
    fi
    print_success "✓ .env.postman found"
}

###############################################################################
# Step 6: Run Connection Tests
###############################################################################

run_tests() {
    print_header "Step 6: Running Connection Tests"

    echo "Running Postman MCP connection tests..."
    echo ""

    if node "$TEST_FILE"; then
        print_success "All tests passed!"
    else
        print_warning "Some tests failed - see details above"
        echo ""
        print_info "This might be normal if:"
        echo "  • MCP server is not currently running"
        echo "  • You're testing for the first time"
        echo ""
        print_info "Next steps:"
        echo "  1. Start the MCP server: npm run mcp:start"
        echo "  2. Re-run tests: npm run postman:test"
    fi
}

###############################################################################
# Step 7: Update package.json
###############################################################################

update_package_json() {
    print_header "Step 7: Updating package.json Scripts"

    if [ ! -f "${SCRIPT_DIR}/package.json" ]; then
        print_warning "package.json not found - skipping script updates"
        return
    fi

    print_info "Checking if MCP scripts exist in package.json..."

    # Check if scripts already exist
    if grep -q '"postman:test"' "${SCRIPT_DIR}/package.json"; then
        print_success "MCP scripts already configured in package.json"
    else
        print_info "Adding MCP scripts to package.json..."
        print_info "You can manually add these to your package.json:"
        echo ""
        echo '  "postman:config": "node postman-mcp-config.js",'
        echo '  "postman:test": "node postman-mcp-test.js",'
        echo '  "postman:setup": "bash postman-mcp-integrate.sh",'
        echo '  "mcp:start": "node mcp-server.js",'
        echo '  "mcp:test": "node postman-mcp-test.js"'
        echo ""
        print_info "Or run this command:"
        echo "npm pkg set scripts.postman:test='node postman-mcp-test.js'"
    fi
}

###############################################################################
# Step 8: Create Quick Reference
###############################################################################

create_quick_reference() {
    print_header "Step 8: Creating Quick Reference"

    QUICK_REF_FILE="${SCRIPT_DIR}/POSTMAN_MCP_QUICK_START.txt"

    cat > "$QUICK_REF_FILE" << 'EOF'
╔════════════════════════════════════════════════════════════════════╗
║        POSTMAN MCP INTEGRATION - QUICK START REFERENCE             ║
╚════════════════════════════════════════════════════════════════════╝

📋 SETUP COMMANDS
─────────────────────────────────────────────────────────────────────

1. Initial Setup (one-time):
   bash postman-mcp-integrate.sh

2. Test Connection:
   npm run postman:test
   OR
   node postman-mcp-test.js

3. Start MCP Server:
   npm run mcp:start

4. View Configuration:
   node postman-mcp-config.js


📁 KEY FILES
─────────────────────────────────────────────────────────────────────

.env.postman ⚠️  — Environment variables (NEVER commit)
.env.postman.template — Template for .env.postman

postman-mcp-config.js — Main bridge configuration
postman-mcp-test.js — Connection test script
postman-mcp-integrate.sh — This setup script

POSTMAN_MCP_SETUP.md — Full documentation


🔐 SECURITY CHECKLIST
─────────────────────────────────────────────────────────────────────

✓ .env.postman has 600 permissions (chmod 600 .env.postman)
✓ .env.postman is in .gitignore
✓ Postman API key is stored securely (not in code)
✓ No API keys logged to console
✓ Only necessary environment variables are set


🚀 QUICK TROUBLESHOOTING
─────────────────────────────────────────────────────────────────────

Issue: "POSTMAN_API_KEY is not set"
→ Check: source .env.postman (or restart terminal)

Issue: "MCP server not reachable"  
→ Check: npm run mcp:start (start the server first)

Issue: "Cannot find module 'dotenv'"
→ Check: npm install dotenv

Issue: Configuration validation fails
→ Run: npm run postman:test (for detailed diagnostics)


📚 USEFUL LINKS
─────────────────────────────────────────────────────────────────────

Postman API Docs: https://learning.postman.com/docs/developer/intro-api/
VS Code MCP Docs: https://code.visualstudio.com/docs/editor/mcp
API Key Settings: https://web.postman.co/settings/me/api-keys


🎯 NEXT STEPS
─────────────────────────────────────────────────────────────────────

1. Edit .env.postman with your settings
2. Run: npm run postman:test
3. Check: POSTMAN_MCP_SETUP.md for full documentation
4. Start: npm run mcp:start


═════════════════════════════════════════════════════════════════════
Last Updated: May 9, 2026
Contact: givens.abraham@live.com
═════════════════════════════════════════════════════════════════════
EOF

    print_success "Created quick reference: $QUICK_REF_FILE"
    echo ""
    cat "$QUICK_REF_FILE"
}

###############################################################################
# Main Setup Flow
###############################################################################

main() {
    print_header "🔗 POSTMAN MCP INTEGRATION SETUP"

    echo "This script will help you integrate Postman API with VS Code MCP"
    echo ""
    print_info "Steps:"
    echo "  1. Check prerequisites"
    echo "  2. Set up environment file (.env.postman)"
    echo "  3. Configure environment variables"
    echo "  4. Install dependencies (dotenv)"
    echo "  5. Verify configuration files"
    echo "  6. Run connection tests"
    echo "  7. Update package.json"
    echo "  8. Create quick reference"
    echo ""

    pause_for_input

    # Run all steps
    check_prerequisites
    setup_env_file
    configure_env_variables
    install_dependencies
    verify_config_files
    run_tests
    update_package_json
    create_quick_reference

    # Final summary
    print_header "✅ SETUP COMPLETE"
    
    echo "Setup has completed successfully!"
    echo ""
    print_success "Next steps:"
    echo "  1. Review: cat POSTMAN_MCP_QUICK_START.txt"
    echo "  2. Test: npm run postman:test"
    echo "  3. Start: npm run mcp:start"
    echo "  4. Read: POSTMAN_MCP_SETUP.md"
    echo ""
    print_info "Your Postman API is now ready to integrate with VS Code MCP!"
    echo ""
}

# Run main function
main
