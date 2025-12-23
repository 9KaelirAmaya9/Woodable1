#!/bin/bash
# ============================================
# Staging Environment Preflight Checks
# ============================================
# Validates staging environment configuration before deployment
# Usage: ./scripts/staging-preflight.sh

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0
CHECKS=0

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Staging Environment Preflight Checks${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Function to print check result
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((CHECKS++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
    ((CHECKS++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
    ((CHECKS++))
}

# Load .env.staging
ENV_FILE="${ENV_FILE:-.env.staging}"

if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}ERROR: $ENV_FILE not found!${NC}"
    echo "Please create $ENV_FILE from .env.staging.template"
    exit 1
fi

echo -e "${BLUE}Loading environment from: $ENV_FILE${NC}"
echo ""

# Export variables from .env.staging
set -a
source "$ENV_FILE"
set +a

# ============================================
# 1. Check for CHANGE_ME placeholders
# ============================================
echo -e "${BLUE}[1/8] Checking for placeholder values...${NC}"

PLACEHOLDERS=$(grep -c "CHANGE_ME" "$ENV_FILE" || true)
if [ "$PLACEHOLDERS" -gt 0 ]; then
    check_fail "Found $PLACEHOLDERS CHANGE_ME placeholder(s) in $ENV_FILE"
    echo "      Please replace all CHANGE_ME values with actual credentials"
    grep -n "CHANGE_ME" "$ENV_FILE" | head -5
else
    check_pass "No CHANGE_ME placeholders found"
fi
echo ""

# ============================================
# 2. Validate Digital Ocean credentials
# ============================================
echo -e "${BLUE}[2/8] Validating Digital Ocean credentials...${NC}"

if [ -z "$DO_API_TOKEN" ]; then
    check_fail "DO_API_TOKEN is not set"
else
    if [[ "$DO_API_TOKEN" == "dop_v1_"* ]] || [[ "$DO_API_TOKEN" == "dop_"* ]]; then
        check_pass "DO_API_TOKEN format looks valid"
    else
        check_warn "DO_API_TOKEN format may be invalid (should start with dop_v1_ or dop_)"
    fi
fi

if [ -z "$DO_SSH_KEY_ID" ] && [ -z "$DO_API_SSH_KEYS" ]; then
    check_fail "Neither DO_SSH_KEY_ID nor DO_API_SSH_KEYS is set"
else
    check_pass "SSH key configuration found"
fi

if [ -z "$DO_DROPLET_NAME" ]; then
    check_fail "DO_DROPLET_NAME is not set"
else
    check_pass "DO_DROPLET_NAME is set: $DO_DROPLET_NAME"
fi
echo ""

# ============================================
# 3. Validate Stripe test mode
# ============================================
echo -e "${BLUE}[3/8] Validating Stripe configuration...${NC}"

if [ -z "$STRIPE_SECRET_KEY" ]; then
    check_fail "STRIPE_SECRET_KEY is not set"
elif [[ "$STRIPE_SECRET_KEY" == "sk_test_"* ]]; then
    check_pass "Stripe secret key is in TEST mode (correct for staging)"
elif [[ "$STRIPE_SECRET_KEY" == "sk_live_"* ]]; then
    check_fail "Stripe secret key is in LIVE mode (should be TEST for staging!)"
else
    check_warn "Stripe secret key format unrecognized"
fi

if [ -z "$STRIPE_PUBLISHABLE_KEY" ]; then
    check_fail "STRIPE_PUBLISHABLE_KEY is not set"
elif [[ "$STRIPE_PUBLISHABLE_KEY" == "pk_test_"* ]]; then
    check_pass "Stripe publishable key is in TEST mode (correct for staging)"
elif [[ "$STRIPE_PUBLISHABLE_KEY" == "pk_live_"* ]]; then
    check_fail "Stripe publishable key is in LIVE mode (should be TEST for staging!)"
else
    check_warn "Stripe publishable key format unrecognized"
fi

# Check React app Stripe key matches
if [ "$REACT_APP_STRIPE_PUBLISHABLE_KEY" != "$STRIPE_PUBLISHABLE_KEY" ]; then
    check_warn "REACT_APP_STRIPE_PUBLISHABLE_KEY doesn't match STRIPE_PUBLISHABLE_KEY"
fi
echo ""

# ============================================
# 4. Validate email configuration
# ============================================
echo -e "${BLUE}[4/8] Validating email configuration...${NC}"

if [ -z "$EMAIL_PASSWORD" ]; then
    check_fail "EMAIL_PASSWORD is not set"
elif [[ "$EMAIL_PASSWORD" == "SG."* ]]; then
    check_pass "SendGrid API key format looks valid"
else
    check_warn "EMAIL_PASSWORD doesn't look like a SendGrid API key"
fi

if [ -z "$EMAIL_FROM" ]; then
    check_fail "EMAIL_FROM is not set"
else
    check_pass "EMAIL_FROM is set: $EMAIL_FROM"
fi
echo ""

# ============================================
# 5. Validate Google Maps API
# ============================================
echo -e "${BLUE}[5/8] Validating Google Maps API...${NC}"

if [ -z "$GOOGLE_MAPS_API_KEY" ]; then
    check_fail "GOOGLE_MAPS_API_KEY is not set"
elif [[ "$GOOGLE_MAPS_API_KEY" == "AIza"* ]]; then
    check_pass "Google Maps API key format looks valid"
else
    check_warn "GOOGLE_MAPS_API_KEY format may be invalid (should start with AIza)"
fi

# Check React app Google Maps key matches
if [ "$REACT_APP_GOOGLE_MAPS_API_KEY" != "$GOOGLE_MAPS_API_KEY" ]; then
    check_warn "REACT_APP_GOOGLE_MAPS_API_KEY doesn't match GOOGLE_MAPS_API_KEY"
fi
echo ""

# ============================================
# 6. Validate secrets and passwords
# ============================================
echo -e "${BLUE}[6/8] Validating secrets and passwords...${NC}"

# JWT Secret
if [ -z "$JWT_SECRET" ]; then
    check_fail "JWT_SECRET is not set"
elif [ ${#JWT_SECRET} -lt 64 ]; then
    check_warn "JWT_SECRET is less than 64 characters (recommended: 64+)"
else
    check_pass "JWT_SECRET length is adequate (${#JWT_SECRET} chars)"
fi

# Database password
if [ -z "$POSTGRES_PASSWORD" ]; then
    check_fail "POSTGRES_PASSWORD is not set"
elif [ ${#POSTGRES_PASSWORD} -lt 32 ]; then
    check_warn "POSTGRES_PASSWORD is less than 32 characters (recommended: 32+)"
else
    check_pass "POSTGRES_PASSWORD length is adequate (${#POSTGRES_PASSWORD} chars)"
fi

# Check DB_PASS matches POSTGRES_PASSWORD
if [ "$DB_PASS" != "$POSTGRES_PASSWORD" ]; then
    check_fail "DB_PASS doesn't match POSTGRES_PASSWORD"
else
    check_pass "DB_PASS matches POSTGRES_PASSWORD"
fi

# Session secret
if [ -z "$SESSION_SECRET" ]; then
    check_warn "SESSION_SECRET is not set (optional but recommended)"
elif [ ${#SESSION_SECRET} -lt 32 ]; then
    check_warn "SESSION_SECRET is less than 32 characters"
else
    check_pass "SESSION_SECRET length is adequate"
fi
echo ""

# ============================================
# 7. Validate environment settings
# ============================================
echo -e "${BLUE}[7/8] Validating environment settings...${NC}"

if [ "$NODE_ENV" != "staging" ]; then
    check_warn "NODE_ENV is not set to 'staging' (current: $NODE_ENV)"
else
    check_pass "NODE_ENV is set to 'staging'"
fi

if [ "$DEBUG_MODE" == "false" ]; then
    check_warn "DEBUG_MODE is false (consider enabling for staging)"
else
    check_pass "DEBUG_MODE is enabled for staging"
fi

if [ "$LOG_LEVEL" != "debug" ] && [ "$LOG_LEVEL" != "info" ]; then
    check_warn "LOG_LEVEL is '$LOG_LEVEL' (consider 'debug' or 'info' for staging)"
else
    check_pass "LOG_LEVEL is appropriate for staging: $LOG_LEVEL"
fi
echo ""

# ============================================
# 8. Validate domain configuration
# ============================================
echo -e "${BLUE}[8/8] Validating domain configuration...${NC}"

if [ -z "$WEBSITE_DOMAIN" ]; then
    check_warn "WEBSITE_DOMAIN is not set (will use IP address)"
else
    check_pass "WEBSITE_DOMAIN is set: $WEBSITE_DOMAIN"
fi

if [ -z "$TRAEFIK_CERT_EMAIL" ]; then
    check_warn "TRAEFIK_CERT_EMAIL is not set (needed for SSL certificates)"
else
    check_pass "TRAEFIK_CERT_EMAIL is set: $TRAEFIK_CERT_EMAIL"
fi
echo ""

# ============================================
# Summary
# ============================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}Preflight Check Summary${NC}"
echo -e "${BLUE}============================================${NC}"
echo -e "Total checks: $CHECKS"
echo -e "${GREEN}Passed: $((CHECKS - ERRORS - WARNINGS))${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo -e "${RED}Errors: $ERRORS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Preflight checks FAILED${NC}"
    echo -e "${RED}Please fix the errors above before deploying${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Preflight checks passed with warnings${NC}"
    echo -e "${YELLOW}Review warnings above - deployment may proceed${NC}"
    exit 0
else
    echo -e "${GREEN}✅ All preflight checks PASSED${NC}"
    echo -e "${GREEN}Ready to deploy staging environment!${NC}"
    exit 0
fi
