#!/bin/bash
# ============================================
# Deploy Rico's Tacos to Staging Environment
# ============================================
# Deploys the application to Digital Ocean staging environment
# Usage: ./scripts/deploy-staging.sh [--dry-run]

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}Rico's Tacos - Staging Deployment${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Set environment file
export ENV_FILE="${ENV_FILE:-.env.staging}"
ENV_PATH="$PROJECT_ROOT/$ENV_FILE"

echo -e "${BLUE}Project root: $PROJECT_ROOT${NC}"
echo -e "${BLUE}Environment file: $ENV_FILE${NC}"
echo ""

# Check if .env.staging exists
if [ ! -f "$ENV_PATH" ]; then
    echo -e "${RED}ERROR: $ENV_FILE not found at $ENV_PATH${NC}"
    echo ""
    echo "Please create $ENV_FILE from .env.staging.template:"
    echo "  cp .env.staging.template $ENV_FILE"
    echo "  # Then edit $ENV_FILE with your credentials"
    exit 1
fi

# ============================================
# Step 1: Run Preflight Checks
# ============================================
echo -e "${BLUE}[Step 1/4] Running preflight checks...${NC}"
echo ""

if [ -f "$SCRIPT_DIR/staging-preflight.sh" ]; then
    bash "$SCRIPT_DIR/staging-preflight.sh"
    PREFLIGHT_EXIT=$?
    
    if [ $PREFLIGHT_EXIT -ne 0 ]; then
        echo ""
        echo -e "${RED}Preflight checks failed. Please fix errors before deploying.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Warning: staging-preflight.sh not found, skipping preflight checks${NC}"
fi

echo ""
echo -e "${GREEN}✓ Preflight checks passed${NC}"
echo ""

# ============================================
# Step 2: Load Environment Variables
# ============================================
echo -e "${BLUE}[Step 2/4] Loading environment variables...${NC}"
echo ""

# Export variables from .env.staging
set -a
source "$ENV_PATH"
set +a

echo -e "${GREEN}✓ Environment variables loaded${NC}"
echo "  - Project: $PROJECT_NAME"
echo "  - Environment: $NODE_ENV"
echo "  - Droplet: $DO_DROPLET_NAME"
echo "  - Region: $DO_API_REGION"
echo "  - Size: $DO_API_SIZE"
echo ""

# ============================================
# Step 3: Deploy to Digital Ocean
# ============================================
echo -e "${BLUE}[Step 3/4] Deploying to Digital Ocean...${NC}"
echo ""

# Check if orchestrate_deploy.py exists
DEPLOY_SCRIPT="$PROJECT_ROOT/digital_ocean/orchestrate_deploy.py"
if [ ! -f "$DEPLOY_SCRIPT" ]; then
    echo -e "${RED}ERROR: Deployment script not found at $DEPLOY_SCRIPT${NC}"
    exit 1
fi

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}ERROR: python3 not found. Please install Python 3.${NC}"
    exit 1
fi

# Check for required Python packages
echo "Checking Python dependencies..."
if ! python3 -c "import pydo" 2>/dev/null; then
    echo -e "${YELLOW}Installing required Python packages...${NC}"
    pip3 install -r "$PROJECT_ROOT/digital_ocean/requirements.txt" || {
        echo -e "${RED}Failed to install Python dependencies${NC}"
        exit 1
    }
fi

echo ""
echo -e "${CYAN}Starting Digital Ocean deployment...${NC}"
echo -e "${CYAN}This may take 5-10 minutes...${NC}"
echo ""

# Run deployment script with environment variables
cd "$PROJECT_ROOT"
python3 "$DEPLOY_SCRIPT" "$@"

DEPLOY_EXIT=$?

if [ $DEPLOY_EXIT -ne 0 ]; then
    echo ""
    echo -e "${RED}Deployment failed. Check logs above for details.${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Deployment completed successfully${NC}"
echo ""

# ============================================
# Step 4: Post-Deployment Summary
# ============================================
echo -e "${BLUE}[Step 4/4] Deployment Summary${NC}"
echo ""

# Try to read deployment info from DO_userdata.json
if [ -f "$PROJECT_ROOT/DO_userdata.json" ]; then
    DROPLET_ID=$(python3 -c "import json; print(json.load(open('DO_userdata.json')).get('droplet_id', 'N/A'))" 2>/dev/null || echo "N/A")
    IP_ADDRESS=$(python3 -c "import json; print(json.load(open('DO_userdata.json')).get('ip_address', 'N/A'))" 2>/dev/null || echo "N/A")
    
    echo -e "${CYAN}Deployment Details:${NC}"
    echo "  Droplet ID: $DROPLET_ID"
    echo "  IP Address: $IP_ADDRESS"
    echo "  Environment: staging"
    echo ""
    
    if [ "$IP_ADDRESS" != "N/A" ]; then
        echo -e "${CYAN}Access Your Staging Environment:${NC}"
        echo ""
        echo "  SSH into droplet:"
        echo -e "    ${GREEN}ssh root@$IP_ADDRESS${NC}"
        echo ""
        echo "  View application logs:"
        echo -e "    ${GREEN}ssh root@$IP_ADDRESS 'docker logs -f \$(docker ps -q -f name=backend)'${NC}"
        echo ""
        echo "  Access via IP (HTTP):"
        echo -e "    ${GREEN}http://$IP_ADDRESS${NC}"
        echo ""
        
        if [ -n "$WEBSITE_DOMAIN" ] && [ "$WEBSITE_DOMAIN" != "staging.ricostacos.com" ]; then
            echo -e "${YELLOW}Next Steps - DNS Configuration:${NC}"
            echo ""
            echo "  1. Add DNS A record for your domain:"
            echo "     Domain: $WEBSITE_DOMAIN"
            echo "     Type: A"
            echo "     Value: $IP_ADDRESS"
            echo "     TTL: 300"
            echo ""
            echo "  2. Wait for DNS propagation (5-30 minutes)"
            echo ""
            echo "  3. Access via domain (HTTPS):"
            echo "     https://$WEBSITE_DOMAIN"
            echo ""
        fi
        
        echo -e "${CYAN}Testing Your Deployment:${NC}"
        echo ""
        echo "  Run automated tests:"
        echo -e "    ${GREEN}./scripts/test-staging.sh${NC}"
        echo ""
        echo "  Test Stripe checkout with test card:"
        echo "     Card: 4242 4242 4242 4242"
        echo "     Expiry: Any future date"
        echo "     CVC: Any 3 digits"
        echo ""
    fi
else
    echo -e "${YELLOW}Could not read deployment details from DO_userdata.json${NC}"
fi

echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}✅ Staging deployment complete!${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
