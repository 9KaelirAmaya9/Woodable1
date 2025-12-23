#!/bin/bash
# ============================================
# Staging Deployment Checklist
# ============================================
# Interactive checklist to guide through staging deployment
# Usage: ./scripts/staging-checklist.sh

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}║         Rico's Tacos - Staging Deployment Checklist       ║${NC}"
echo -e "${CYAN}║                                                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        return 1
    fi
}

# Function to check if env var is set in file
check_env_var() {
    local file="$1"
    local var="$2"
    if [ -f "$file" ]; then
        if grep -q "^${var}=" "$file" && ! grep -q "^${var}=CHANGE_ME" "$file" && ! grep -q "^${var}=$" "$file"; then
            echo -e "${GREEN}✓${NC}"
            return 0
        fi
    fi
    echo -e "${RED}✗${NC}"
    return 1
}

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Phase 1: Prerequisites${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -n "  Python 3 installed: "
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✓${NC} ($(python3 --version))"
else
    echo -e "${RED}✗${NC}"
    echo -e "    ${YELLOW}Install Python 3.10+${NC}"
fi

echo -n "  Node.js installed: "
if command -v node &> /dev/null; then
    echo -e "${GREEN}✓${NC} ($(node --version))"
else
    echo -e "${RED}✗${NC}"
    echo -e "    ${YELLOW}Install Node.js 18+${NC}"
fi

echo -n "  Git installed: "
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓${NC} ($(git --version | cut -d' ' -f3))"
else
    echo -e "${RED}✗${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Phase 2: Third-Party Accounts${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo "  Have you created accounts for:"
echo -n "    • Digital Ocean: "
read -p "" -n 1 -r
echo ""
echo -n "    • Stripe (test mode): "
read -p "" -n 1 -r
echo ""
echo -n "    • SendGrid: "
read -p "" -n 1 -r
echo ""
echo -n "    • Google Cloud (Maps API): "
read -p "" -n 1 -r
echo ""

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Phase 3: Environment Configuration${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -n "  .env.staging file exists: "
check_file ".env.staging"
ENV_EXISTS=$?

if [ $ENV_EXISTS -eq 0 ]; then
    echo ""
    echo "  Checking required variables in .env.staging:"
    echo -n "    • DO_API_TOKEN: "
    check_env_var ".env.staging" "DO_API_TOKEN"
    echo -n "    • DO_SSH_KEY_ID: "
    check_env_var ".env.staging" "DO_SSH_KEY_ID"
    echo -n "    • STRIPE_SECRET_KEY: "
    check_env_var ".env.staging" "STRIPE_SECRET_KEY"
    echo -n "    • STRIPE_PUBLISHABLE_KEY: "
    check_env_var ".env.staging" "STRIPE_PUBLISHABLE_KEY"
    echo -n "    • EMAIL_PASSWORD: "
    check_env_var ".env.staging" "EMAIL_PASSWORD"
    echo -n "    • GOOGLE_MAPS_API_KEY: "
    check_env_var ".env.staging" "GOOGLE_MAPS_API_KEY"
    echo -n "    • JWT_SECRET: "
    check_env_var ".env.staging" "JWT_SECRET"
    echo -n "    • POSTGRES_PASSWORD: "
    check_env_var ".env.staging" "POSTGRES_PASSWORD"
else
    echo -e "    ${YELLOW}Run: cp .env.staging.template .env.staging${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Phase 4: Deployment Scripts${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -n "  staging-preflight.sh: "
check_file "scripts/staging-preflight.sh"
echo -n "  deploy-staging.sh: "
check_file "scripts/deploy-staging.sh"
echo -n "  test-staging.sh: "
check_file "scripts/test-staging.sh"
echo -n "  generate-secrets.sh: "
check_file "scripts/generate-secrets.sh"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Recommended Next Steps${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

if [ $ENV_EXISTS -ne 0 ]; then
    echo -e "${YELLOW}1. Create environment file:${NC}"
    echo "   cp .env.staging.template .env.staging"
    echo ""
    echo -e "${YELLOW}2. Generate secrets:${NC}"
    echo "   ./scripts/generate-secrets.sh"
    echo ""
    echo -e "${YELLOW}3. Edit .env.staging with your credentials${NC}"
    echo "   nano .env.staging"
    echo ""
else
    echo -e "${GREEN}1. Validate configuration:${NC}"
    echo "   ./scripts/staging-preflight.sh"
    echo ""
    echo -e "${GREEN}2. Deploy to staging:${NC}"
    echo "   ./scripts/deploy-staging.sh"
    echo ""
    echo -e "${GREEN}3. Test deployment:${NC}"
    echo "   ./scripts/test-staging.sh"
    echo ""
fi

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Documentation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "  • Quick Start: STAGING_QUICKSTART.md"
echo "  • Full Guide: STAGING_DEPLOYMENT.md"
echo "  • Third-Party Setup: THIRD_PARTY_SETUP.md"
echo "  • Scripts Reference: scripts/README.md"
echo ""

echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo ""
