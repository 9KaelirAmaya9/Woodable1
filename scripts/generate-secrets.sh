#!/bin/bash
# ============================================
# Generate Secure Secrets for Staging
# ============================================
# Generates cryptographically secure random secrets
# Usage: ./scripts/generate-secrets.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}Secure Secret Generator${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "${BLUE}Generating secure random secrets...${NC}"
echo ""

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Using openssl instead."
    JWT_SECRET=$(openssl rand -hex 64)
    DB_PASSWORD=$(openssl rand -hex 32)
    SESSION_SECRET=$(openssl rand -hex 64)
else
    JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
    DB_PASSWORD=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    SESSION_SECRET=$(node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
fi

echo -e "${GREEN}✓ Secrets generated successfully${NC}"
echo ""

echo -e "${CYAN}Copy these values to your .env.staging file:${NC}"
echo ""

echo -e "${BLUE}# JWT Secret (128 characters)${NC}"
echo "JWT_SECRET=$JWT_SECRET"
echo ""

echo -e "${BLUE}# Database Password (64 characters)${NC}"
echo "POSTGRES_PASSWORD=$DB_PASSWORD"
echo "DB_PASS=$DB_PASSWORD"
echo ""

echo -e "${BLUE}# Session Secret (128 characters)${NC}"
echo "SESSION_SECRET=$SESSION_SECRET"
echo ""

echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}✓ Done!${NC}"
echo ""
echo -e "${BLUE}Security Tips:${NC}"
echo "  • Never commit these secrets to version control"
echo "  • Use different secrets for staging and production"
echo "  • Store secrets securely (password manager, vault)"
echo "  • Rotate secrets every 90 days"
echo ""
